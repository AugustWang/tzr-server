package com.ming.ui.layout
{
	import flash.geom.Point;
	/**
	 * 布局基类 
	 * @author huyongbo
	 * 
	 */
	public class BaseLayout
	{
		//布局的类型 
		protected var type:String ;
		
		//要布局的对象数据数组
		protected var layoutEls:Array;
		
		//布局中心点位置
		protected var centerPoint:Point;
		
		//分布开始角度 默认0度开始分布
		protected var startAngle:Number = 0 ;
		
		//每个元素之间的角度间隙
		//通过计算得到
		protected var disAngle:Number ; 
		
		public function BaseLayout(){
			
		}
		
		public function layout():void{
			
		}
	}
}