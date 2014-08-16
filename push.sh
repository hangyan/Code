#!/usr/bin/env bash

### Author : Hang Yan
### Date   : 2014-08-13
### Email  : yanhangyhy@gmail.com
### Desc   : A useful script to do git add / commit / push stuff.

push() {

    git add .
    git commit -am "$1"
    git push origin $2
}



main(){

    local comments="update"
    local branch="master"

    if [[ ! -z "$1" ]];then
        comments=$1
    fi

    if [[ ! -z "$2" ]];then
        branch=$2
    fi

    push "$comments" $branch 
    
}

main "$@"
