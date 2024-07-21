package com.ming.ui.controls
{
	import com.ming.ui.controls.core.BaseToolTip;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.ToolTipSkin;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * 普通信息提示类
	 */ 
	public class ToolTip extends BaseToolTip
	{
		private var text:TextField;
		
		public function ToolTip()
		{
			super();
			this.bgColor = 0xffcc88;
			setDefaultToolTip();
			if(ToolTipSkin.bgSkin){
				bgSkin = ToolTipSkin.bgSkin;
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data=value;
			if(data){
				
				if(text.htmlText!=data.toString())text.htmlText=data.toString();
				width=text.width + 20;
				height=text.height + 10;
				this.validateNow();
				text.x=10;
				text.y=5;
			}
		}
		
		override public function set mX(value:Number):void
		{
			super.mX=value;
			if (stage != null)
			{
				if (value - 5 <= 0)
				{
					value=0;
				}
				else if (value - 5 + width > stage.stageWidth)
				{
					value=stage.stageWidth - width;
				}
				else
				{
					value=value - 5;
				}
			}
			else
			{
				value=value - 5;
			}
			x=value;
		}
		
		override public function set mY(value:Number):void
		{
			super.mY=value;
			if (stage != null)
			{
				if (value + height + 30 > stage.stageHeight)
				{
					value=value - height - 8;
				}
				else
				{
					value=value + 20;
				}
			}
			else
			{
				value=value + 20;
			}
			y=value;
		}
		
		public function setDefaultToolTip():void
		{
			text=new TextField();
			text.defaultTextFormat=ToolTipSkin.tf;
			text.autoSize=TextFieldAutoSize.CENTER;
			addChild(text);
		}
		
		override public function clear():void{
			data = "";
		}
	}
}