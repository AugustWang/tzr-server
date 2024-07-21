<?php
if ($_SERVER['argc'] < 2) {
	print "使用语法: php gene_nif_protobuf.php (as3|erlang) \n";
	exit(1);
}
$curPwd = getcwd();
$appRoot = dirname($curPwd);
chdir($appRoot);
$protoChat = "proto/chat.proto";
$protoCommon = "proto/common.proto";
$protoLogin = "proto/login.proto";
$protoGame = "proto/game.proto";
$protoProxy = "proto/proxy.proto";

if (!file_exists($protoChat)) {
    exit("文件{$protoChat}不存在\r\n");
}
if (!file_exists($protoCommon)) {
    exit("文件{$protoCommon}不存在\r\n");
}
if (!file_exists($protoLogin)) {
    exit("文件{$protoLogin}不存在\r\n");
}
if (!file_exists($protoGame)) {
    exit("文件{$protoGame}不存在\r\n");
}
if (!file_exists($protoProxy)) {
    exit("文件{$protoProxy}不存在\r\n");
}


print "正在处理中......[请勿关闭窗口！]\r\n";

define('CL', "\n");

if ($_SERVER['argv'][1] == 'erlang') {
	$contentAll = null;
	$contentCommon = file_get_contents($protoCommon);
	$contentChat = file_get_contents($protoChat);
	$contentLogin = file_get_contents($protoLogin);
	$contentGame = file_get_contents($protoGame);
	$contentProxy = file_get_contents($protoProxy);
	
	$contentAll = $contentCommon .  $contentChat . $contentLogin . $contentGame . $contentProxy;
	    
	//过滤掉import
	$find = 'import "common.proto";';
	$contentAll = str_replace($find, '', $contentAll);
	$contentAll = preg_replace("/(option java_package = )\"(\w+).(\w+)\";/", "", $contentAll);
	$contentAll = preg_replace("/\/\/(.*)?\\\n/","\n",$contentAll);//去掉注释
	$generator = new ProtoNifGenerator($appRoot);
	$codeArray = $generator->geneErlang($contentAll);
	$erlCode = $codeArray[1];
	$hrlCode = $codeArray[0];
	file_put_contents("proto/all_pb.erl", $erlCode);
	file_put_contents("hrl/all_pb.hrl", $hrlCode);
	print "生成all_pb.hrl  all_pb.erl成功 \n";
	print "开始编译all_pb.erl ... ... \n";
	@mkdir('/data/tzr/');
	@mkdir('/data/tzr/server/');
	@mkdir('/data/tzr/server/ebin/');
	@mkdir('/data/tzr/server/ebin/proto/');
	exec("erlc -W -I hrl -o /data/tzr/server/ebin/proto/  proto/all_pb.erl", $result);
	if (empty($result)) {
		@mkdir('/data/mtzr/');
		@mkdir('/data/mtzr/ebin/');
		@mkdir('/data/mtzr/ebin/proto/');
		@copy('/data/tzr/server/ebin/proto/all_pb.beam', '/data/mtzr/ebin/proto/all_pb.beam');
		echo "编译成功！\r\n";
		exit(0);
	} else {
		print "编译失败：".$result[0]."\n";
		exit(1);
	}
} else {
	$as3 = new ProtoNifGenerator($appRoot);
	$as3->geneAs3();
}


print "处理成功\n";
print "=====================================\r\n";
print "文件存放在proto/front-end/目录下\r\n";
print "=====================================\r\n";

function lcfirst2($string) {
    return strtolower($string[0]) . substr($string, 1);
}


class ProtoNifGenerator {

	private $allMessage = array();
	
    private $inTypes = array('double' => 'double', 'float' => 'float', 'int32' => 'PBInt', 'int64' => 'PBInt',
                              'uint32', 'uint64', 'sint32' => 'PBSignedInt', 'sint64' => 'PBSignedInt',
                              'fixed32', 'fixed64', 'sfixed32', 'sfixed64',
                              'bool' => 'PBBool', 'string' => 'PBString', 'bytes' => 'PBString');
    
    /**
     * 用于保存已经生成的erlang的encode函数
     */
    private $erlangEncodes = array();
    
    /**
     * 用于保存已经生成的erlang的decode函数
     */
    private $erlangDecodes = array();
    
    /**
     * 用于保存已经生成的as3的encode函数
     */
    private $as3Encodes = array();
    
    private $as3Decodes = array();
    
    private $erlangCode;
    
    private $asCode;
    
    private $erlEncodeFuncArray = array();
    
    private $erlEncodeRepeatedFuncArray = array();
    
    private $erlDecodeFuncArray = array();
    
    private $erlDecodeRepeatedFuncArray = array();
    
    private $baseDir = null;
    
    
    public function __construct($baseDir)
    {
    	$this->baseDir = $baseDir;
		error_reporting(E_ERROR);
    }
    
    
    //生成函数导出代码
    private function _gene_erlang_encode_export()
    {
    	$code = '-export([' . CL;
    	foreach($this->erlangEncodes as $funcName=>$argc) {
    		$code .= "	{$funcName}/{$argc}," . CL;
    	}		
    	$code = trim($code, ",\n"). CL . "])." . CL;
    	return $code;
    }
    
    
    //生成函数导出代码
    private function _gene_erlang_decode_export()
    {
    	$code = '-export([' . CL;
    	foreach($this->erlangDecodes as $funcName=>$argc) {
    		$code .= "	{$funcName}/{$argc}," . CL;
    	}		
    	$code = trim($code, ",\n"). CL . "])." . CL;
    	return $code;
    }
    
    
    public function geneAs3()
    {
    	$array = array(
	    	array('common.proto', 'common'),
	    	array('chat.proto', 'chat'),
	    	array('login.proto', 'login'),
	    	array('game.proto', 'line'),
	    	array('proxy.proto', 'proxy')
    	);
    	foreach ($array as $proto) {
    		$fileName = $proto[0];
    		$packageName = $proto[1];
    		$this->_gene_as3_code_files($fileName, $packageName);
    		
    	}
    }
    
    
    private function _gene_as3_code_files($file, $packageName) {
    	$string = file_get_contents($this->baseDir."/proto/".$file);
		$contentAll = str_replace('import "common.proto";', '', $string);
		$contentAll = preg_replace("/(option java_package = )\"(\w+).(\w+)\";/", "", $contentAll);
		$contentAll = preg_replace("/\/\/(.*)?\\\n/","\n",$contentAll);//去掉注释
    	$pb = new ProtoParse();
        $allMessage = $pb->parse($contentAll);	
        
		mkdir($this->baseDir."/proto/front-end");
		mkdir($this->baseDir."/proto/front-end/".$packageName);
        foreach ($allMessage as $m) {
        	$code .= $this->_gene_as3_code($m, $packageName);
        }
        return true;
    }
    
    private $classPackageMap = array();
    
    private function _get_as3_class_method($className) {
    	return substr(substr($className, 0, strlen($className) - 4), 2);
    }
    
    private function _gene_as3_code(ProtoMessage $message, $packageName) {
    	$className = $message->getName();
    	$this->classPackageMap[$className] = $packageName;
    	$head = "package proto.{$packageName} {" . CL;
    	$code .= "	import flash.net.registerClassAlias;" . CL;
    	$code .= "	import com.Message;" . CL;
    	$code .= "	import flash.utils.ByteArray;" . CL;
    	$code .= "	public class {$className} extends Message" . CL;
    	$code .= "	{" . CL;
    	
    	$code .= $this->_gene_as3_property($message);
    	
    	$encode = $this->_gene_as3_encode_code($message);
    	
    	$code .= "		public function $className() {" . CL;
    	$code .= "			super();" . CL;
    	$code .= $this->tmpAs3ConstructCode . CL;
    	$code .= "			flash.net.registerClassAlias(\"copy.proto.{$packageName}.$className\", $className);" . CL;
    	$code .= "		}" . CL;
    	
    	$code .= "		public override function getMethodName():String {" . CL;
    	$code .= "			return '".$this->_get_as3_class_method($className)."';" . CL;
    	$code .= "		}" . CL;
    	
    	$code .= "		public override function writeToDataOutput(output:ByteArray):void {" . CL;
    	$code .= $encode;
    	$code .= "		}" . CL;
    	$code .= "		public override function readFromDataOutput(input:ByteArray):void {" . CL;
    	$code .= $this->_gene_as3_decode_code($message);
    	$code .= "		}" . CL;
    	$code .= "	}" . CL;
    	$code .= "}" . CL;
    	
    	$import = '';
    	foreach ($this->as3RefClass as $refClass) {
    		$p = $this->classPackageMap[$refClass];
    		if ($p != '' && $p != NULL) {
    			$import .= "	import proto.{$p}.{$refClass};" . CL;
    		}
    	}
    	
    	$this->as3RefClass = array();
    	
    	$code = $head . $import . $code;
    	
    	$file = $this->baseDir."/proto/front-end/".$packageName."/$className.as";
    	file_put_contents($file, $code);
    	
    	return $code;
    }
    
    private function _gene_as3_property(ProtoMessage $m) {
    	$fields = $m->getFields();
    	foreach($fields as $field) {
    		$name = $field->name;
    		$type = $field->type;
    		$dataType = $field->dataType;
    		$default = $field->default;
    		if ($type == 'repeated') {
    			$code .= "		public var $name:Array = new Array;" . CL;
    		} else {
	    		if ($dataType == 'int32') {
	    			if (is_null($default)) {
	    				$default = 0;
	    			}
	    			$dataType = 'int';
	    		} else if ($dataType == "double") {
	    			if (is_null($default)) {
	    				$default = 0.0;
	    			}
	    			$dataType = 'Number';
	    		} else if ($dataType == 'string') {
	    			if (is_null($default)) {
	    				$default = '""';
	    			}
	    			$dataType = 'String';
	    		} else if ($dataType == 'bool') {
	    			if (is_null($default)) {
	    				$default = 'true';
	    			}
	    			$dataType = 'Boolean';
				} else if ($dataType == 'bytes') {
					// 特殊处理bytes类型的数据
					$dataType = 'ByteArray';
					$default = 'null';
	    		} else {
	    			if (is_null($default)) {
	    				$default = 'null';
	    			}
	    		}
	    		
	    		$code .= "		public var $name:$dataType = $default;" . CL;
    		}
    	}
    	return $code;
    }
    
    private $as3RefClass = array();
    
    private $tmpAs3ConstructCode = null;
    
    
    private function _gene_as3_encode_code(ProtoMessage $message) {
    	$this->tmpAs3ConstructCode = null;
    	$fields = $message->getFields();
    	$prefix = "			";
    	$code = NULL;
    	
    	$declare = false;
    	foreach ($fields as $field) {
    		$type = $field->type;
    		$dataType = $field->dataType;
    		$name = $field->name;
    		
    		if ($type == 'repeated') {
    			$declare = true;
    			$code .= $prefix."var size_$name:int = this.{$name}.length;" . CL;
    			$code .= $prefix."output.writeShort(size_$name);" . CL;
    			$code .= $prefix."var temp_repeated_byte_$name:ByteArray= new ByteArray;" . CL;
    			if ($dataType == 'int32') {
    				$code .= $prefix."for(i=0; i<size_$name; i++) {" . CL;
    				$code .= $prefix."	temp_repeated_byte_$name.writeInt(this.{$name}[i]);" . CL;
    				$code .= $prefix."}" . CL;
    			} else if ($dataType == 'bool') {
    				$code .= $prefix."for(i=0; i<size_$name; i++) {" . CL;
    				$code .= $prefix."	temp_repeated_byte_$name.writeBoolean(this.{$name}[i]);" . CL;
    				$code .= $prefix."}" . CL;
    			} else if ($dataType == 'double') {
    				$code .= $prefix."for(i=0; i<size_$name; i++) {" . CL;
    				$code .= $prefix."	temp_repeated_byte_$name.writeDouble(this.{$name}[i]);" . CL;
    				$code .= $prefix."}" . CL;
    			} else if ($dataType == 'string') {
    				$code .= $prefix."for(i=0; i<size_$name; i++) {" . CL;
    				$code .= $prefix."	if (this.$name != null) {";
    				$code .= $prefix."		temp_repeated_byte_$name.writeUTF(this.{$name}[i].toString());" . CL;
    				$code .= $prefix."	} else {" . CL;
    				$code .= $prefix."		temp_repeated_byte_$name.writeUTF(\"\");" . CL;
    				$code .= $prefix."	}" . CL;
    				$code .= $prefix."}" . CL;
    			} else {
    				$this->as3RefClass[] = $dataType;
    				
    				$code .= $prefix."for(i=0; i<size_$name; i++) {" . CL;
    				$code .= $prefix."	var t2_$name:ByteArray = new ByteArray;" . CL;
    				$code .= $prefix."	var tVo_$name:$dataType = this.{$name}[i] as $dataType;" . CL;
    				$code .= $prefix."	tVo_$name.writeToDataOutput(t2_$name);" . CL;
    				$code .= $prefix."	var len_tVo_$name:int = t2_$name.length;" . CL;
    				$code .= $prefix."	temp_repeated_byte_$name.writeInt(len_tVo_$name);" . CL;
    				$code .= $prefix."	temp_repeated_byte_$name.writeBytes(t2_$name);" . CL;
    				$code .= $prefix."}" . CL;
    			}
    			$code .= $prefix."output.writeInt(temp_repeated_byte_{$name}.length);". CL;
    			$code .= $prefix."output.writeBytes(temp_repeated_byte_{$name});" . CL;
    		} else {
    			if ($dataType == 'int32') {
    				$code .= $prefix."output.writeInt(this.{$name});" . CL;
    			} else if ($dataType == 'bool') {
    				$code .= $prefix."output.writeBoolean(this.{$name});" . CL;
    			} else if ($dataType == 'double') {
    				$code .= $prefix."output.writeDouble(this.{$name});" . CL;
    			} else if ($dataType == 'string') {
    				$code .= $prefix."if (this.$name != null) {";
    				$code .= $prefix."	output.writeUTF(this.{$name}.toString());" . CL;
    				$code .= $prefix."} else {" . CL;
    				$code .= $prefix."	output.writeUTF(\"\");" . CL;
    				$code .= $prefix."}" . CL;
				} else if ($dataType == 'ByteArray') {
					$code .= $prefix."output.writeBytes(this.{$name});" . CL;
    			} else {
    				$this->tmpAs3ConstructCode .= $prefix."this.{$name} = new {$dataType};" . CL;
    				$this->as3RefClass[] = $dataType;
    				$code .= $prefix."var tmp_{$name}:ByteArray = new ByteArray;" . CL;
    				$code .= $prefix."this.{$name}.writeToDataOutput(tmp_{$name});" . CL;
    				$code .= $prefix."var size_tmp_{$name}:int = tmp_{$name}.length;" . CL;
    				$code .= $prefix."output.writeInt(size_tmp_{$name});" . CL;
    				$code .= $prefix."output.writeBytes(tmp_{$name});" . CL;
    			}
    		}
    	}	
    	
    	if ($declare = true) {
    		$code = $prefix."var i:int;" . CL . $code;
    	}
    	
    	return $code;
    }
    
    
    /**
     * 生成解码函数
     */
    private function _gene_as3_decode_code(ProtoMessage $message) {
    	$fields = $message->getFields();
    	$code = null;
    	
    	$declare = false;
    	foreach ($fields as $field) {
    		$type = $field->type;
    		$dataType = $field->dataType;
    		$name = $field->name;
	    			
    		if ($type == 'repeated') {
    			$declare = true;
    			//数组长度    byte长度  byte
    			$code .= "			var size_{$name}:int = input.readShort();" . CL;
    			$code .= "			var length_{$name}:int = input.readInt();" . CL;
    			
    			if ($dataType == 'int32') {
    				$code .= "			var byte_{$name}:ByteArray = new ByteArray; ". CL ;
    				$code .= "			if (size_{$name} > 0) {" . CL;
	    			$code .= "				input.readBytes(byte_{$name}, 0, size_{$name} * 4);" . CL;
    				$code .= "				for(i=0; i<size_{$name}; i++) {" . CL;
    				$code .= "					var tmp_{$name}:int = byte_{$name}.readInt();" . CL;
    				$code .= "					this.$name.push(tmp_{$name});" . CL;
	    			$code .= "				}" . CL;
	    			$code .= "			}" . CL;
    			} else if ($dataType == 'double') {
    				$code .= "			var byte_{$name}:ByteArray = new ByteArray; ". CL ;
    				$code .= "			if (size_{$name} > 0) {" . CL;
	    			$code .= "				input.readBytes(byte_{$name}, 0, size_{$name} * 8);" . CL;
    				$code .= "				for(i=0; i<size_{$name}; i++) {" . CL;
    				$code .= "					var tmp_{$name}:Number = byte_{$name}.readDouble();";
    				$code .= "					this.$name.push(tmp_{$name});" . CL;
	    			$code .= "				}" . CL;
	    			$code .= "			}" . CL;
    			} else if ($dataType == 'bool') {
    				$code .= "			var byte_{$name}:ByteArray = new ByteArray; ". CL;
    				$code .= "			if (size_{$name} > 0) {" . CL;
	    			$code .= "				input.readBytes(byte_{$name}, 0, size_{$name});" . CL;
    				$code .= "				for(i=0; i<size_{$name}; i++) {" . CL;
    				$code .= "					var tmp_{$name}:Boolean = byte_{$name}.readBoolean();";
    				$code .= "					this.$name.push(tmp_{$name});" . CL;
	    			$code .= "				}" . CL;
	    			$code .= "			}" . CL;
    			} else if ($dataType == 'string') {
    				$code .= "			if (size_{$name}>0) {" . CL;
	    			$code .= "				var byte_{$name}:ByteArray = new ByteArray; ". CL 
	    					."				input.readBytes(byte_{$name}, 0, length_{$name});" . CL;
	    			$code .= "				for(i=0; i<size_{$name}; i++) {" . CL;
	    			$code .= "					var tmp_$name:String = byte_{$name}.readUTF(); " . CL;
	    			$code .= "					this.$name.push(tmp_$name);" . CL;
	    			$code .= "				}" . CL;
	    			$code .= "			}". CL;
    			} else {
	    			$code .= "			if (length_{$name} > 0) {" . CL;
	    			$code .= "				var byte_{$name}:ByteArray = new ByteArray; ". CL;
	    			$code .= "				input.readBytes(byte_{$name}, 0, length_{$name});" . CL;
	    			$code .= "				for(i=0; i<size_{$name}; i++) {" . CL;
	    			$code .= "					var tmp_{$name}:{$dataType} = new {$dataType};" . CL;
	    			$code .= "					var tmp_{$name}_length:int = byte_{$name}.readInt();" . CL;
	    			$code .= "					var tmp_{$name}_byte:ByteArray = new ByteArray;" . CL;
	    			$code .= "					byte_{$name}.readBytes(tmp_{$name}_byte, 0, tmp_{$name}_length);" .CL;
	    			$code .= "					tmp_$name.readFromDataOutput(tmp_{$name}_byte);" . CL;
	    			$code .= "					this.$name.push(tmp_{$name});" . CL;
	    			$code .= "				}" . CL;
	    			$code .= "			}" . CL;
    			}
    			
    		} else {
	    		if ($dataType == 'bool') {
	    			$code .= "			this.$name = input.readBoolean();" . CL;
	    		} else if ($dataType == 'int32') {
	    			$code .= "			this.$name = input.readInt();" . CL;
	    		} else if ($dataType == 'string') {
	    			$strLenVName = "{$name}_str_len";
	    			$code .= "			this.$name = input.readUTF();" . CL;
	    		} else if ($dataType == 'double') {
	    			$code .= "			this.$name = input.readDouble();" . CL;
				} else if ($dataType == 'bytes') {
					$code .= "			this.$name = input.readBytes();" . CL;
	    		} else {
	    			//复杂结构
	    			$code .= "			var byte_{$name}_size:int = input.readInt();" . CL;
	    			$code .= "			if (byte_{$name}_size > 0) {";
	    			$code .= "				this.$name = new {$dataType};" . CL;
	    			$code .= "				var byte_{$name}:ByteArray = new ByteArray;" . CL;
	    			$code .= "				input.readBytes(byte_{$name}, 0, byte_{$name}_size);" . CL;
	    			$code .= "				this.$name.readFromDataOutput(byte_{$name});" . CL;
	    			$code .= "			}" . CL;
	    		}
    		}
    		
    	}
    	
    	if ($declare = true) {
    		$code = "			var i:int;" . CL . $code;
    	}
    	
    	return $code;
    }
    
    
    /**
     * 从字符串开始分析proto并生成代码
     */
    public function geneErlang($string) {
        $pb = new ProtoParse();
        $allMessage = $pb->parse($string);
        $this->allMessage = $allMessage;
        foreach($allMessage as $m) {
            $this->erlangCode .= $this->_gene_erlang_code($m);
        }
        
        //循环生成所有的二级结构的编码函数
        while(sizeof($this->erlEncodeFuncArray) > 0  
        	|| sizeof($this->erlDecodeFuncArray) > 0) {
        	$erlEncodeFuncArray = $this->erlEncodeFuncArray;
        	$this->erlEncodeFuncArray = array();
        	//生成所有复杂结构体的编码函数
        	foreach($erlEncodeFuncArray as $k=>$v) {
     			if (array_key_exists($k, $this->inTypes)) {
     				continue;
     			} else {
     				$m = $this->allMessage[$k];   	
     				$this->erlangCode .= $this->_gene_erlang_encode_code($m);
     			}
        	}
        	
        	$erlDecodeFuncArray = $this->erlDecodeFuncArray;
        	$this->erlDecodeFuncArray = array();
	        foreach($erlDecodeFuncArray as $k=>$v) {
	        	if (array_key_exists($k, $this->inTypes)) {
     				continue;
     			} else {
     				$m = $this->allMessage[$k];   	
     				$this->erlangCode .= $this->_gene_erlang_decode_code($m);
     			}
	        }
        }
        
        while (sizeof($this->erlEncodeRepeatedFuncArray) > 0 ||
        	sizeof($this->erlDecodeRepeatedFuncArray)> 0) {
        	$erlEncodeRepeatedFuncArray = $this->erlEncodeRepeatedFuncArray;
        	$this->erlEncodeRepeatedFuncArray = array();
        	foreach($erlEncodeRepeatedFuncArray as $k=>$v) {
        		if (array_key_exists($k, $this->inTypes)) {
        			continue;
        		} else {
        			$m = $this->allMessage[$k];
        			$this->erlangCode .= $this->_gene_erlang_encode_repeated_code($m);
        		}
        	}
        	
        	$erlDecodeRepeatedFuncArray = $this->erlDecodeRepeatedFuncArray;
        	$this->erlDecodeRepeatedFuncArray = array();
        	foreach($erlDecodeRepeatedFuncArray as $k=>$v) {
        		if (array_key_exists($k, $this->inTypes)) {
        			continue;
        		} else {
        			$m = $this->allMessage[$k];
        			$this->erlangCode .= $this->_gene_erlang_decode_repeated_code($m);
        		}
        	}
        }
        
        $code = "-module(all_pb)." . CL;
        $code .= "-include(\"all_pb.hrl\")." . CL;
        
        $code .= $this->_gene_erlang_encode_export() . $this->_gene_erlang_decode_export();
        
        $code .= "-export([" . CL;
        $code .= "	encode_int32s/2," . CL;
        $code .= "	encode_doubles/2," . CL;
        $code .= "	encode_bools/2," . CL;
        $code .= "	encode_strings/2" . CL;
        $code .= "])." . CL . CL;
        
        $code .= "-export([" . CL;
        $code .= "	decode_int32s/2," . CL;
        $code .= "	decode_doubles/2," . CL;
        $code .= "	decode_bools/2," . CL;
        $code .= "	decode_strings/2" . CL;
        $code .= "])." . CL . CL;
        
        $code .= $this->_gene_intype_encode_repeated_code();
        $code .= $this->_gene_intype_decode_repeated_code();
        
        //生成hrl文件
        $hrlCode = $this->_gene_erlang_hrl();
        
        $erlCode = $code . $this->erlangCode;
        
        return array($hrlCode, $erlCode);
    }
    
    private function _gene_erlang_hrl() {
    	$code = null;
    	foreach ($this->allMessage as $m) {
    		$recordName = $m->getName();
    		$fields = $m->getFields();
    		$rCode = "-record($recordName, {";
    		foreach($fields as $field) {
    			$default = $field->default;
    			if ($default != NULL && $default != '') {
    				$rCode .= "{$field->name}=$default,";
    			} else {
    				$rCode .= "{$field->name},";
    			}
    			
    		}
    		$code .= trim($rCode, ",")."})." . CL;
    	}
    	return $code;
    }
    
    /**
     * 生成内置类型的repeated类型编码函数
     */
    private function _gene_intype_encode_repeated_code()
    {
    	$code = '';
    	$code .= "encode_int32s([], Bin) ->" . CL;
    	$code .= "	Bin;" . CL;
    	$code .= "encode_int32s([H|T], Bin) ->" . CL;
    	$code .= "	encode_int32s(T, <<Bin/binary, H:32/signed>>)." . CL . CL;
    	
    	$code .= "encode_doubles([], Bin) ->" . CL;
    	$code .= "	Bin;" .  CL;
    	$code .= "encode_doubles([H|T], Bin) ->" . CL;
    	$code .= "	encode_doubles(T, <<Bin/binary, H/float>>)." . CL . CL;
    	
    	$code .= "encode_strings([], Bin) ->" . CL;
    	$code .= "	Bin;" .  CL;
    	$code .= "encode_strings([H|T], Bin) ->" . CL;
    	$code .= "	Str = common_tool:to_binary(H)," . CL;
    	$code .= "	StrLen = erlang:byte_size(Str)," . CL;
    	$code .= "	encode_strings(T, <<Bin/binary, StrLen:16, Str/binary>>)." . CL . CL;
    	
    	$code .= "encode_bools([], Bin) ->" . CL;
    	$code .= "	Bin;" . CL;
    	$code .= "encode_bools([H|T], Bin) ->" . CL;
    	$code .= "	case H  of" . CL;
    	$code .= "	true ->" . CL;
    	$code .= "		B = 1;" . CL;
    	$code .= "	false ->" . CL;
    	$code .= "		B = 0" . CL;
    	$code .= "	end," . CL;
    	$code .= "	encode_bools(T, <<Bin/binary, B:8>>)." . CL . CL;
    	
    	return $code;
    }
    
    private function _gene_intype_decode_repeated_code() {
    	$code = '';
    	$code .= "decode_int32s(<<>>, List) ->" . CL;
    	$code .= "	List;" . CL;
    	$code .= "decode_int32s(Bin, List) ->" . CL;
    	$code .= "	<<Int:32/signed, Bin2/binary>> = Bin," . CL;
    	$code .= "	decode_int32s(Bin2, [Int|List])." . CL;
    	
    	$code .= "decode_doubles(<<>>, List) ->" . CL;
    	$code .= "	List;" . CL;
    	$code .= "decode_doubles(Bin, List) ->" . CL;
    	$code .= "	<<Double/float, Bin2/binary>> = Bin," . CL;
    	$code .= "	decode_doubles(Bin2, [Double|List])." . CL;
    	
    	$code .= "decode_strings(<<>>, List) ->" . CL;
    	$code .= "	List;" . CL;
    	$code .= "decode_strings(Bin, List) ->" . CL;
    	$code .= "	<<Len:16, Bin2/binary>> = Bin," . CL;
    	$code .= "	<<Str:Len/binary, Bin3/binary>> = Bin2," . CL;
    	$code .= "	decode_strings(Bin3, [common_tool:to_list(Str)|List])." . CL;
    	
    	$code .= "decode_bools(<<>>, List) ->" . CL;
    	$code .= "	List;" . CL;
    	$code .= "decode_bools(Bin, List) ->" . CL;
    	$code .= "	<<Int:8, Bin2/binary>> = Bin," . CL;
    	$code .= "	case Int of ". CL;
    	$code .= "		1 ->". CL;
    	$code .= "			Bool = true;". CL;
    	$code .= "		_ ->";
    	$code .= "			Bool = false". CL;
    	$code .= "	end,". CL;
    	$code .= "	decode_bools(Bin2, [Bool|List])." . CL;
    	
    	return $code;
    }
    
    
    /**
     * 生成消息对应的erlang部分代码
     */
    private function _gene_erlang_code(ProtoMessage $m) {
    	$code = $this->_gene_erlang_encode_code($m);
    	$code .= $this->_gene_erlang_decode_code($m);
    	return $code;
    }
    
    
    private function _gene_erlang_encode_code(ProtoMessage $m) {
    	$code = '';
    	//消息名称
        $messageName = $m->getName();
        $fields = $m->getFields();
        $funcName = "encode_".$messageName;
        //避免重复生成
        if (isset($this->erlangEncodes[$funcName])){
        	return null;
        }
        $this->erlangEncodes[$funcName] = 1;
        $code .= $funcName."(Record) when is_record(Record, $messageName) ->" . CL;
   	 	//生成record赋值语句
        $code .= "	#{$messageName}{";
        foreach($fields as $field) {
        	$name = $field->name;
        	$vName = ucfirst($name);
        	$code .= "$name=$vName,";
        }
        $code = rtrim($code, ",");
        $code .= "} = Record," . CL;
        
        $declareCode = "";
        $assignCode = "	<<";
        
        //编码每一个字段
        foreach($fields as $field) {
    		$name = $field->name;
        	$vName = ucfirst($name);
        	$vNameFinal = $vName."Final";
    		$type = $field->type;
    		$dataType = $field->dataType;
    		$default = ($field->default !== null) ? ($field->default) : 'undefined';
    		
    		//判断传入的record是否合法，是否需要使用默认值
    		if ($type == 'required') {
    			$code .= "	case $vName =:= undefined of" . CL;
	    		$code .= "		true ->". CL;
	    		
	    		if ($default == 'undefined') {
	    			$code .= "				$vNameFinal = undefined," . CL;
	    			$code .= "				exit({required_field_not_assigned, $messageName, $name});". CL;
	    		} else {
	    			if ($dataType == 'bool') {
		    			if ($default == 'true') {
		    				$default = 1;
		    			} else {
		    				$default = 0;
		    			}
	    			}
	    			
	    			$code .= "				$vNameFinal = $default;". CL;
	    		}
	    		
	    		$code .= "		false ->". CL;
	    		//bool类型使用一个位来存储 0 为false 1 为true
	    		if ($dataType == 'bool') {
	    			$code .= "		case $vName of". CL;
	    			$code .= "			true ->". CL;
	    			$code .= "				$vNameFinal = 1;". CL;
	    			$code .= "			false ->". CL;
	    			$code .= "				$vNameFinal = 0". CL;
	    			$code .= "		end". CL;
	    		} else {
	    			$code .= "			$vNameFinal = $vName". CL;
	    		}
	    		
	    		$code .= "	end,". CL;
    		} else if ($type == 'optional') {
    			$code .= "	case $vName =:= undefined of" . CL;
	    		$code .= "		true ->". CL;
	    		if ($default == 'undefined') {
	    			if ($dataType == 'int32') {
	    				$code .= "				$vNameFinal = 0;". CL;	
	    			} else if ($dataType == 'double' || $dataType == 'float') {
	    				$code .= "				$vNameFinal = 0.0;". CL;	
	    			} else if ($dataType == 'string') {
	    				$code .= "				$vNameFinal = <<>>;". CL;
	    			} else if ($dataType == 'bool') {
	    				//默认的bool类型值为true(1)
	    				$code .= "				$vNameFinal = 1;". CL;
	    			} else {
	    				//用0表示空message
	    				$code .= "				$vNameFinal = 0;". CL;
	    				$nullMessage = true;
	    			}
	    		} else {
	    			if ($dataType == 'bool') {
	    				if ($default == 'true') {
	    					$default = 1;
	    				} else {
	    					$default = 0;
	    				}
	    			}
	    			$code .= "				$vNameFinal = $default;". CL;
	    		}
	    		$code .= "		false ->". CL;
	    		if ($dataType == 'bool') {
	    			$code .= "			case $vName of". CL;
	    			$code .= "				true ->". CL;
	    			$code .= "					$vNameFinal = 1;". CL;
	    			$code .= "				false ->". CL;
	    			$code .= "					$vNameFinal = 0". CL;
	    			$code .= "			end". CL;
	    		} else {
	    			$code .= "			$vNameFinal = $vName". CL;
	    		}
	    		
	    		$code .= "	end,". CL;
    		} else {
    			//repeated类型需要特殊对待
    			//repeated 类型编码规则     数组长度  数据长度(性能优化) 数据
    			$code .= "	case $vName =:= undefined of" . CL;
	    		$code .= "		true ->". CL;
	    		if ($default == 'undefined') {
		    		$code .= "			$vNameFinal = [];". CL;
	    		} else {
	    			$code .= "			$vNameFinal = $default;". CL;
	    		}
	    		$code .= "		false ->". CL;
	    		$code .= "			$vNameFinal = $vName". CL;
	    		$code .= "	end,". CL;
    		}
    		
    		if ($type == 'repeated') {
    			$repeatedVName = ucfirst($vName."_bin");
    			$funcName = "encode_{$dataType}s";
    			$declareCode .= "	$repeatedVName = {$funcName}($vNameFinal, <<>>)," . CL;
    			$this->erlEncodeRepeatedFuncArray[$dataType] = $funcName;
    			//填充数组大小，两个字节表示
    			$sizeVName = "Size{$vNameFinal}";
    			$declareCode .= "	$sizeVName = erlang:length($vNameFinal)," . CL;
    			$declareCode .= "	BinLen_$name = erlang:byte_size($repeatedVName)," . CL;
    			$assignCode .= "$sizeVName:16, BinLen_$name:32, $repeatedVName/binary,";
    		} else {
	    		if ($dataType == 'int32') {
	    			$assignCode .= "$vNameFinal:32/signed,";
	    		} else if ($dataType == 'double' || $dataType == 'float') {
	    			$assignCode .= "$vNameFinal:64/float,";
	    		} else if ($dataType == 'string') {
	    			$declareCode .= "	{$vName}2 = common_tool:to_binary({$vNameFinal})," . CL;
	    			$declareCode .= "	{$vName}Len = erlang:byte_size({$vName}2)," . CL;
	    			//字符串的长度用两个字节表示
	    			$assignCode .= "{$vName}Len:16, {$vName}2/binary,";
	    		} else if ($dataType == 'bool') {
	    			$assignCode .= "$vNameFinal:8,";
				} else if ($dataType == 'bytes') {
					$assignCode .= "$vNameFinal/binary,";
	    		} else {
	    			//自定义类型
	    			$subMessage = $this->allMessage[$dataType];
	    			if (isset($subMessage) && $subMessage !== NULL) {
	    				$binVName = ucfirst ( "{$vName}_bin" );
						$funcName = "encode_" . $dataType;
						$declareCode .= "	$binVName = {$funcName}($vNameFinal)," . CL;
						$declareCode .= "	BinLen_$name = erlang:byte_size($binVName)," . CL;
						if (!array_key_exists($dataType, $this->inTypes)) {
							$this->erlEncodeFuncArray[$dataType] = $funcName;
						}
						//复杂结构体:   bin长度  ,  bin
						$assignCode .= "BinLen_$name:32, $binVName/binary,";
	    			} else {
	    				throw new Exception("未知的数据类型：".$dataType);
	    			}
	    		}
    		}
        }
        
        $assignCode = rtrim($assignCode, ",").">>;";
        
        $code .= $declareCode . CL . $assignCode . CL ;
        
        $code .= "encode_{$messageName}(_) -> ". CL;
        $code .= "	<<>>." . CL . CL;
        
        return $code;
    }
    
    
    private function _gene_erlang_encode_repeated_code(ProtoMessage $message) {
    	$code = '';
    	$name = $message->getName();
    	$funcName = "encode_{$name}s";
    	//避免重复生成
        if (isset($this->erlangEncodes[$funcName])){
        	return null;
        }
        $this->erlangEncodes[$funcName] = 2;
    	
		$code .= "$funcName([], Bin) ->" . CL;
		$code .= "	Bin;" . CL;
		$code .= "$funcName([H|T], Bin) ->" . CL;
		$code .= "	NewBin = encode_{$name}(H)," . CL;
		$code .= " 	NewBinSize = erlang:byte_size(NewBin)," . CL;
		$code .= "	$funcName(T, <<Bin/binary, NewBinSize:32, NewBin/binary>>)." . CL;   	
		return $code;
    }
    
    
    /**
     * 生成解码代码
     * @return string
     */
    private function _gene_erlang_decode_code(ProtoMessage $m)
    {
    	$messageName = $m->getName();
    	$fields = $m->getFields();
    	$funcName = "decode_{$messageName}";
    	if (isset($this->erlangDecodes[$funcName])){
        	return null;
        }
        $this->erlangDecodes[$funcName] = 1;
        
        $code = "$funcName(Bin0) when erlang:is_binary(Bin0) andalso erlang:byte_size(Bin0) > 0 ->" . CL;
        $code .= '	<<';
    	$i = 0;
    	$sizeOfField = sizeof($fields);
    	
    	$constructCode = '	{'."$messageName, ";
    	$ifBreak = false; 
    	$assignCode = null;
    	
    	$k = 1;
    	foreach($fields as $field) {
    		$type = $field->type;
    		$dataType = $field->dataType;
    		$name = $field->name;
    		$vName = ucfirst($name);
    		if ($type == 'repeated') {
    			
    			$sizeVName = "Size{$name}";
    			$lenVName = "BinLen{$name}";
    			$subBinVName = "SubBin".$name;
    			
    			if ($k == $sizeOfField) {
	    			if ($ifBreak) {
	    				$code .= "	<<_{$sizeVName}:16, _$lenVName:32, $subBinVName/binary>> = Bin".$i."," . CL;
	    			} else {
	    				$code .= "_{$sizeVName}:16, _$lenVName:32, $subBinVName/binary>> = Bin".$i."," . CL;
	    			}
    			} else {
    				$j = $i+1;
    				if ($ifBreak) {
	    				$code .= "	<<_{$sizeVName}:16, $lenVName:32, Bin{$j}/binary>> = Bin".$i."," . CL;
	    			} else {
	    				$code .= "_{$sizeVName}:16, $lenVName:32, Bin{$j}/binary>> = Bin".$i."," . CL;
	    			}
	    			$i++;
	    			$j = $i+1;
    				$code .= "	<<$subBinVName:$lenVName/binary, Bin{$j}/binary>> = Bin".($j-1).", " . CL;
    				$i++;
    			}
    			
    			$code .= "	$vName = lists:reverse(decode_{$dataType}s($subBinVName, []))," . CL;
    			$this->erlDecodeRepeatedFuncArray[$dataType] = 2;
    			$ifBreak = true;
    			
    		} else {
	    		if ($dataType == 'int32') {
	    			if ($ifBreak) {
	    				$code .= "	<<$vName:32/signed,";
	    				$ifBreak = false;
	    			} else {
	    				$code .= "$vName:32/signed,";
	    			}
	    		} else if ($dataType == 'double' || $dataType == 'float') {
	    			if ($ifBreak) {
	    				$code .= "	<<$vName:64,";
	    				$ifBreak = false;
	    			} else {
	    				$code .= "$vName:64,";
	    			}
	     		} else if ($dataType == 'string') {
	     			$strLenVName = "{$vName}Len";
	     			$j = $i+1;
	     			if ($ifBreak) {
	     				$code .= "	<<$strLenVName:16, Bin{$j}/binary>> = Bin{$i}," . CL;
	     				$ifBreak = false;
	     			} else {
	     				$code .= "$strLenVName:16, Bin{$j}/binary>> = Bin{$i}," . CL;
	     			}
	     			$i++;
	     			$code .= "	<<$vName:$strLenVName/binary,";
	     		} else if ($dataType == 'bool') {
	     			$vNameTmp = $vName."Tmp";
	     			if ($ifBreak) {
	     				$code .= "<<$vNameTmp:8,";
	     				$ifBreak = false;
	     			} else {
	     				$code .= "$vNameTmp:8,";
	     			}
	     			$assignCode .= "case $vNameTmp of " . CL;
	     			$assignCode .= "	1 -> " . CL;
					$assignCode .= "		$vName = true;" . CL;
					$assignCode .= "	_ ->" . CL;
					$assignCode .= "		$vName = false" . CL;
					$assignCode .= "end," . CL;
				} else if ($dataType == 'bytes') {
					if ($ifBreak) {
	     				$code .= "<<$vName/binary,";
	     				$ifBreak = false;
	     			} else {
	     				$code .= "$vName/binary,";
	     			}
	     		} else {
	     			//复杂结构体类型，先读取长度(为什么读取长度，而不是直接传入二进制匹配？性能!)
	     			$subBinVName = "SubBin".$name;
	     			$subBinSizeVName = "SubBinSize".$name;
	     			
	     			if ($k == $sizeOfField) {
	     				if ($ifBreak) {
		     				$code .= "	<<_$subBinSizeVName:32, $subBinVName/binary>> = Bin{$i}," . CL;
		     			} else {
		     				$code .= "_$subBinSizeVName:32, $subBinVName/binary>> = Bin{$i}," . CL;
		     			}
	     			} else {
	     				$j = $i + 1;
		     			if ($ifBreak) {
		     				$code .= "	<<$subBinSizeVName:32, Bin{$j}/binary>> = Bin{$i}," . CL;
		     			} else {
		     				$code .= "$subBinSizeVName:32, Bin{$j}/binary>> = Bin{$i}," . CL;
		     			}
		     			$i++;
		     			$j = $i + 1;
		     			$code .= "	<<$subBinVName:$subBinSizeVName/binary, Bin{$j}/binary>> = Bin{$i}," . CL;
		     			$i++;
	     			}
	     			
	     			$code .= "	$vName = decode_{$dataType}($subBinVName)," . CL;
	     			$this->erlDecodeFuncArray[$dataType] = 1;
	     			$ifBreak = true;
	     		}
    		}
    		
    		if ($type != 'repeated' && $dataType == 'string') {
    			$constructCode .= "common_tool:to_list($vName),";
    		} else {
    			$constructCode .= "$vName,";
    		}
    		
    		$k++;
    	}
    	$constructCode = trim($constructCode, ", ")."};" . CL;
    	$code = rtrim($code, ",");
    	if ($ifBreak) {
    		//ignore
    	} else {
    		$code .= ">> = Bin".$i++."," . CL;
    	}
    	$code .= $assignCode . CL . $constructCode . CL;
    	
    	$code .= "decode_{$messageName}(_) ->" . CL;
    	$code .= "	undefined." . CL;
    	
    	return $code;
    }
    
    private function _gene_erlang_decode_repeated_code(ProtoMessage $m) {
    	$code = '';
    	$name = $m->getName();
    	$funcName = "decode_{$name}s";
    	//避免重复生成
        if (isset($this->erlangEncodes[$funcName])){
        	return null;
        }
        $this->erlangEncodes[$funcName] = 2;
    	
		$code .= "$funcName(<<>>, List) ->" . CL;
		$code .= "	List;" . CL;
		$code .= "$funcName(Bin, List) ->" . CL;
		$code .= "	<<SubBinSize:32, Bin2/binary>> = Bin," . CL;
		$code .= "	<<SubBin:SubBinSize/binary, Bin3/binary>> = Bin2,";
		$code .= "	TmpRecord = decode_{$name}(SubBin)," . CL;
		$code .= "	$funcName(Bin3, [TmpRecord|List])." . CL;   	
		return $code;
    }
}


class ProtoParse {
    private $messages = array();
    
    public function parse($contentAll) {
        //匹配所有的message
        if (preg_match_all("/message[ \t]+[\w]+[ \t\n]*{[ \t\n]+[^}]*}/i", $contentAll, $matches) > 0) {
            // 现在 matches数组的每个元素都是一个message
            foreach($matches[0] as $messageDesc) {
                $message = $this->_parse_message($messageDesc);
                $this->_push($message);
            }
            return $this->messages;
		} else {
			var_dump($matches);
		    throw new Exception ("proto定义文件格式出错:1");
		}
    }
    
    private function _push(ProtoMessage $message) {
        $this->messages[$message->getName()] = $message;
    }
    
    private function _parse_message($messageDesc) {
        if (preg_match("/message[ \t]+([\w]+)[ \t\n]?{([ \t\n]+[^}]*)}/i", $messageDesc, $messageDetail) > 0) {
            $messageName = $messageDetail[1];
            $messageBody = $messageDetail[2];
            $fields = explode("\n", $messageBody);
            $pm = new ProtoMessage($messageName);
            foreach($fields as $field) {
                if (trim($field) == '') {
                    continue;
                }
                //顺序匹配出  : 字段类型    数据类型  字段名称  字段唯一标示数字 默认值   
                $p = "/[ \t]*(required|optional|repeated)[ \t]+(\w+)[ \t]+(\w+)[ \t]*=[ \t]*([0-9]+)[ \t]*(\[default[ \t]*=[ \t]*([^\[\]]+)\])?;/";
                if (preg_match($p, $field, $f) > 0) {
                    $fieldObj = new ProtoField;
                    $fieldObj->type = $f[1];
                    $fieldObj->dataType = $f[2];
                    $fieldObj->name = strtolower($f[3]);
                    $fieldObj->unique = $f[4];
                    $fieldObj->default = isset($f[6]) ? ($f[6]) : NULL;
                    $pm->push($fieldObj);
                } else {
                    throw new Exception("proto定义文件格式出错:3 ->".$field);
                }
            }
            return $pm;
        }
        throw new Exception("proto定义文件格式出错:2");
    }
}

class ProtoMessage {
    private $fields = array();
    
    private $name;
    
    public function __construct($name) {
        $this->name = $name;
    }
    
    public function getName() {
        return $this->name;
    }
    
    public function setName($name) {
        $this->name = $name;
    }
    
    public function push(ProtoField $field) {
        array_push($this->fields, $field);
    }
    
    public function getFields() {
        return $this->fields;
    }
}

class ProtoField {
    public $type;
    public $dataType;
    public $name;
    public $unique;
    public $default;
}

