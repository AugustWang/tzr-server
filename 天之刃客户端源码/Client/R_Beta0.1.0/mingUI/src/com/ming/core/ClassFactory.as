package com.ming.core
{
	/**
	 * ClassFactory 通过设置需要实例化的类，并通过newInstance方法将其实例化.
	 * 
	 */
	public class ClassFactory implements IFactory
	{
	    /**
	     *  构造函数.
	     *  @param generator 这个类通过newInstance方法来构造一个对象从这个工厂对象中.
	     */
	    public function ClassFactory(instanceClass:Class = null)
	    {
	    	this.instanceClass = instanceClass;
	    }
	
	    /**
	     * 这个类通过newInstance方法来构造一个对象从这个工厂对象中.
	     */
	    public var instanceClass:Class;
	
		/**
		 * 这个属性在实例化instanceClass定义的类时，可以作为初始化参数赋值给instance.
		 * @default null
		 */
		public var properties:* = null;
	
		/**
		 * 构造一个新的实例，根据这个generator类.
		 * @return 构造的新的实例对象.
		 */
		public function newInstance():*
		{
			var instance:Object = new instanceClass();
	
	        if (properties != null)
	        {
	        	for (var p:String in properties)
				{
	        		instance[p] = properties[p];
				}
	       	}
	
	       	return instance;
		}
	}

}
