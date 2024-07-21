#!/bin/bash
if [ "$1" = '' ] ; then
    echo '请使用语法 ./nodes_montior.sh start -ping_node [Node] -info [挂掉时提示的信息]'
    echo '请使用语法 ./nodes_montior.sh stop'
    exit 1
fi

ACTION=$1
ERLANG_COOKIE=123456
NODE_NAME=nodes_montior@127.0.0.1
PING_NODE=$2
INFO=$3

if [ "$ACTION" = 'start' ] ; then
    erlc nodes_montior.erl
    erlc nodes_montior_server.erl
    /usr/local/bin/erl -noinput -detached -name $NODE_NAME -setcookie $ERLANG_COOKIE -s nodes_montior -ping_node $PING_NODE -info $INFO
    echo '启动服务,操作结束'
elif [ "$ACTION" = 'stop' ] ; then
    erlc nodes_montior.erl
    erlc nodes_montior_server.erl
    /usr/local/bin/erl -noinput -detached -name stop-$NODE_NAME -setcookie $ERLANG_COOKIE -eval "\
        Ping = net_adm:ping('$NODE_NAME'),
        if
            Ping =:= pong ->
                rpc:call('${NODE_NAME}', nodes_montior, stop, []),
                io:format(\"stop succes\");
            true ->
                io:format(\"stop failed,not run\")
        end,
        init:stop().
    "
    echo '关闭服务,操作结束'
else
    echo '参数错误'
    exit 1
fi

exit 0