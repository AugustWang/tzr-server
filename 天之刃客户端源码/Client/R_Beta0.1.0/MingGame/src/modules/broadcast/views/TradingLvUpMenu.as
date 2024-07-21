package modules.broadcast.views
{
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TradingLvUpMenu extends UIComponent
	{
		private var bgView:Sprite;
		private var text:TextField;
		
		public function TradingLvUpMenu()
		{
			super();
			this.width = 230;
			this.height = 44;
			initView();
		}
		
		private function initView():void
		{
			this.bgColor=0x000000;
//			this.bgAlpha=0;
			Style.setRectBorder(this);
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF6F5CD);
			tf.leading = 5;
			text = ComponentUtil.createTextField("",5,2,tf,228,44,this);
			
			text.text = "1 到平江挂机打怪\n" +
				"2 到太平村找张三丰，挂训练营获得经验";
		}
		
		override public function dispose():void
		{
			super.dispose();
			if(text)
			{
				if(text.parent)
				{
					this.removeChild(text);
				}
				text.text = "";
				text = null;
			}
		}
		
	}
}