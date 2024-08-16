#!/bin/zsh

local BUFFER_DIRECTORY="${HOME}/.cache"
local BUFFER_FILE="${BUFFER_DIRECTORY}/hitokoto.txt"
local URL='https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=e&c=f&c=g&c=h&c=i&c=j&c=k&c=l&encode=text&charset=utf-8&min_length=0&max_length=128'

local function get_hitokoto_text() { curl -sf $URL }

if [[ -r $BUFFER_DIRECTORY && -w $BUFFER_DIRECTORY ]] {
    print "$(<$BUFFER_FILE)"
} else {
    print "$(get_hitokoto_text)"
}

if [[ ! -d $BUFFER_DIRECTORY ]] {
    mkdir -p $BUFFER_DIRECTORY
}

get_hitokoto_text > $BUFFER_FILE &
