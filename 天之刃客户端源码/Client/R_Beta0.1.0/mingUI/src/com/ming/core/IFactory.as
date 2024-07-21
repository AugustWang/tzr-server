package com.ming.core
{
	/**
	 * 接口定义一个工厂对象方法. 
	 */	
	public interface IFactory
	{
		/**
		 * 构造一个实例，基于一些类。
		 * @return 新的实例.
		 */
		function newInstance():*;
	}
}