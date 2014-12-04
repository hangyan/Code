#!/usr/bin/perl -w
# NAME: gencmake.pl
# AIM: Given an input folder, roughly generate a CMakeLists.txt from what is seem
# 31/07/2012 - Added *.rc files to sources
# 09/07/2012 - Initial cut
use strict;
use warnings;
use File::Basename;  # split path ($name,$dir,$ext) = fileparse($file [, qr/\.[^.]*/] )
use File::Spec; # File::Spec->rel2abs($rel); # we are IN the SLN directory, get ABSOLUTE from
use Cwd;
my $os = $^O;
my $perl_dir = '/home/geoff/bin';
my $PATH_SEP = '/';
my $temp_dir = '/tmp';
if ($os =~ /win/i) {
    $perl_dir = 'C:\GTools\perl';
    $temp_dir = $perl_dir;
    $PATH_SEP = "\\";
}
unshift(@INC, $perl_dir);
require 'lib_utils.pl' or die "Unable to load 'lib_utils.pl' Check paths in \@INC...\n";
require 'lib_params.pl' or die "Unable to load 'lib_params.pl'! Check location and \@INC content.\n";
require 'lib_amscan.pl' or die "Unable to load 'lib_amscan.pl'! Check location and \@INC content.\n";

# log file stuff
our ($LF);
my $pgmname = $0;
if ($pgmname =~ /(\\|\/)/) {
    my @tmpsp = split(/(\\|\/)/,$pgmname);
    $pgmname = $tmpsp[-1];
}
my $outfile = $temp_dir.$PATH_SEP."temp.$pgmname.txt";
open_log($outfile);

# user variables
my $VERS = "0.0.2 2012-07-31";  # add *.rc files also
###my $VERS = "0.0.1 2012-07-09";
my $load_log = 0;
my $in_directory = '';
my $verbosity = 0;
my $out_file = '';
my $proj_title = '';
my $tmp_cmake_list = $temp_dir.$PATH_SEP."temp.CMakeLists.txt";

# DEBUG
my $debug_on = 0;
my $def_dir = 'C:\GTools\tools\versinfo';
###my $def_dir = 'C:\FG\16\fgms-1-x';
#my $def_dir = 'C:\Users\user\Downloads\temp7\Tools\MainLine';

### program variables
my @warnings = ();
my $cwd = cwd();
my %files_found = ();
my %c_files_found = ();
my %h_files_found = ();
my %am_files_found = ();
my $total_dirs = 0;
my $total_c_files = 0;
my $total_h_files = 0;
my $total_am_files = 0;

my $TYP_NONE = 0;   # well not defined
my $TYP_C    = 1;   # .c .cpp, .cxx
my $TYP_H    = 2;   # .h .hpp, .hxx
my $TYP_RC   = 3;   # .rc
my $TYP_AM   = 4;   # Makefile.am

### shared 
### SHARED RESOURCES, VALUES
### ========================
our $fix_relative_sources = 1;
our %g_user_subs = ();    # supplied by USER INPUT
our %g_user_condits = (); # conditionals supplied by the user
# Auto output does the following -
# For libaries
# Debug:  '/out:"lib\barD.lib"'
# Release:'/out:"lib\barD.lib"'
# for programs
# Debug:  '/out:"bin\fooD.exe"'
# Release:'/out:"bin\foo.exe"'
# This also 'adds' missing 'include' files
#Bit:   1: Use 'Debug\$proj_name', and 'Release\$proj_name' for intermediate and out directories
#Bit:   2: Set output to lib, or bin, and names to fooD.lib/foo.lib or barD.exe/bar.exe
#Bit:   4: Set program dependence per library output directories
#Bit:   8: Add 'msvc' to input file directory, if no target directory given
#Bit:  16: Add program library dependencies, if any, to DSW file output.
#Bit:  32: Add all necessary headers to the DSP file. That is scan the sources for #include "foo.h", etc.
#Bit:  64: Write a blank header group even there are no header files for that component.
#Bit: 128: Add defined item of HAVE_CONFIG_H to all DSP files.
#Bit: 256: Exclude projects in SUBDIRS protected by a DEFINITION macro, else include ALL.
#Bit: 512: Unconditionally add ANY libraries build, and NOT excluded to the last application
#Bit:1024: If NO users conditional, do sustitution, if at all possible, regardless of TRUE or FALSE
#Bit:2048: Add User -L dependent libraries to each application
#Bit: These can be given as an integer, or the form 2+8, etc. Note using -1 sets ALL bits on.
#Bit: Bit 32 really slows down the DSP creation, since it involves scanning every line of the sources.
my $auto_max_bit = 512;
our $auto_on_flag = -1; #Bit: ALL ON by default = ${$rparams}{'CURR_AUTO_ON_FLAG'}
sub get_curr_auto_flag() { return $auto_on_flag; }
#my ($g_in_name, $g_in_dir);
#my ($root_file, $root_folder);
#sub get_root_dir() { return $root_folder; }
our $exit_value = 0;
# But SOME Makefile.am will use specific 'paths' so the above can FAIL to find
# a file, so the following two 'try harder' options, will do a full 'root'
# directory SCAN, and search for the file of that name in the scanned files
our $try_harder = 0;
our $try_much_harder = 0;
# ==============================================================================
our $process_subdir = 0;
our $warn_on_plus = 0;
# ==============================================================================
# NOTE: Usually a Makefile.am contains SOURCE file names 'relative' to itself,
# which is usually without any path. This options ADDS the path to the
# Makefile.am, and then substracts the 'root' path, to get a SOURCE file
# relative to the 'root' configure.ac, which is what is needed if the DSP
# is to be placed in a $target_dir, and we want the file relative to that
our $add_rel_sources = 1;
our $target_dir = '';
# ==============================================================================
our $ignore_EXTRA_DIST = 0;
our $added_in_init = '';
our $supp_make_in = 0; # Support Makefile.in scanning
our $project_name = ''; # a name to override any ac scanned name of the project

###my $dsp_files_skipped = 0;

### =============================
# offsets into REF_LIB_LIST array
our $RLO_MSG = 0;
our $RLO_PRJ = 1;
our $RLO_VAL = 2;
our $RLO_NAM = 3;
our $RLO_EXC = 4;
### =============================
my $dsp_out_dir = '';
my $write_cmake_files = 0;
my $write_dsp_files = 0;
sub get_PATH_SEP() { return $PATH_SEP; }
sub get_pgmname() { return $pgmname; }
sub get_dsp_out_dir() { return $dsp_out_dir; }
sub get_write_cmake_files() { return $write_cmake_files; }
sub get_write_dsp_files() { return $write_dsp_files; }

###########################################################

my %excluded_files = ();
my %excluded_dirs = ();

sub is_excluded_file($) {
    my $fil = shift;
    my $iret = 0;
    if ($os =~ /win/i) {
        my $lcfil = lc($fil);
        my @arr = keys(%excluded_files);
        my ($tst,$lctst);
        foreach $tst (@arr) {
            $lctst = lc($tst);
            if ($lcfil eq $lctst) {
                #prt("Setting EXCLUDED [$fil] [$lcfil]\n");
                $iret = 1;
                last;
            }
        }
    } else {
        $iret = 1 if (defined $excluded_files{$fil});
    }
    #prt("In exclude [$iret]\n") if($fil eq 'DumpTar-scaps.c');
    return $iret;
}

sub is_excluded_dir($) {
    my $fil = shift;
    my $iret = 0;
    if ($os =~ /win/i) {
        my $lcfil = lc($fil);
        my @arr = keys(%excluded_dirs);
        my ($tst,$lctst);
        foreach $tst (@arr) {
            $lctst = lc($tst);
            if ($lcfil eq $lctst) {
                $iret = 1;
                last;
            }
        }
    } else {
        $iret = 1 if (defined $excluded_dirs{$fil});
    }
    return $iret;
}


sub VERB1() { return $verbosity >= 1; }
sub VERB2() { return $verbosity >= 2; }
sub VERB5() { return $verbosity >= 5; }
sub VERB9() { return $verbosity >= 9; }

sub show_warnings($) {
    my ($val) = @_;
    if (@warnings) {
        prt( "\nGot ".scalar @warnings." WARNINGS...\n" );
        foreach my $itm (@warnings) {
           prt("$itm\n");
        }
        prt("\n");
    } else {
        prt( "\nNo warnings issued.\n\n" ) if (VERB9());
    }
}

sub pgm_exit($$) {
    my ($val,$msg) = @_;
    if (length($msg)) {
        $msg .= "\n" if (!($msg =~ /\n$/));
        prt($msg);
    }
    show_warnings($val);
    close_log($outfile,$load_log);
    exit($val);
}


sub prtw($) {
   my ($tx) = shift;
   $tx =~ s/\n$//;
   prt("$tx\n");
   push(@warnings,$tx);
}

sub conv_2_cmake($) {
    my $txt = shift;
    $txt =~ s/\s/_/g;
    $txt =~ s/-/_/g;
    $txt =~ s/__/_/g;
    return $txt;
}

sub process_in_file($) {
    my ($inf) = @_;
    if (! open INF, "<$inf") {
        pgm_exit(1,"ERROR: Unable to open file [$inf]\n"); 
    }
    my @lines = <INF>;
    close INF;
    my $lncnt = scalar @lines;
    prt("Processing $lncnt lines, from [$inf]...\n");
    my ($line,$inc,$lnn);
    $lnn = 0;
    foreach $line (@lines) {
        chomp $line;
        $lnn++;
        if ($line =~ /\s*#\s*include\s+(.+)$/) {
            $inc = $1;
            prt("$lnn: $inc\n");
        }
    }
}

sub get_short_form($$) {
    my ($fil1,$fil2) = @_;
    my $len1 = length($fil1);
    my $len2 = length($fil2);
    if ($len1 > $len2) {
        my ($ch1,$ch2,$i);
        for ($i = 0; $i < $len2; $i++) {
            $ch1 = substr($fil1,$i,1);
            $ch2 = substr($fil2,$i,1);
            last if ($ch1 ne $ch2);
        }
        $fil1 = substr($fil1,$i);
        $fil1 =~ s/^(\\|\/)//;
        #prt("Lengths fil1=$len1 and fil2=$len2 - return $fil1\n");
    } else {
        ##prt("Lengths fil1=$len1 and fil2=$len2\n");
    }
    return $fil1;
}

sub sub_base_dir($) {
    my $fil1 = shift;
    my $fil2 = $in_directory;
    return get_short_form($fil1,$fil2);
}

sub sub_root_folder($) {
    my $fil1 = shift;
    my $fil2 = $in_directory;
    return get_short_form($fil1,$fil2);
}


sub process_in_dir($);
sub process_in_dir($) {
    my $dir = shift;
    if (! opendir(DIR,$dir)) {
        pgm_exit(1,"ERROR: Unable to open directory [$dir]!\n");
    }
    my @files = readdir(DIR);
    closedir(DIR);
    my ($file,$ff,$sf,$excl);
    my @dirs = ();
    ut_fix_directory(\$dir);
    $total_dirs++;
    foreach $file (@files) {
        next if ($file eq '.');
        next if ($file eq '..');
        $ff = $dir.$file;
        if (-d $ff) {
            push(@dirs,$ff) if (!is_excluded_dir($file));
        } else {
            next if (is_excluded_file($file));
            $sf = sub_base_dir($ff);
            # if C/C++ source
            if (is_c_source($file)) {
                $total_c_files++;
                $files_found{$ff} = $TYP_C;
                $c_files_found{$ff} = $sf;
            } elsif (is_h_source($file)) {
                $total_h_files++;
                $h_files_found{$ff} = $sf;
                $files_found{$ff} = $TYP_H;
            } elsif ($file =~ /\.rc$/i) {
                $total_c_files++;
                $files_found{$ff} = $TYP_RC;
                $c_files_found{$ff} = $sf;
            } elsif ($file eq 'Makefile.am') {
                $total_am_files++;
                $am_files_found{$ff} = $TYP_AM;
                $files_found{$ff} = $TYP_AM;
            } else {
                $files_found{$ff} = 0;
            }
        }
    }
    foreach $ff (@dirs) {
        process_in_dir($ff);
    }
}

my %files_by_dir = ();

sub add_options_block($) {
    my $type = shift;
    my $txt = <<EOF;

# Allow developer to select is Dynamic or static library built
set( LIB_TYPE STATIC )  # set default static
option( BUILD_SHARED_LIB "Build Shared Library" $type )
# EXPERIMENTAL - Turn ON to combine library into EXE - above shared library MUST be OFF
option( BUILD_AS_ONE "Build as one. Combine library into EXE" OFF )

EOF
    return $txt;
}

sub get_definitions_block {
    my $txt = <<EOF;

if(CMAKE_COMPILER_IS_GNUCXX)
    set( WARNING_FLAGS -Wall )
endif(CMAKE_COMPILER_IS_GNUCXX)

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang") 
   set( WARNING_FLAGS "-Wall -Wno-overloaded-virtual" )
endif() 

if(WIN32)
    #if(MSVC)
        # turn off various warnings - none needed in this compile
        #set(WARNING_FLAGS "\${WARNING_FLAGS} /wd4996")
        # foreach(warning 4244 4251 4267 4275 4290 4786 4305)
        #     set(WARNING_FLAGS "\${WARNING_FLAGS} /wd\${warning}")
        # endforeach(warning)
        #set( MSVC_FLAGS "-DNOMINMAX -D_USE_MATH_DEFINES -D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS -D__CRT_NONSTDC_NO_WARNINGS" )
        # if (\${MSVC_VERSION} EQUAL 1600)
        #    set( MSVC_LD_FLAGS "/FORCE:MULTIPLE" )
        # endif (\${MSVC_VERSION} EQUAL 1600)
    #endif(MSVC)
    #set( NOMINMAX 1 )
    #if(MINGW)
        # need to specifically handle rc files, like
        # resource compilation for mingw
        #ADD_CUSTOM_COMMAND(OUTPUT \${CMAKE_CURRENT_BINARY_DIR}/test_rc.o
        #                   COMMAND windres.exe -I\${CMAKE_CURRENT_SOURCE_DIR}
        #                                       -i\${CMAKE_CURRENT_SOURCE_DIR}/test.rc
        #                                       -o \${CMAKE_CURRENT_BINARY_DIR}/test_rc.o)
        #SET(test_EXE_SRCS \${test_EXE_SRCS} \${CMAKE_CURRENT_BINARY_DIR}/test_rc.o)
    #else(MINGW)
        #SET(test_EXE_SRCS \${test_EXE_SRCS} test.rc)
    #endif(MINGW)
#else(WIN32)
#    message( FATAL_ERROR "This program can ONLY be compiled in Windows!" )
endif(WIN32)

set( CMAKE_C_FLAGS "\${CMAKE_C_FLAGS} \${WARNING_FLAGS} \${MSVC_FLAGS} -D_REENTRANT" )
set( CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} \${WARNING_FLAGS} \${MSVC_FLAGS} -D_REENTRANT" )
set( CMAKE_EXE_LINKER_FLAGS "\${CMAKE_EXE_LINKER_FLAGS} \${MSVC_LD_FLAGS}" )

add_definitions( -DHAVE_CONFIG_H )

# to distinguish between debug and release lib
set( CMAKE_DEBUG_POSTFIX "d" )

if(BUILD_SHARED_LIB)
   set(LIB_TYPE SHARED)
   message(STATUS "*** Building DLL library \${LIB_TYPE}")
else(BUILD_SHARED_LIB)
   message(STATUS "*** Option BUILD_SHARED_LIB is OFF \${LIB_TYPE}")
endif(BUILD_SHARED_LIB)

EOF
    return $txt;
}

sub get_info_block() {
    my $txt = <<EOF;
# Lots of things to know about...
# MFC app - Need to add -D_AFXDLL -D_WIN32_WINNT=0x0501, and set(CMAKE_MFC_FLAG 2) 2=DLL 1=static
# __declspec(dllexport|dllimport) - Originally switched by VER_INFO_EXPORTS, but have NOT 
# found a way add_definitions(-DVER_INFO_EXPORTS) just for library. Seems remove_definitions(-DVER_INFO_EXPORTS)
# REMOVES it for BOTH - Could separate the makes, but found cmake added 'Versinfo_EXPORTS' for library, so used this
# The DeclSpec.h does have a -DVER_INFO_STATIC for building as a static, and it seems no problem leaving
# the DllMain() module in the compile...
# precompile headers: not found a way to instruct cmake to 'understand' this, so removed stdafx.cpp|h
# RC/RES compile - seems cmake 'know' what to do with the '*.rc' files, but not for MinGW build.
# UNICODE - Seems need to add_definitions( -DUNICODE -D_UNICODE ) for this to be enabled - default is _MSCS (multi-byte)
#

EOF
    return $txt;
}

sub get_cmake_root() {
    my $cmake_root = "\n# CMakeLists.txt, generated $pgmname, on ";
    $cmake_root .= lu_get_YYYYMMDD_hhmmss(time())."\n";
    $cmake_root .= get_info_block();
    $cmake_root .= "cmake_minimum_required( VERSION 2.6 )\n\n";
    $cmake_root .= "project( $proj_title )\n\n";
    $cmake_root .= "# The version number.\n";
    # TODO ***TBD*** This VERSION stuff MUST BE FIXED ONE DAY
    # =======================================================
    $cmake_root .= "set( ${proj_title}_VERSION_MAJOR 3 )\n";
    $cmake_root .= "set( ${proj_title}_VERSION_MINOR 0 )\n";
    $cmake_root .= "set( ${proj_title}_VERSION_POINT 0 )\n\n";
    $cmake_root .= add_options_block("OFF");
    $cmake_root .= get_definitions_block();
    return $cmake_root;
}

sub load_am_file2($$) {
    my ($ff,$rh) = @_;
    if (open FIL,"<$ff") {
        my @lines = <FIL>;
        close FIL;
        my ($line,$len,$lncnt,$i,$i2,$tmp,$cnt,$sf);
        $lncnt = scalar @lines;
        $sf = sub_base_dir($ff);
        prt("Doing $lncnt lines from [$sf] ");
        my @nlines = ();
        for ($i = 0; $i < $lncnt; $i++) {
            $i2 = $i + 1;
            $line = $lines[$i];
            chomp $line;
            $line = trim_all($line);
            $len = length($line);
            next if ($len == 0);
            next if ($line =~ /^\#/);
            while (($line =~ /\\$/)&&($i2 < $lncnt)) {
                $line =~ s/\\$//;
                $line .= ' ' if ($line =~ /\S$/);
                $i++;
                $i2 = $i + 1;
                $tmp = $lines[$i];
                chomp $tmp;
                $tmp = trim_all($tmp);
                next if ($tmp =~ /^\#/);
                $line .= $tmp;
            }
            push(@nlines,$line);
        }
        $cnt = scalar @nlines;
        prt("reduced to $cnt.\n");
        ${$rh}{$ff} = \@nlines;
    }
}

sub load_am_file($$) {
    my ($ff,$rh) = @_;
    my $rparams = init_common_subs($ff); # note: sets ROOT_FOLDER - where a CMakeLists.txt could be written
    ${$rparams}{'AM_FILE'} = $ff;
    am_process_AM_file($rparams,0);
    ${$rh}{$ff} = $rparams; # keep collection of Makefile.am loaded per file name
}

# find 'main' or '_tmain'
sub chk_for_main($) {
    my $fil = shift;
    if (!open FIL,"<$fil") {
        return 0;
    }
    my @lines = <FIL>;
    close FIL;
    my ($line,$i,$ch,$nc,$pc,$incom,$len,$i2);
    $incom = 0;
    $ch = '';
    my $got_main = 0;
    foreach $line (@lines) {
        chomp $line;
        $line = trim_all($line);
        $len = length($line);
        next if ($len == 0);
        for ($i = 0; $i < $len; $i++) {
            $i2 = $i + 1;
            $pc = $ch;
            $ch = substr($line,$i,1);
            $nc = ($i2 < $len) ? substr($line,$i2,1) : '';
            if ($incom) {
                $incom = 0 if (($pc eq '*')&&($ch eq '/'));
            } else {
                if (($ch eq '/') && ($nc eq '*')) {
                    $incom = 1;
                } elsif (($ch eq '/') && ($nc eq '/')) {
                    last; # forget this line
                } elsif ($line =~ /\bmain\b/) {
                    $got_main = 1;
                    prt("$i2 Found 'main' [$line]\n file [$fil]\n");
                    last;
                } elsif ($line =~ /\b_tmain\b/) {
                    $got_main = 1;
                    prt("$i2 Found '_tmain' [$line]\n file [$fil]\n");
                    last;
                } elsif ($line =~ /\bDllMain\b/) {
                    $got_main = 2;
                    prt("$i2 Found 'DllMain' [$line]\n file [$fil]\n");
                    last;
                }
            }
        }
        last if ($got_main);
    }
    return $got_main;
}

sub process_files_found() {
    my $cmake = '';
    my @files = sort keys(%files_found);
    my $cnt = scalar @files;
    prt("From $total_dirs directories scanned, found $cnt files... C/C++=$total_c_files, Hdrs=$total_h_files,am=$total_am_files\n");
    my ($ff,$type,$n,$d,$ra,$i,$name,$dir,$sf,$ccnt,$hcnt,$var1,$var2,$got_main,$gm,$tmp);
    foreach $ff (@files) {
        $sf = path_d2u(sub_base_dir($ff));
        $type = $files_found{$ff};
        ($n,$d) = fileparse($ff);
        $files_by_dir{$d} = [] if (!defined $files_by_dir{$d});
        $ra = $files_by_dir{$d};
        my %h = ();
        $got_main = 0;
        if ($type == $TYP_AM) {
            load_am_file($ff,\%h)
        } elsif ($type == $TYP_C) {
            $got_main = chk_for_main($ff);
            prt("Found 'main' in [$ff] [$sf]\n") if ($got_main);
        }
        #            0  1     2   3   4
        push(@{$ra},[$n,$type,$sf,\%h,$got_main]);
    }
    $cnt = scalar keys(%files_by_dir);
    prt("Sorted into $cnt sub-directories...\n");
    foreach $d (keys %files_by_dir) {
        $ra = $files_by_dir{$d};
        $cnt = scalar @{$ra};
        $d =~ s/(\\|\/)$//;
        ($name,$dir) = fileparse($d);
        my @carr = ();
        my @harr = ();
        my @rcarr = ();
        $got_main = 0;
        for ($i = 0; $i < $cnt; $i++) {
            $n = ${$ra}[$i][0];
            $type = ${$ra}[$i][1];
            $sf = ${$ra}[$i][2];
            #$rh = ${$ra}[$i][3];
            if ($type == $TYP_C) {
                push(@carr,$sf);
            } elsif ($type == $TYP_H) {
                push(@harr,$sf);
            } elsif ($type == $TYP_RC) {
                push(@rcarr,$sf);
            } elsif ($type == $TYP_AM) {
                #$rh = load_am_file(
            }
        }
        $ccnt = scalar @carr;
        $hcnt = scalar @harr;
        if (@carr) {
            $got_main = 0;
            $tmp = 'no main';
            for ($i = 0; $i < $cnt; $i++) {
                $type = ${$ra}[$i][1];
                if ($type == $TYP_C) {
                    $gm = ${$ra}[$i][4];
                    if ($gm & 1) {
                        $tmp = 'GOT MAIN';
                        $got_main = $gm;
                        last;
                    } elsif ($gm & 2) {
                        $tmp = 'GOT DLLMAIN';
                        $got_main = $gm;
                        last;
                    }
                }
            }
            prt("Processing directory [$d] $tmp [$got_main]\n");
            $cmake .= "\n# $name ";
            if ($got_main & 1) {
                $cmake .= "EXECUTABLE";
            } else {
                $cmake .= "LIBRARY";
                if ($got_main & 2) {
                    $cmake .= " SHARED(DLL)";
                }
            }
            $cmake .= " from [$d],\n";
            $cmake .= "# have $ccnt C/C++ sources,";
            if (@rcarr) {
                $cmake .= " ".scalar @rcarr." rc,";
            }
            $cmake .= " $hcnt headers";
            $cmake .= "\n";

            $var1 = "${name}_SRCS";
            $cmake .= "set($var1\n";
            foreach $sf (@carr) {
                $cmake .= "   $sf\n";
            }
            # 20120731 - Add *.rc files to SOURCES!
            foreach $sf (@rcarr) {
                $cmake .= "   $sf\n";
            }
            $cmake =~ s/\n$/ \)\n/;
            $var2 = '';
            if (@harr) {
                $var2 = "${name}_HDRS";
                $cmake .= "set($var2\n";
                foreach $sf (@harr) {
                    $cmake .= "   $sf\n";
                }
                $cmake =~ s/\n$/ \)\n/;
            }
            if ($got_main & 1) {
                prt("Adding EXECUTABLE for [$name]\n");
                $cmake .= "add_executable( $name \${$var1} ";
                $cmake .= "\${$var2} " if (length($var2));
                $cmake .= ")\n";
                $cmake .= "target_link_libraries( $name \${add_LIBS} )\n";
                $cmake .= "set_target_properties( $name PROPERTIES DEBUG_POSTFIX d )\n";

            } else {
                prt("Adding LIBRARY for [$name]\n");
                $cmake .= "add_library( $name ";
                if ($got_main & 2) {
                    $cmake .= "SHARED ";
                }
                $cmake .= "\${$var1} ";
                $cmake .= "\${$var2} " if (length($var2));
                $cmake .= ")\n";
                $cmake .= "list(APPEND add_LIBS $name)\n";
            }
        }
    }
    if (length($cmake)) {
        $var1 = get_cmake_root();
        $cmake = $var1.$cmake."\n\n# eof\n";
        if (length($out_file) == 0) {
            $out_file = $tmp_cmake_list;
            prt("Setting DEFAULT ouput file, since no -o <file> given!\n");
        }
        rename_2_old_bak($out_file);
        write2file($cmake,$out_file);
        prt("CMake string written to [$out_file]\n");

    }
}

#########################################
### MAIN ###
parse_args(@ARGV);
process_in_dir($in_directory);
process_files_found();
pgm_exit(0,"");
########################################

my $in_input = 0;

sub set_excluded_files($) {
    my $arg = shift;
    my @arr = split(';',$arg);
    my ($fil);
    my $cnt = 0;
    foreach $fil (@arr) {
        $excluded_files{$fil} = 1;
        $cnt++;
    }
    prt("Add $cnt files to excluded list\n") if (VERB1());
    if (VERB9()) {
        prt("Excluded file list is [".join(" ",@arr)."]\n");
    }
}
sub set_excluded_dirs($) {
    my $arg = shift;
    my @arr = split(';',$arg);
    my ($fil);
    my $cnt = 0;
    foreach $fil (@arr) {
        $excluded_dirs{$fil} = 1;
        $cnt++;
    }
    prt("Add $cnt directories to excluded list\n") if (VERB1());
    if (VERB9()) {
        prt("Excluded dir list is [".join(" ",@arr)."]\n");
    }
}

sub need_arg {
    my ($arg,@av) = @_;
    pgm_exit(1,"ERROR: [$arg] must have a following argument!\n") if (!@av);
}

sub load_input_file($) {
    my $file = shift;
    if (!open INP, "<$file") {
        pgm_exit(1,"ERROR: Unable to open input file [$file]\n");
    }
    my @lines = <INP>;
    close INP;
    my @lnarr = ();
    my ($line,$len,@arr,$itm);
    my @args = ();
    foreach $line (@lnarr) {
        chomp $line;
        $len = trim_all($line);
        next if ($len == 0);
        next if ($line =~ /^\s*\#/);
        @arr = space_split($line);
        foreach $itm (@arr) {
            last if ($itm =~ /^\#/);    # skip trailing comments
            $itm = strip_quotes($itm);  # strip any quotes
            push(@args,$itm);
        }
    }
    if (@args) {
        $in_input++;
        parse_args(@args);
        $in_input--;
    }
}

sub parse_args {
    my (@av) = @_;
    my ($arg,$sarg);
    while (@av) {
        $arg = $av[0];
        if ($arg =~ /^-/) {
            $sarg = substr($arg,1);
            $sarg = substr($sarg,1) while ($sarg =~ /^-/);
            if (($sarg =~ /^h/i)||($sarg eq '?')) {
                give_help();
                pgm_exit(0,"Help exit(0)");
            } elsif ($sarg =~ /^n/) {
                need_arg(@av);
                shift @av;
                $sarg = $av[0];
                load_input_file($sarg);
            } elsif ($sarg =~ /^v/) {
                if ($sarg =~ /^v.*(\d+)$/) {
                    $verbosity = $1;
                } else {
                    while ($sarg =~ /^v/) {
                        $verbosity++;
                        $sarg = substr($sarg,1);
                    }
                }
                prt("Verbosity = $verbosity\n") if (VERB1());
            } elsif ($sarg =~ /^l/) {
                if ($sarg =~ /^lll/) {
                    $load_log = 3;
                } elsif ($sarg =~ /^ll/) {
                    $load_log = 2;
                } else {
                    $load_log = 1;
                }
                prt("Set to load log at end. ($load_log)\n") if (VERB1());
            } elsif ($sarg =~ /^n/) {
                need_arg(@av);
                shift @av;
                $sarg = $av[0];
                $proj_title = $sarg;
                prt("Set project name to [$proj_title].\n") if (VERB1());
            } elsif ($sarg =~ /^o/) {
                need_arg(@av);
                shift @av;
                $sarg = $av[0];
                $out_file = $sarg;
                prt("Set out file to [$out_file].\n") if (VERB1());
            } elsif ($sarg =~ /^x/) {
                need_arg(@av);
                shift @av;
                $sarg = $av[0];
                set_excluded_files($sarg);
            } elsif ($sarg =~ /^X/) {
                need_arg(@av);
                shift @av;
                $sarg = $av[0];
                set_excluded_dirs($sarg);
            } else {
                pgm_exit(1,"ERROR: Invalid argument [$arg]! Try -?\n");
            }
        } else {
            $in_directory = File::Spec->rel2abs($arg);
            prt("Set input to [$in_directory]\n") if (VERB1());
        }
        shift @av;
    }

    if ($in_input) {
        return;
    }

    if ((length($in_directory) ==  0) && $debug_on) {
        $in_directory = $def_dir;
        prt("Set DEFAULT input to [$in_directory]\n");
        $load_log = 2;
    }
    if ((length($out_file) ==  0) && $debug_on) {
        $out_file = $tmp_cmake_list;
    }

    if (length($in_directory) ==  0) {
        pgm_exit(1,"ERROR: No input files found in command!\n");
    }
    if (! -d $in_directory) {
        pgm_exit(1,"ERROR: Unable to find directory [$in_directory]! Check name, location...\n");
    }
    if (length($proj_title) == 0) {
        my $tmp = $in_directory;
        $tmp =~ s/(\\|\/)$//;
        my ($n,$d) = fileparse($tmp);
        $proj_title = conv_2_cmake($n);
        prt("Set DEFAULT project name to [$proj_title]\n");
    }

    if (length($target_dir) == 0) {
        $target_dir = $in_directory;
        prt("Set DEFAULT target to [$target_dir]\n");
    }
}

sub give_help {
    prt("$pgmname: version $VERS\n");
    prt("Usage: $pgmname [options] in-file\n");
    prt("Options:\n");
    prt(" --help    (-h or -?) = This help, and exit 0.\n");
    prt(" --verb[n]       (-v) = Bump [or set] verbosity. def=$verbosity\n");
    prt(" --load          (-l) = Load LOG at end. ($outfile)\n");
    prt(" --input <file>  (-i) = Take commands from an input (repsonse) file.\n");
    prt(" --name <proj>   (-n) = Set 'project' name, otherwise name of directory will be used.\n");
    prt(" --defs <value>  (-d) = Add definitions to CMakeLists.txt\n");
    prt(" --out <file>    (-o) = Write output to this file. ANy existing file will be renamed old/bak.\n");
    prt(" --xclude <itms> (-x) = Semicolon separated list of files to exclude.\n");
    prt(" --Xclude <dirs> (-X) = Semicolon separated list of directories to exclude.\n");
}

# eof - gencmake.pl
