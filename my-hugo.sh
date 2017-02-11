#!/usr/bin/bash

subcmd=$1

BLOG_REPO=~/site/go-blog
POST_DIR=$BLOG_REPO/content/post
PUBLIC_REPO=$BLOG_REPO/public

THEME=angels-ladder

function generatePublic()
{
    cd $BLOG_REPO
    hugo -t $THEME
}

function deploy()
{
    generatePublic
    cd $PUBLIC_REPO
    git add --all
    DAY=`date`
    MSG="deploy at $DAY"
    git commit -m "MSG"
    git push origin master
}

function argCheck()
{
    if [ ! -n "$1" ]; then
        echo "Please tyep article title"
        exit 1
    fi
}

function postCheck()
{
    if [ -f "$POST_DIR/$1" ]; then
        return 0
    fi
    return 1
}

function postAdd()
{
    cd $BLOG_REPO
    argCheck $1
    hugo new "post/$1"
}

function undraft()
{
    cd $BLOG_REPO
    argCheck $1
    hugo undraft "post/$1"
}

case "$subcmd" in
    deploy)
        echo "deploy github pages."
        deploy
        ;;
    add)
        postAdd $2
        ;;
    write)
        if ! postCheck $2 ; then
            postAdd $2
        fi
        nvim $POST_DIR/$2
        ;;
    undraft)
        undraft $2
        ;;
    *)
        echo "$subcmd Didn't match anything"
        exit 1
esac
