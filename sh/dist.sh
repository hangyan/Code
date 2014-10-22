#!/usr/bin/env bash

##########################################
#  File:    distribute.sh
#  Author:  Hang Yan
#  Email:   yanhangyhy@gmail.com
#  Desc:    flume管理通用脚本.           
#  Usage:   see Usage.
#  Todo:    1.jdk设置
#           2.更新文件
#           
##########################################

##########################################
#          设计原则
# 1. 设计文件操作之前，必须判断文件存在与否
#    scp时,统一由scp_file来做判断
# 2. 文件可执行权限判定
# 3. 单个节点最顶层函数在错误时必须返回详细错误信息
#    说明程序在哪一阶段失败
# 4. *_all 函数无需进行函数返回值判定，应交由单个
#    函数来做，使其保持独立性
#
##########################################

ERROR_INFO=""

### colorful output
which tput >/dev/null
if [ $? -eq 0 ];then
    NORMAL=$(tput sgr0)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1;tput bold)
    err () {
        echo "$RED[$(date +'%Y-%m-%d %H:%M:%S')]: $@$NORMAL" >&2
        ERROR_INFO=$ERROR_INFO"<$NODE>:$@\n"
    }
    debug () {
        echo "$GREEN[$(date +'%Y-%m-%d %H:%M:%S')]: $@$NORMAL" >&2
    }

fi

### Config file
CFG_FILE="dist.cfg"
NODES=""


### flume env vars.
JDK_DIR=jdk1.6.0_31
FLUME_DIST=apache-flume-1.5.0-SNAPSHOT-bin
FLUME_DIR=/disk2/flume
JDK_PATH=$FLUME_DIR/$JDK_DIR
FLUME_BASE_DIR=$FLUME_DIR/$FLUME_DIST
FLUME_UPDATE_DIR=$FLUME_BASE_DIR/distribute
FLUME_BACKUP_DIR=$FLUME_BASE_DIR/backup

### flume confs
FLUME_NODE_TYPE=collector
FLUME_CONF_FILE=conf/collector.conf

SOURCE_FILE=""
DEST_DIR=""

FLUME_LOCAL_FILE=$FLUME_DIST.tar.gz
JDK_TAR_FILE=$JDK_DIR.tar.gz

### auth settings
LOCAL_KEY_FILE="id_rsa.pub"
REMOTE_AUTH_FILE="~/.ssh/authorized_keys"

USER=sunflower
USER_HOME=/home/$USER
if [ $USER = "root" ];then
    USER_HOME="/root"
fi

NODE=""
FLUME_PID=0
TIMES=60
INTER=1
CUR_TIME=""

### monitor settings
MONITOR_TIMES=30
MONITOR_LEVEL="WARN"
MONITOR_DAYS=1


load_config()
{
    if [ ! -e $CFG_FILE ];then
        err "config file not exist!"
        return 1
    fi
    
    read_ini -p dist dist.cfg
    
    NODES=$dist__dist__nodes    
    IFS=' ' read -a NODES <<< "$NODES"

    FLUME_DIST=$dist__dist__flume
    JDK_DIR=$dist__dist__jdk
    FLUME_DIR=$dist__path__root
    
    JDK_PATH=$FLUME_DIR/$JDK_DIR
    FLUME_BASE_DIR=$FLUME_DIR/$FLUME_DIST
    FLUME_UPDATE_DIR=$FLUME_BASE_DIR/distribute
    FLUME_BACKUP_DIR=$FLUME_BASE_DIR/backup
    
    FLUME_NODE_TYPE=$dist__conf__node
    FLUME_CONF_FILE=$dist__conf__file
    
    SOURCE_FILE=$dist__file__source
    DEST_DIR=$dist__file__dest
    FLUME_LOCAL_FILE=$dist__file__flume
    JDK_TAR_FILE=$dist__file__jdk
    LOCAL_KEY_FILE=$dist__ssh__file
    REMOTE_AUTH_FILE=$dist__ssh__remote
    
    USER=$dist__ssh__user
    USER_HOME=/home/$USER
    if [ $USER = "root" ];then
      USER_HOME="/root"
    fi
    
    TIMES=$dist__counter__times
    INTER=$dist__counter__inter
    
    MONITOR_TIMES=$dist__monitor__times
    MONITOR_DAYS=$dist__monitor__days
    MONITOR_LEVEL=$dist__monitor__level
}

scp_file ()
{
    if [ $# -eq 2 ] && [ ! -z "$1" ] && [ ! -z "$2" ];then
        ssh -l $USER $NODE test -d "$2"
        if [ $? -eq 0 ] && [ -e "$1" ];then
            scp -r $1 $USER@$NODE:$2
            if [ $? -eq 0 ];then
                debug "  Scp file  $1 done."
                return 0
            else
                err "  Scp file $1 error."
                return 1
            fi
        else
            err "  source file or dest dir not exist,scp file failed!"
            return 1
        fi
    else
        err "  wrong arguments,scp file failed!"
        return 1
    fi
}


deploy_jdk_file()
{
    ssh -l $USER $NODE mkdir -p $FLUME_DIR 2&>/dev/null
    scp_file $JDK_TAR_FILE $FLUME_DIR
    if [ $? -eq 1 ];then
        return 1
    else
        debug "  Extracting jdk files..."
        ssh -l $USER $NODE "cd $FLUME_DIR && tar -xzvf $JDK_TAR_FILE > /dev/null"
        debug "  Extract jdk files done."
        return 0
    fi
}


correct_jdk_set ()
{
    ssh -l $USER $NODE test -d $JDK_PATH
    if [ $? -eq 0 ];then
        debug "  Jdk path is correct."
        return 0
    else
		debug "  Start deploy jdk files..."
        deploy_jdk_file
        return $?
    fi
 }


backup_logs ()
{
    return 0
    ssh -l $USER $NODE "test -d $FLUME_BASE_DIR/logs && cd $FLUME_BASE_DIR/logs && test -e flume.log && mv flume.log flume.log.$CUR_TIME"
    return $?
}

generate_start_scipt()
{
    (
    cat <<EOF
export JAVA_HOME=$JDK_PATH
export PATH=\$JAVA_HOME/bin:\$PATH
source ~/.profile
source ~/.bashrc
nohup bin/flume-ng agent -n $FLUME_NODE_TYPE -c conf -f $FLUME_CONF_FILE 
EOF
) > start.sh
}

get_flume_pid()
{
    ### on some machine,there is no conf info in `ps`
    FLUME_PID=$(ssh -l $USER $NODE ps aux | grep $FLUME_BASE_DIR |awk  '/java.*flume.*jar.*/ {print $2}' | head -1)
    [[ -z "$FLUME_PID" ]] && FLUME_PID=0
}



stop_flume()
{
    for i in `seq 1 $TIMES`
    do
        get_flume_pid
        if [[ $FLUME_PID -gt 0 ]]; then
            debug "  Flume process exist($FLUME_PID).Killing it..."
            ssh -l $USER $NODE kill  -9 $FLUME_PID
            sleep $INTER
        else
            debug "  Flume process has been killed."
            break
        fi
    done

    get_flume_pid
    
    if [[ $FLUME_PID -gt 0 ]];then
        err "  Can not kill flume process nomally,stop flume failed!"
        return 1
    else
        return 0
    fi
}




monitor_flume()
{
	get_flume_pid
	if [ $FLUME_PID -gt 0 ];then
		debug "  Flume Process exist,pid is [$FLUME_PID]"
	else
		err "  Flume Process not exist!"
		return 1
	fi
	
	ssh -l $USER $NODE "test -d $FLUME_BASE_DIR/logs && cd $FLUME_BASE_DIR/logs && test -e $FLUME_BASE_DIR/logs/flume.log"
	if [ $? -eq 0 ];then
        date_str_=$(date -d "-$MONITOR_DAYS days" +"%d %b %Y") 
        if [ "$MONITOR_LEVEL" = "INFO" ];then
            scp $USER@$NODE:$FLUME_BASE_DIR/logs/flume.log $NODE-flume.log
        elif [ "$MONITOR_LEVEL" = "WARN" ];then
		    ssh -l $USER $NODE "cd $FLUME_BASE_DIR/logs && grep -n \"$date_str_\"  flume.log|egrep '(WARN|ERROR|Exception)'"
        else
            ssh -l $USER $NODE "cd $FLUME_BASE_DIR/logs && grep -n \"$date_str_\"  flume.log|egrep '(ERROR|Exception)'"
        fi
        
		if [ $? -eq 0 ];then
			return 1
		else
			debug "  No errors found."
		    return 0
		fi    
	else
		err "  Flume log file not exist!"
		return 1
	fi
	
}


start_flume()
{
    debug "  Test old flume process ..."
    get_flume_pid
    if [[ $FLUME_PID -gt 0 ]];then
        err "  Old flume process exist,start flume failed!"
        return 1
    else
        debug "  Starting flume process..."
        generate_start_scipt
        ssh -l $USER $NODE test -d $FLUME_BASE_DIR
        if [ $? -eq 1 ];then
            err "  No flume dist exist,start flume failed!"
            return 1
        fi
        scp_file start.sh $FLUME_BASE_DIR 
        if [ $? -eq 1 ];then
			err "  scp file error,start flume failed!"
			return 1
		fi
        ssh $USER@$NODE "cd $FLUME_BASE_DIR && test -e bin/flume-ng && chmod a+x bin/flume-ng &&  test -e conf/flume-env.sh && test -e start.sh && chmod a+x start.sh"
        ssh $USER@$NODE "which dos2unix > /dev/null && cd $FLUME_BASE_DIR && dos2unix bin/flume-ng && dos2unix conf/flume-env.sh"
        CUR_TIME=$(date +'%Y-%m-%dT%H-%M')
        backup_logs
        ssh -n -f $USER@$NODE "cd $FLUME_BASE_DIR && source start.sh"

        for i in `seq 1 $TIMES`
        do
            get_flume_pid
            if [ $FLUME_PID -gt 0 ];then
                debug "  Start flume successfully."
                return 0
            else
                sleep $INTER
            fi
        done

        err "  Start flume failed!"
        return 1
    fi      
}


deploy_flume()
{
    debug "  Test old flume process ..."
    get_flume_pid
    if [[ $FLUME_PID -gt 0 ]];then
        err "  Old flume process exist,deploy failed!"
        return 1
    else
        debug "  Start deploy flume dist files..."
        correct_jdk_set
        if [ $? -eq 1 ];then
            err "  Jdk set error,deploy failed!"
            return 1
        fi

        ssh -l $USER $NODE "mkdir -p $FLUME_DIR > /dev/null 2>&1"
	ssh -l $USER $NODE "test -d $FLUME_BASE_DIR && mkdir -p $FLUME_DIR/backup && mv $FLUME_BASE_DIR $FLUME_DIR/backup"
        scp_file $FLUME_LOCAL_FILE $FLUME_DIR
        if [ $? -eq 1 ];then
            err "Scp flume file error,deploy flume failed!"
            return 1
        fi
        debug "  Extracting flume dist files..."
        ssh -l $USER $NODE "cd $FLUME_DIR &&  tar -xzvf $FLUME_LOCAL_FILE > /dev/null && test -d $FLUME_BASE_DIR "
        if [ $? -eq 0 ];then
            debug "  Deploy flume dist done."
            return 0
        else
            err "  Deploy flume dist error!"
            return 1
        fi
    fi
}

update_flume()
{
    debug "  Test old flume process ..."
    get_flume_pid
    if [[ $FLUME_PID -gt 0 ]];then
        err "  Old flume process exist,skip this node!"
        return 1
    else
        CUR_TIME=$(date +'%Y-%m-%dT%H-%M')
        debug "  No flume process exist.Start copy updated files..."
        if [[ ! -z $SOURCE_FILE && ! -z $DEST_DIR ]];then
			temp_prefix_=$(sed 's/\//-/g' <<< "$SOURCE_FILE")
            TRANS_DIR=$temp_prefix_"--"$CUR_TIME
            ssh -l $USER $NODE mkdir -p $FLUME_UPDATE_DIR/$TRANS_DIR 2>/dev/null
            ssh -l $USER $NODE mkdir -p $FLUME_BACKUP_DIR/$TRANS_DIR 2>/dev/null
            scp_file $SOURCE_FILE $FLUME_UPDATE_DIR/$TRANS_DIR
            if [ $? -eq 1 ];then
				err "  scp updated file error,update flume failed!"
				return 1
			fi
            backup_logs
            ssh -l $USER $NODE "cd $FLUME_BASE_DIR && cp -r $DEST_DIR/$SOURCE_FILE $FLUME_BACKUP_DIR/$TRANS_DIR"
            ssh -l $USER $NODE "cd $FLUME_BASE_DIR && cp -r $FLUME_UPDATE_DIR/$TRANS_DIR/* $DEST_DIR/"
            debug "  Update file $SOURCE_FILE done."
            return 0
        else
            err "  script arguments wrong,updat flume failed!"
            return 1
        fi
    fi
}

auth()
{
	flag_=0
    key_full_path_=$HOME/.ssh/$LOCAL_KEY_FILE
	if [ ! -e $key_full_path_ ];then
		err "  No ssh rsa key found!auth failed!"
		return 1
	fi
    local_pub_key_=$(cat $key_full_path_)
    ssh -l $USER $NODE "cd ~ && test -e $REMOTE_AUTH_FILE"
    if [ $? -eq 0 ];then
		ssh -l $USER $NODE "grep \"$local_pub_key_\" $REMOTE_AUTH_FILE > /dev/null"
		if [ $? -eq 0 ];then
			debug "  Authentication has been done before."
			return 0
		else
			flag_=1
		fi
    else
        flag_=1
    fi
    
    if [ $flag_ -eq 1 ];then
		ssh-copy-id $USER@$NODE
		debug "  Authentication successfully."
	fi	
    return 0    
}




deploy_all()
{
    debug "Start deploy flume dist..."
    for NODE in "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        stop_flume
        deploy_flume
        start_flume
    done
}

dist_all()
{
    debug "Start copy full flume dist files..."
    for NODE in "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        deploy_flume
    done
}


replace_all()
{
    debug "Start replace flume files..."
    for NODE in "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        update_flume
    done
}
update_all()
{
    debug "Start update flume ..."
    for NODE in "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        stop_flume
        update_flume
        start_flume
    done
}

stop_all()
{
    debug "Stop all nodes'flume process..."
    for NODE in  "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        stop_flume
    done
}


start_all()
{
    debug "Start all nodes'flume process..."
    for NODE in "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        start_flume
    done
}

restart_all()
{
    debug "Restart all nodes'flume process..."
    for NODE in "${NODES[@]}";do
        debug "Processing node : $NODE ..."
        auth
        stop_flume
        start_flume
    done   
}

auth_all()
{
    debug "Start authentication all ndoes..."
    for NODE in "${NODES[@]}" ;do
        debug "Processing node : $NODE..."
        auth
    done
}

monitor_all()
{
	debug "Start monitor all ndoes..."
	for i in `seq 1 $MONITOR_TIMES`; do
        for NODE in "${NODES[@]}" ;do
            debug "Processing node : $NODE..."
            auth
            monitor_flume
        done
    done
}


main ()
{
	load_config

	case "$1" in
		auth)
			auth_all
			;;
		restart)
			restart_all
			;;
    
		stop)
			stop_all
			;;
    
		start)
			start_all
			;;
		dist)
			dist_all
			;;
		deploy)
			deploy_all
			;;
		monitor)
			monitor_all
			;;
		replace)
			if [ $# -ge 3 ];then
				SOURCE_FILE=$2
				DEST_DIR=$3
				replace_all
			else
				err "No updating file supplyed!"
				exit
			fi
			;;
		update)
			if [ $# -ge 3 ];then
				SOURCE_FILE=$2
				DEST_DIR=$3
				update_all
			else
				err "No updating file supplyed!"
				exit
			fi
			;;
		
		*)
			cat <<FLUME_DISTRIBUTE_SH_USAGE
Usage: $0 {start|stop|restart|deploy|update src_file dst_dir}
---------------------------------------------------------------
start:   启动所有节点的flume进程,若已存在flume进程,则跳过
stop:    杀死所有节点的flume进程,如果失败,跳过
restart: 重启所有节点的flume进程,如果杀死失败时，跳过,备份日志信息
deploy:  部署一个全新的flume.包括jdk及环境变量设置.若已有flume进程，跳过.
         flume/jdk文件传送失败时跳过.部署完成后启动flume.
dist:    仅部署flume文件,不启动flume进程.若已有flume进程,跳过
update:  1.杀死flume进程失败时跳过
         2.更新文件
         3.重启flume.
monitor: 读取flume.log,打印出异常信息
auth:    密码认证.其他操作在执行之前也会进行认证.
相关文件说明:
1.apache-flume-0.2.0-SNAPSHOT-bin.tar.gz 
	本地flume发行压缩包，新部署机器时需要
2.jdk1.6.0_31.tar.gz 
	jdk文件压缩包，新部署机器时需要.
3.nodelist 
	需要操作的机器列表
FLUME_DISTRIBUTE_SH_USAGE
			exit 1
	esac
	
	echo -e "\n"
	echo "----------------------------SUMMARY--------------------------"
	if [ -z "$ERROR_INFO" ];then
		debug "No Errors."
	else
		echo -e "$ERROR_INFO"
	fi
}

function read_ini()
{
	# Be strict with the prefix, since it's going to be run through eval
	function check_prefix()
	{
		if ! [[ "${VARNAME_PREFIX}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] ;then
			echo "read_ini: invalid prefix '${VARNAME_PREFIX}'" >&2
			return 1
		fi
	}
	
	function check_ini_file()
	{
		if [ ! -r "$INI_FILE" ] ;then
			echo "read_ini: '${INI_FILE}' doesn't exist or not" \
				"readable" >&2
			return 1
		fi
	}
	
	# enable some optional shell behavior (shopt)
	function pollute_bash()
	{
		if ! shopt -q extglob ;then
			SWITCH_SHOPT="${SWITCH_SHOPT} extglob"
		fi
		if ! shopt -q nocasematch ;then
			SWITCH_SHOPT="${SWITCH_SHOPT} nocasematch"
		fi
		shopt -q -s ${SWITCH_SHOPT}
	}
	
	# unset all local functions and restore shopt settings before returning
	# from read_ini()
	function cleanup_bash()
	{
		shopt -q -u ${SWITCH_SHOPT}
		unset -f check_prefix check_ini_file pollute_bash cleanup_bash
	}
	
	local INI_FILE=""
	local INI_SECTION=""

	# {{{ START Deal with command line args

	# Set defaults
	local BOOLEANS=1
	local VARNAME_PREFIX=INI
	local CLEAN_ENV=0

	# {{{ START Options

	# Available options:
	#	--boolean		Whether to recognise special boolean values: ie for 'yes', 'true'
	#					and 'on' return 1; for 'no', 'false' and 'off' return 0. Quoted
	#					values will be left as strings
	#					Default: on
	#
	#	--prefix=STRING	String to begin all returned variables with (followed by '__').
	#					Default: INI
	#
	#	First non-option arg is filename, second is section name

	while [ $# -gt 0 ]
	do

		case $1 in

			--clean | -c )
				CLEAN_ENV=1
			;;

			--booleans | -b )
				shift
				BOOLEANS=$1
			;;

			--prefix | -p )
				shift
				VARNAME_PREFIX=$1
			;;

			* )
				if [ -z "$INI_FILE" ]
				then
					INI_FILE=$1
				else
					if [ -z "$INI_SECTION" ]
					then
						INI_SECTION=$1
					fi
				fi
			;;

		esac

		shift
	done

	if [ -z "$INI_FILE" ] && [ "${CLEAN_ENV}" = 0 ] ;then
		echo -e "Usage: read_ini [-c] [-b 0| -b 1]] [-p PREFIX] FILE"\
			"[SECTION]\n  or   read_ini -c [-p PREFIX]" >&2
		cleanup_bash
		return 1
	fi

	if ! check_prefix ;then
		cleanup_bash
		return 1
	fi

	local INI_ALL_VARNAME="${VARNAME_PREFIX}__ALL_VARS"
	local INI_ALL_SECTION="${VARNAME_PREFIX}__ALL_SECTIONS"
	local INI_NUMSECTIONS_VARNAME="${VARNAME_PREFIX}__NUMSECTIONS"
	if [ "${CLEAN_ENV}" = 1 ] ;then
		eval unset "\$${INI_ALL_VARNAME}"
	fi
	unset ${INI_ALL_VARNAME}
	unset ${INI_ALL_SECTION}
	unset ${INI_NUMSECTIONS_VARNAME}

	if [ -z "$INI_FILE" ] ;then
		cleanup_bash
		return 0
	fi
	
	if ! check_ini_file ;then
		cleanup_bash
		return 1
	fi

	# Sanitise BOOLEANS - interpret "0" as 0, anything else as 1
	if [ "$BOOLEANS" != "0" ]
	then
		BOOLEANS=1
	fi


	# }}} END Options

	# }}} END Deal with command line args

	local LINE_NUM=0
	local SECTIONS_NUM=0
	local SECTION=""
	
	# IFS is used in "read" and we want to switch it within the loop
	local IFS=$' \t\n'
	local IFS_OLD="${IFS}"
	
	# we need some optional shell behavior (shopt) but want to restore
	# current settings before returning
	local SWITCH_SHOPT=""
	pollute_bash
	
	while read -r line || [ -n "$line" ]
	do
#echo line = "$line"

		((LINE_NUM++))

		# Skip blank lines and comments
		if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
		then
			continue
		fi

		# Section marker?
		if [[ "${line}" =~ ^\[[a-zA-Z0-9_]{1,}\]$ ]]
		then

			# Set SECTION var to name of section (strip [ and ] from section marker)
			SECTION="${line#[}"
			SECTION="${SECTION%]}"
			eval "${INI_ALL_SECTION}=\"\${${INI_ALL_SECTION}# } $SECTION\""
			((SECTIONS_NUM++))

			continue
		fi

		# Are we getting only a specific section? And are we currently in it?
		if [ ! -z "$INI_SECTION" ]
		then
			if [ "$SECTION" != "$INI_SECTION" ]
			then
				continue
			fi
		fi

		# Valid var/value line? (check for variable name and then '=')
		if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
		then
			echo "Error: Invalid line:" >&2
			echo " ${LINE_NUM}: $line" >&2
			cleanup_bash
			return 1
		fi


		# split line at "=" sign
		IFS="="
		read -r VAR VAL <<< "${line}"
		IFS="${IFS_OLD}"
		
		# delete spaces around the equal sign (using extglob)
		VAR="${VAR%%+([[:space:]])}"
		VAL="${VAL##+([[:space:]])}"
		VAR=$(echo $VAR)


		# Construct variable name:
		# ${VARNAME_PREFIX}__$SECTION__$VAR
		# Or if not in a section:
		# ${VARNAME_PREFIX}__$VAR
		# In both cases, full stops ('.') are replaced with underscores ('_')
		if [ -z "$SECTION" ]
		then
			VARNAME=${VARNAME_PREFIX}__${VAR//./_}
		else
			VARNAME=${VARNAME_PREFIX}__${SECTION}__${VAR//./_}
		fi
		eval "${INI_ALL_VARNAME}=\"\${${INI_ALL_VARNAME}# } ${VARNAME}\""

		if [[ "${VAL}" =~ ^\".*\"$  ]]
		then
			# remove existing double quotes
			VAL="${VAL##\"}"
			VAL="${VAL%%\"}"
		elif [[ "${VAL}" =~ ^\'.*\'$  ]]
		then
			# remove existing single quotes
			VAL="${VAL##\'}"
			VAL="${VAL%%\'}"
		elif [ "$BOOLEANS" = 1 ]
		then
			# Value is not enclosed in quotes
			# Booleans processing is switched on, check for special boolean
			# values and convert

			# here we compare case insensitive because
			# "shopt nocasematch"
			case "$VAL" in
				yes | true | on )
					VAL=1
				;;
				no | false | off )
					VAL=0
				;;
			esac
		fi
		

		# enclose the value in single quotes and escape any
		# single quotes and backslashes that may be in the value
		VAL="${VAL//\\/\\\\}"
		VAL="\$'${VAL//\'/\'}'"

		eval "$VARNAME=$VAL"
	done  <"${INI_FILE}"
	
	# return also the number of parsed sections
	eval "$INI_NUMSECTIONS_VARNAME=$SECTIONS_NUM"

	cleanup_bash
}



main "$@"


