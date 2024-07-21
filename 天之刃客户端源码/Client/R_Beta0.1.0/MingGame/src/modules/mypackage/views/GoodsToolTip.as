package modules.mypackage.views
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.BaseToolTip;
	import com.ming.ui.style.StyleManager;
	import com.ming.utils.StringUtil;
	import com.utils.HtmlUtil;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class GoodsToolTip extends BaseToolTip
	{
		private var text:TextField;
		public function GoodsToolTip()
		{
			super();
			this.bgSkin = Style.getInstance().tipSkin;
			text=new TextField();
			text.width = 170;
			text.wordWrap = true;
			var tf:TextFormat=Style.textFormat;
			tf.leading=4;
			text.defaultTextFormat =tf;
			text.selectable=false;
			addChild(text);
		}
	
		override public function set data(value:Object):void
		{
			super.data=value;
			if(value is String){
				text.htmlText=StringUtil.trim(value.toString());
				text.height = text.textHeight + 5;
				width=text.width + 10;
				text.width = width - 10;
				height=text.height + 10;
				text.x=5;
				text.y=5;
				validateNow();
			}else{
				wrapperHTML(data as BaseItemVO);
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
		
		private function wrapperHTML(itemVo:BaseItemVO):void{
			text.htmlText=GoodsTipWrapper.wrapperItem(itemVo);
			text.height = text.textHeight + 5;
			width=text.width + 10;
			text.width = width - 10;
			height=text.height + 10;
			text.x=5;
			text.y=5;
			validateNow();
		}
		
		override public function clear():void{
			data = "";
		}
	}
}