package com.ming.ui.controls
{
	import com.ming.core.IDataRenderer;
	/**
	 * 定义提示信息接口
	 **/
	public interface IToolTip extends IDataRenderer
	{
		function set mX(value:Number):void; //鼠标所在的mouseX (如果是鼠标跟随可能需要覆盖此方法 )
		function get mX():Number;
		function set mY(value:Number):void; //鼠标所在的mouseY (如果是鼠标跟随可能需要覆盖此方法 )
		function get mY():Number;
		function set targetX(value:Number):void; //固定X (如果固定提示位置可能需要覆盖此方法 )
		function get targetX():Number;
		function set targetY(value:Number):void; //固定Y (如果固定提示位置可能需要覆盖此方法 )
		function get targetY():Number;		
	}
}