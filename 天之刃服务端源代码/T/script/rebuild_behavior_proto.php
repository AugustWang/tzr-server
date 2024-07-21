<?php
$curPwd = getcwd();
$appRoot = dirname($curPwd);
$basePath = "{$appRoot}/proto/";
$protoBehavior = "behavior/behavior.proto";

chdir($basePath);
if (!file_exists($protoBehavior)) {
	exit("文件{$protoChat}不存在\r\n");
}

$contentAll = null;
$contenBehavior = file_get_contents($protoBehavior);

$contentAll =  $contenBehavior;

//过滤掉import
$find = 'import "common.proto";';
$contentAll = str_replace($find, '', $contentAll);
$tmpName = "behavior.proto";
@unlink($tmpName);
$fp = fopen($tmpName, "wb");
if (!$fp) {
	print "创建文件{$tmpName}失败！";
	exit(1);
}
fwrite($fp, $contentAll);
fclose($fp);
print "生成临时文件成功\r\n";

echo "正在处理中......[请勿关闭窗口！]\r\n";
//生成beam
exec("erl -pa ../ebin/library/ -noshell -s protobuffs_compile scan_file \"$tmpName\" -s erlang halt", $result);
if (empty($result)) {
	echo "好像成功了！\r\n";
}else {
	print "失败了：".$result[0];
}

@unlink("{$appRoot}/hrl/behavior/behavior_pb.hrl");
rename("behavior_pb.hrl", "{$appRoot}/hrl/behavior/behavior_pb.hrl");

@unlink("{$appRoot}/ebin/behavior/behavior_pb.beam");
rename("behavior_pb.beam", "{$appRoot}/ebin/proto/behavior_pb.beam");
copy("{$appRoot}/ebin/proto/behavior_pb.beam", "/data/tzr/server/ebin/proto/behavior_pb.beam");
@unlink($tmpName);
