<?php
class DBClass
{
	/**
	 *
	 * 数据库连接
	 * @var resource
	 */
	private $conn = null;

	private $query_result;

	private $rows;

	/**
	 *
	 * 连接数据库
	 * @param array $config
	 * @throws Exception
	 */
	public function connect($config)
	{
		if (!is_resource($this->conn)) {
			$user = $config['user'];
			$passwd = $config['passwd'];
			$host = $config['host'];
			$dbname = $config['dbname'];
			$link = mysql_connect($host, $user, $passwd);
			if (!$link){
				throw new Exception("数据连接失败:" . mysql_error());
			}
			$this->conn = $link;
			if (!mysql_select_db($dbname, $link)) {
				throw new Exception("选择数据库表错误:" . mysql_error());
			}
			mysql_query("set names utf8", $link);
		}
	}

	public function begin()
	{

	}

	public function rollback()
	{

	}

	public function commit()
	{

	}

	/**
	 * 执行sql语句，并返回Resource
	 * @param string $sql
	 * @throws Exception
	 * @return resource
	 */
	public function query($sql)
	{
		$sql = trim($sql);
		if ($sql == '') {
			throw new Exception("SQL语句不能为空");
		}
		if (!$this->conn) {
			global $dbConfig;
			$this->connect($dbConfig);
		}
		$result = mysql_query($sql, $this->conn);
		if ($result === false) {
			throw new Exception("sql执行出错:" . $sql . "   " . mysql_error());
		}
		$this->query_result=$result;
		return $result;
	}

	/**
	 * 执行select语句并返回结果
	 * @param string $sql
	 * @return array
	 */
	public function fetchAll($sql)
	{
		$this->query($sql);
		return $this->getAll($this->query_result);
	}

	public function fetchOne($sql)
	{
		$this->query($sql);
		return $this->getOne($this->query_result);
	}

	public function getOne($result)
	{
		if ($this->query_result) {
			$result =  mysql_fetch_assoc($this->query_result);
			if (!$result) {
				return array();
			}
			return $result;
		}
		throw new Exception("获取sql执行结果出错，可能尚未执行sql");
	}

	public function getAll($result)
	{
		if ($this->query_result) {
			$this->rows = array();
			while (($row = mysql_fetch_assoc($this->query_result)) !== false) {
				array_push($this->rows, $row);
			}
			return $this->rows;
		}
		throw new Exception("获取sql执行结果出错，可能尚未执行sql");
	}
	
	public function insertID()
	{
		return @mysql_insert_id($this->conn);
	}
}