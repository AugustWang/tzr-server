<?php
/**
 * 门派处理类
 * PHP访问Mochiweb操作处理
 * 提供以下接口
 * 根据门派名查询门派信息（返回所有的数据）
 */

class AdminFamilyClass {

        function AdminFamilyClass(){
            $jsonHomeUrl = ERLANG_WEB_URL . "/family";
        }
        /**
 	 	 * 根据门派名查询门派信息（返回所有的数据）
         */
         public static function getfamilybyfamilyname($FamilyName){
            $result = getJson (ERLANG_WEB_URL . "/family?fun=getFamilyInfo&arg0=&arg1=".$FamilyName);
			return $result;
        }
        public static function getFamilyInfo($FamilyID,$FamilyName){
            $result = getJson (ERLANG_WEB_URL . "/family?fun=getFamilyInfo&arg0=".$FamilyID."&arg1=".$FamilyName);
			return $result;
        }
        public static function getFamilyExtInfo($FamilyID){
        	$result = getJson (ERLANG_WEB_URL . "/family?fun=getFamilyExtInfo&arg0=".$FamilyID);
        	return $result;
        }
		public static function getFamilyCreateTime($where){
			$sql = "select create_time from t_family_summary {$where}";
			$rs = GFetchRowOne($sql);
		return intval($rs['create_time']);
	}
}

?>
