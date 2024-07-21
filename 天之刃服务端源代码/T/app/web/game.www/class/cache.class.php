<?php
/***************************************************************************
 *                              cache_class.php
 *                            -------------------
 *   begin                : 2008-03-05
 *   copyright            : odinxu
 *   email                : odinxu@hotmail.com
 * 
 * 	 Cache data at file or at memcached.  http://www.danga.com/memcached/
 * 
 *   Further: can cache at APC, eAccelerator, xCache shared memory.
 * 
 *   
        /////////////////////////////////////////////////////////////////////           
        //缓存配置,  use_config 为0表示使用第一项配置，为1表示使用第2项
        $CACHE_CONFIG = array(
                'use_config' => 'memcache' ,
                'memcache'   => 
                        array('type'     => 'memcache',
                          'server'   => array(
                                                array('host' =>'localhost', 'port' => '11211', 'weight' => '10')
                                                ),
                          'ttl'      => 3600,
                          'compress' => false,
                          ),
                'eaccelerator' => array(
                                'type'  => 'eaccelerator' ,
                                'ttl'      => 3600,
                                ),
                'file'       =>
                        array('type'     => 'file',
                          'cache_dir'=> dirname(dirname(__FILE__)) . '/cache/tmp/',
                          'ttl'      => 600,  
                          )
        );              
        /////////////////////////////////////////////////////////////////////   
 *  使用说明：
 *   include("....../cache_class.php");
 * 	 $cache = ConnectCache($CACHE_CONFIG, true);
 * 	 $cache->store('my_key','foobar',600); 
 *   print_r($cache->fetch('my_key')); 
 * 
 * 	 //最常用法示例，可以直接用SQL语句做用CACHE的KEY
 * 	 $sql = "SELECT * FROM tablename WHERE xxx='123'";
 * 
 * 	 if (! $arr = $cache->fetch($sql))  
 * 	 {	 //如果缓存中没有，则从数据库读取
 * 	     $arr = .... get data from database ....
 * 		 //读取到数据后，把它保存到缓存中，下次就可直接从缓存获取
 * 		 $cache->store($sql,$arr); 
 * 	 }
 *   print_r($arr);   //使用取得的数据
 ***************************************************************************/

if ( !defined('IN_ODINXU_SYSTEM') )
{
	die("Hacking attempt");
}

if(!defined("CACHE_CLASS_DEFINE"))
{

	define("CACHE_CLASS_DEFINE", TRUE );

	/////////////////////////////////////////////////////////////////////////////

	abstract class OX_Cache_Abstract { 
		abstract function __construct($conf);
		abstract function fetch($key); 
		abstract function store($key,$data,$ttl = -1); 
		abstract function delete($key); 
	} 

	/////////////////////////////////////////////////////////////////////////////
	// nothing to do this class
	class OX_Cache_Empty extends OX_Cache_Abstract { 
		public $connection; 
		public $cachetype;
		function __construct($conf) { 	
			$this->cache_config = $conf;
			$this->cachetype = 'empty';

			$this->connection = false;
		}
		function fetch($key)
		{
			return false;
		} 
		function store($key,$data,$ttl = -1)
		{
			return false;
		}
		function delete($key)
		{
			return false;
		}		
	}
	/////////////////////////////////////////////////////////////////////////////
	// Our class 
	class OX_Cache_Filesystem extends OX_Cache_Abstract { 

		public $connection; 
		public $cachetype;

		function __construct($conf) { 
			$this->connection = false;

			if ( (! $conf ) || $conf['type'] != 'file' )
				return false;

			$this->cache_config = $conf;
			$this->cachetype = 'file';

			//默认缓存时间为3600秒
			if (empty($this->cache_config['ttl']))
				$this->cache_config['ttl'] = 3600;
			//暂时不支持压缩
			if (empty($this->cache_config['compress']))
				$this->cache_config['compress'] = false;
			//默认缓存文件存放位置
			if (empty($this->cache_config['cache_dir']))
				$this->cache_config['cache_dir'] = '/tmp/';            	

			$this->connection = true;

		} 	

		// General function to find the filename for a certain key 
		private function getFileName($key) { 
			return  $this->cache_config['cache_dir'] . ($key); 
		} 

		// This is the function you store information with 
		function store($key,$data,$ttl = -1) { 
			if ( $ttl == -1)
				$_ttl = $this->cache_config['ttl'];

			$data = serialize(array(time()+$_ttl,$_SERVER['PHP_SELF'],isset($_SERVER["REQUEST_URI"])?$_SERVER["REQUEST_URI"]:'',$key,$data)); 

			// Opening the file in read/write mode 
			$h = fopen($this->getFileName($key),'w');
			if (!$h) throw new exception('Could not write to cache'); 

			// exclusive lock, will get released when the file is closed
			if ( ! flock($h,LOCK_EX) )
				return false;

			if (fwrite($h,$data)===false) { 
				throw new exception('Could not write to cache'); 
			} 
			flock($h, LOCK_UN);

			fclose($h); 
			return true;
		} 

		function fetch($key) { 

			$filename = $this->getFileName($key); 

			if (!file_exists($filename)) return false; 
			$fp = fopen($filename,'r'); 
			if (!$fp) return false; 

			$contents = "";
			while (!feof($fp)) {
				$contents .= fread($fp, 8192);
			}
			fclose($fp); 

			$data = unserialize($contents); 
			if (!$data) { 
				unlink($filename); 
				return false; 
			} 

			if (time() > $data[0]) { 
				unlink($filename); 
				return false; 
			} 

			return $data[4]; 
		} 

		function delete( $key ) { 

			$filename = $this->getFileName($key); 
			if (file_exists($filename)) { 
				return unlink($filename); 
			} else { 
				return false; 
			} 
		} 
	} 

	/////////////////////////////////////////////////////////////////////////////
	if ( extension_loaded("eaccelerator") )
	{
		class OX_Cache_eAccelerator extends OX_Cache_Abstract { 

			public $connection; 
			public $cachetype;

			function __construct($conf) { 
				$this->connection = false;
				if ( (! $conf ) || $conf['type'] != 'eaccelerator' )
					return false;

				$this->cache_config = $conf;
				$this->cachetype = 'eaccelerator';

				//默认缓存时间为3600秒
				if (!isset($this->cache_config['ttl']))
					$this->cache_config['ttl'] = 3600;

				//设置最大缓存时间为2592000，超过则会出错
				if ($this->cache_config['ttl'] > 2592000)
					$this->cache_config['ttl'] = 2592000; 

				$this->connection = true;

			} 

			function fetch($key) { 
				//echo "fetch $key ";
				return unserialize(gzuncompress(eaccelerator_get($key))); 
			} 

			function store($key,$data,$ttl = 3600) { 
				//echo "store $key ";
				return eaccelerator_put($key,gzcompress(serialize($data)),$ttl); 
			} 

			function delete($key) { 
				return eaccelerator_rm($key); 
			} 
		} 
	}

	/////////////////////////////////////////////////////////////////////////////
	if ( extension_loaded("memcache") )
	{
		class OX_Cache_MemCache extends OX_Cache_Abstract { 

			// Memcache object 
			public $connection; 
			public $cachetype;

			function __construct($conf) { 
				$this->connection = false;
				if ( (! $conf ) || $conf['type'] != 'memcache' )
					return false;

				$this->cache_config = $conf;
				$this->cachetype = 'memcache';

				//默认缓存时间为3600秒
				if (!isset($this->cache_config['ttl']))
					$this->cache_config['ttl'] = 3600;
				//默认启用压缩
				if (!isset($this->cache_config['compress']))
					$this->cache_config['compress'] = false;
				//memcache支持的最大缓存时间为2592000，超过则会出错
				if ($this->cache_config['ttl'] > 2592000)
					$this->cache_config['ttl'] = 2592000; 

				$this->connection = new MemCache;
				if  ($this->connection)
				{
					foreach($conf['server'] as $s)
					{
						$this->addServer($s['host'], $s['port'], $s['weight']);
					}
				}
			} 

			function __destruct()
			{
				/*addserver 一直保持持久连接 暂屏蔽
				if ($this->connection)
				{
					$this->connection->close();
				}
				*/
			} 

			function store($key, $data, $ttl = -1) { 
				if ( $ttl == -1)
					$ttl = $this->cache_config['ttl'];

				if ($this->cache_config['compress'])
					return $this->connection->set(($key),$data, MEMCACHE_COMPRESSED ,$ttl); 
				else
					return $this->connection->set(($key),$data, false, $ttl); 
			} 

			function add($key, $data, $ttl = -1) { 
				if ( $ttl == -1)
					$ttl = $this->cache_config['ttl'];

				if ($this->cache_config['compress'])
					return $this->connection->add(($key),$data, MEMCACHE_COMPRESSED ,$ttl); 
				else
					return $this->connection->add(($key),$data, false, $ttl); 
			} 
			
			function increase($key, $value=1) {
				$this->connection->increment($key, $value);				
			}
			
			function decrease($key, $value=1) {
				$this->connection->decrement($key, $value);
			}

			/*
			 * 同时存多个缓存数据，参数为数组，数组下标 对应 每一个缓存项的 KEY 
			 */
			function storeMulti($arrData, $ttl = -1) { 
				if (is_array($arrData))
				{
					foreach($arrData as $key=>$data)
						$this->store($key, $data, $ttl);

					return true;
				}
				else
					return false;
			}

			function fetch($key) { 
				if (empty($key)){
					return NULL;
				}
				return $this->connection->get(($key)); 
			} 

			function delete($key) { 
				return $this->connection->delete(($key)); 
			} 

			function deleteByKeyPattern($key_pattern) {
				$items = $this->connection->getStatus('items');
				foreach($items as $mk=>$mv)
					if(preg_match($key_pattern, $mk))
						$this->connection->delete(($mk));
			}

			function addServer($host,$port = 11211, $weight = 10) { 
				$this->connection->addServer($host,$port,true,$weight); 
			} 

		} 
	}
	
	/////////////////////////////////////////////////////////////////////////////// 
	if ( extension_loaded("memcached") )
	{
		class OX_Cache_MemCacheD extends OX_Cache_Abstract { 

			// MemcacheD object 
			public $connection; 
			public $cachetype;

			function __construct($conf) { 
				$this->connection = false;
				if ( (! $conf ) || $conf['type'] != 'memcached' )
					return false;

				$this->cache_config = $conf;
				$this->cachetype = 'memcached';

				//默认缓存时间为3600秒
				if (!isset($this->cache_config['ttl']))
					$this->cache_config['ttl'] = 3600;
				//默认启用压缩
				if (!isset($this->cache_config['compress']))
					$this->cache_config['compress'] = false;
				//memcached支持的最大缓存时间为2592000，超过则会出错
				if ($this->cache_config['ttl'] > 2592000)
					$this->cache_config['ttl'] = 2592000; 

				$persistent_str = $this->cache_config['persistent_str']; // . posix_getpid();

				//使用带参数的，持久化连接方案
				$this->connection = new MemCached( $persistent_str );
				if  (count($this->connection->getServerList()) < 1)
				{
					//未能从连接池获得连接，则重新连接到memcached服务器
					foreach($conf['server'] as $s)
					{
						$this->addServer($s['host'], $s['port'], $s['weight']);
					}
				}

				//因为 MemCacheD 默认是开启压缩的，所以如果要不压缩，需要更新设置
				if ( ! $this->cache_config['compress'])
				{
					$this->connection->setOption(Memcached::OPT_COMPRESSION , false);
				}       
			} 

			function __destruct()
			{
				//注意这里不需要CLOSE，跟pecl-memcache的不同
			} 

			function store($key, $data, $ttl = -1) { 
				if ( $ttl == -1)
					$ttl = $this->cache_config['ttl'];

				return $this->connection->set($key,$data, $ttl);
				//注意这里是3个参数，跟pecl-memcache的四个参数不同  
			} 

			/*
			 * 同时存多个缓存数据，参数为数组，数组下标 对应 每一个缓存项的 KEY 
			 */
			function storeMulti($arrData, $ttl = -1) { 
				if ( $ttl == -1)
					$ttl = $this->cache_config['ttl'];

				return $this->connection->setMulti($arrData, $ttl);
			}

			function fetch($key) { 
				//跟 pecl-memcache 不同，这里取单个缓存，跟取多个缓存，需要分别用不同的函数，
				//而 pecl-memcache 统一用一个函数 get 就可以处理2种情况。

				if (is_string($key))
					return $this->connection->get($key);
				if (is_array($key))
					return $this->connection->getMulti($key); 
			} 

			function delete($key) { 
				return $this->connection->delete($key); 
			} 

			function deleteByKeyPattern($key_pattern) {
				return false;

				//目前 MemCacheD 尚未支持这项功能！！
			}

			function addServer($host,$port = 11211, $weight = 10) { 
				$this->connection->addServer($host,$port,$weight);	
				//注意这里是3个参数，跟pecl-memcache的四个参数不同 
			} 

		} 
	}
	/////////////////////////////////////////////////////////////////////////////// 


	/**
	 * $error_die  当连接Cache出错时，是否直接die，默认否  
	 * @param $cache_config
	 * @param $error_die
	 * @return OX_Cache_Abstract
	 */
	function ConnectCache($cache_config, $error_die = false)
	{
		$conf = $cache_config[$cache_config['use_config']];

		if (!empty($conf))
		{
			if ($conf['type'] ==  "memcached")
			{
				if ( extension_loaded("memcached") )
				{		
					$cache = new OX_Cache_MemCacheD($conf);
				}
			}
			else if ($conf['type'] ==  "memcache")
			{
				if ( extension_loaded("memcache") )
				{		
					$cache = new OX_Cache_MemCache($conf);
				}
			}
			else if ($conf['type'] == "file" )
			{
				$cache = new OX_Cache_Filesystem($conf); 
			}
			else if ($conf['type'] == "eaccelerator" )
			{
				$cache = new OX_Cache_eAccelerator($conf);
			}
		}

		if (!$cache->connection)
		{
			if($error_die || $cache_config['debug'])
			{
				die("Could not connect to the cache server.");
			}
			else
			{
				//如果没有连接缓存系统，而且不中止程序，则用一个啥也不干的缓存来代替
				$cache = new OX_Cache_Empty($conf); 
			}
		}
		return $cache;		
	}	
}    

