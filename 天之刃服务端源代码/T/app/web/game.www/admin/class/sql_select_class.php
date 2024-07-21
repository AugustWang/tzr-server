<?php
/**
* @author Qingliang 200800510@qq.com
* 2009-7-18 09:46:36
**/

if (!defined('SQL_SELECT_HELPER_CLASS_PHP_FILE'))
{
    define('SQL_SELECT_HELPER_CLASS_PHP_FILE', true);
    
    /**
     * select语句生成助手类，复杂的Select最好还是手写
     *
     */
    class SqlSelectClass
    {
        /**
         * 保存本次Select Sql语句对应的表名
         *
         * @var string
         */
        private $_table;
        
        /**
         * 保存Sql语句的SELECT * FROM TABLE_NAME部分
         *
         * @var string
         */
        private $_sqlField;
        
        /**
         * 保存Sql语句的where子句部分
         *
         * @var string
         */
        private $_sqlWhere;
        
        /**
         * 保存Sql语句的orderby部分
         *
         * @var string
         */
        private $_sqlOrderby;
        
        /**
         * 保存Sql语句的limit部分
         *
         * @var string
         */
        private $_sqlLimit;
        
        /**
         * 是否自动获得select查询的总记录数，
         * 注意：即使使用了limit语句，如果设置本
         * 选项为true也将获得所有的符合记录数
         *
         * @var bool
         */
        private $_autoGetFoundRows;
        
        /**
         * 是否自动转移传进来的数据库字段值
         *
         * @var bool
         */
        private $_autoSlash;
        
        /**
         * 最终生成的SQL语句
         *
         * @var string
         */
        private $_sqlFinal;
        
        /**
         * 私有构造方法
         *
         * @param string $table
         * @throw Exception
         */
        private function __construct($table, $autoSlash, $autoGetFoundRows)
        {
            if (!$table || !is_string($table))
            {
                throw new Exception('必须设置表名');
            }
            $this->_table = $table;
            $this->_autoGetFoundRows = (bool)$autoGetFoundRows;
            $this->_autoSlash = (bool)$autoSlash;
        }
        
        /**
         * 获得对象实例的方法包装
         *
         * @param string $table
         * @return SqlSelectClass
         */
        public static function getInstance($table, $autoSlash = false, $autoGetFoundRows = false)
        {
            return new self($table, $autoSlash, $autoGetFoundRows);
        }
        
        /**
         * 生成selec语句的select主体部分
         *
         * @param mixed $fields
         * @return SqlSelectClass
         */
        public function select($fields = '*')
        {
            //用于自动统计总记录行数，省去再一次使用counts语句
            if ($this->_autoGetFoundRows)
            {
                $this->_sqlField = 'SELECT SQL_CALC_FOUND_ROWS ';
            }
            else
            {
                $this->_sqlField = 'SELECT ';
            }
            if (is_string($fields))
            {
                if (!$fields) {$fields = '*';}
                $this->_sqlField .= $fields.' FROM '
                        .$this->addSqlKeyWordsQuote($this->_table);
            }
            else if (is_array($fields))
            {
                $f = ' ';
                if (array_index_by_string($fields))
                {
                    foreach ($fields as $k=>$v)
                    {
                        $f .= $this->addSqlKeyWordsQuote($k).' AS '
                            .$this->addSqlKeyWordsQuote($v).', ';
                    }
                }
                else
                {
                    $f = rtrim('`'.implode('`,'), ',');
                }
                $this->_sqlField .= $f.' FROM '
                		.$this->addSqlKeyWordsQuote($this->_table);
            }
            
            return $this;
        }
        
        /**
         * 生成select语句的orderby部分
         * 
         * <code>
         * 	orderby('order by id desc, name asc');
         *  orderby('id desc, name asc');
         *  orderby(array('id desc', 'name asc'));
         * </code>
         * @return SqlSelectClass
         */
        public function orderby()
        {
            $argsArr = func_get_args();
            if (is_array($argsArr[0]))
            {
                $this->_sqlOrderby = 'order by '.implode(',', $argsArr[0]);
            }
            else if (is_string($argsArr[0]))
            {
                if (empty($argsArr[0]))
                {
                    return $this;
                }
                if (stripos(trim($argsArr[0]), 'order by') === 0)
                {
                    $this->_sqlOrderby = trim($argsArr[0]);
                }
                else
                {
                    $this->_sqlOrderby = 'ORDER BY '.trim($argsArr[0]);
                }
            }
            return $this;
        }
        
        /**
         * 生成select的limit部分
         *
         * @return SqlSelectClass
         */
        public function limit()
        {
            $argsArr = func_get_args();
            $argc = func_num_args();
            if ($argc == 2)
            {
                $offset = intval($argsArr[0]);
                $pagesize = intval($argsArr[1]);
                $this->_sqlLimit = "LIMIT $offset, $pagesize";
            }
            else if ($argc == 1)
            {
                if (stripos(trim($argsArr[0]), 'LIMIT') === 0)
                {
                    $this->_sqlLimit = trim($argsArr[0]);
                }
                else
                {
                    $this->_sqlLimit = 'LIMIT '.trim($argsArr[0]);
                }
            }
            return $this;
        }
        
        /**
         * 生成sql的where部分
         * 
         * <code>
         * 	//传入多个字符串
         * 	SqlSelectClass::getInstance('test', false)
         * 			->where('id>? and name=?', $id, $name);
         *  //传入一个字符串
         *  SqlSelectClass::getInstance('test', false)
         * 			->where('where id>5 and name = "庆亮"');
         *  //传入一个数组
         *  SqlSelectClass::getInstance('test', false)
         * 			->where(array('id>1', 'name = "庆亮"'));
         * </code>
         *
         * @return SqlSelectClass
         */
        public function where()
        {
            $argsArr = func_get_args();
            $argc = func_num_args();
            if ($argc == 1)
            {
                if (is_string($argsArr[0]))
                {
                    $where = trim($argsArr[0]);
                    if (stripos($where, 'WHERE') === 0)
                    {
                        $this->_sqlWhere = $where;
                    }
                    else 
                    {
                        $this->_sqlWhere = 'WHERE '.$where;
                    }
                }
                else if (is_array($argsArr[0]))
                {
                    $this->_sqlWhere = 'WHERE '.implode(' AND ', $argsArr[0]);
                }
            }
            else if ($argc > 1)
            {
                //这种情形下，参数形式为 where('id=? and name=?', $id, $name)
                $argsArr[0] = str_replace('?', '%s', $argsArr[0]);
                for ($i=1; $i<$argc; $i++)
                {
                    $argsArr[$i] = $this->addSqlValueQuote($argsArr[$i]);
                }
                $this->_sqlWhere = 'WHERE '.call_user_func_array('sprintf', $argsArr);
            }
            else 
            {
                $this->_sqlWhere = 'WHERE 1';
            }
            return $this;
        }
        
        /**
         * 为数据库中的字段名或表名添加``，避免出现关键字冲突
         *
         * @param string $keyword
         * @return string
         */
        public function addSqlKeyWordsQuote($keyword)
        {
            return '`'.$keyword.'`';
        }
        
        /**
         * 为插入数据库中的值加上  ''
         *
         * @param string $value
         * @param bool $autoSlash
         * @return string
         */
        public function addSqlValueQuote($value)
        {
            if ($this->_autoSlash)
            {
                return "'".addslashes($value)."'";                
            }
            return "'$value'";
        }
        
        /**
         * 生成最终的Select SQL语句
         *
         * @return unknown
         */
        public function createSql()
        {
            if (!$this->_sqlField)
            {
                $this->select();
            }
            $this->_sqlFinal = $this->_sqlField;
            if ($this->_sqlWhere)
            {
                $this->_sqlFinal .= ' '.$this->_sqlWhere;
            }
            if ($this->_sqlOrderby)
            {
                $this->_sqlFinal .= ' '.$this->_sqlOrderby;
            }
            if ($this->_sqlLimit)
            {
                $this->_sqlFinal .= ' '.$this->_sqlLimit;
            }
            return $this->_sqlFinal;
        }
    }
    
    /**
     * 检查数组是否为字符串索引
     *
     * @param array $array
     * @return bool
     */
    function array_index_by_string($array)
    {
        $keys = array_keys($array);
        foreach ($keys as $v)
        {
            if (is_string($v))
            {
                return true;
            }
        }
        return false;
    }
}