<?php
/**
* @author Qingliang 200800510@qq.com
* 2009-7-18 11:19:48
**/

if (!defined('SQL_FUNC_HELPER_CLASS_PHP_FILE'))
{
	define('SQL_FUNC_HELPER_CLASS_PHP_FILE', true);
    class SqlFuncHelperClass
    {
        /**
         * 根据当前页和每页的记录集大小获得sql limit语句中的offset
         *
         * @param int $page
         * @param int $pagesize
         * @return int
         */
        public static function calcLimitOffset($page, $pagesize)
        {
            if ($page == 0) 
            {
                return 0;
            }
            return ($page - 1) * $pagesize;
        }
    }
}
