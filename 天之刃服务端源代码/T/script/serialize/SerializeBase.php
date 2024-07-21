<?php
include "excel_class.php";
define ( 'USE_ABLE_COLUMN_INDEX', 0 );

class SerializeBase {
	
	public function __construct() {
	}
	
	protected function getArrayAMF($arr) {
		$stream = new Zend_Amf_Parse_OutputStream ();
		$serialize = new Zend_Amf_Parse_Amf3_Serializer ( $stream );
		$serialize->writeArray ( $arr );
		$data = "\t" . $stream->getStream ();
		
		return $data;
	}
	
	protected function writeToFile($data, $file, $gzip = true) {
		$fh = fopen ( $file, 'w' );
		if ($gzip) {
			$data = gzcompress ( $data );
		}
		
		fwrite ( $fh, $data );
		fclose ( $fh );
	}
	
	protected function readXML($file) {
		if (! file_exists ( $file )) {
			trigger_error ( '文件不存在:' . $file );
			exit ();
		}
		//Read_Excel_File ( $file, $dataTmp );
		
		$xml = simplexml_load_file($file);
		return $xml;
	}
	
	protected function readExcel($file) {
		if (! file_exists ( $file )) {
			trigger_error ( '文件不存在:' . $file );
			exit ();
		}
		$dataTmp = array ();
		Read_Excel_File ( $file, $dataTmp );
		$data = array ();
		
		
		foreach ( $dataTmp as $table ) {
			foreach ( $table as $columns ) {
				$useAble = ($columns [USE_ABLE_COLUMN_INDEX]);
				if ($useAble == 0) {
					continue;
				}
				array_shift ( $columns );
				$data [] = $columns;
			}
		}
		return $data;
	}
}

?>