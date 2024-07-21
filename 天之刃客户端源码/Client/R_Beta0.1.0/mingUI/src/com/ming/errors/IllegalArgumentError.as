package com.ming.errors
{
	/**
	 * 在调用函数时，传入参数错误,抛出此错误类型
	 */	
	public class IllegalArgumentError extends Error
	{
		public function IllegalArgumentError(message:String="")
		{
			super(message, 100000);
		}
		
	}
}