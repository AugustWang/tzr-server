cd /d %0/..

cd ../config

werl -name mgee_remote@127.0.0.1  -setcookie 123456 -pa ../ebin  -mnesia extra_db_nodes  ["'db@192.168.4.208'"]

##启动之后运行一下语句
##	net_adm:ping('db@192.168.4.208').
##  toolbar:start()  如果想打开toolbar工具
##	mnesia:start()	  如果想打开tv工具
