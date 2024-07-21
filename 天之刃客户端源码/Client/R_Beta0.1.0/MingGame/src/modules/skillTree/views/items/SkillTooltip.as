package modules.skillTree.views.items
{
	import com.ming.ui.controls.core.BaseToolTip;
	import com.ming.ui.skins.ToolTipSkin;
	import com.ming.ui.style.StyleManager;
	
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class SkillTooltip extends BaseToolTip
	{
		private var text:TextField
		public function SkillTooltip()
		{
			createText();
			this.bgSkin = Style.getInstance().tipSkin;
		}
		
		override public function set data(value:Object):void{
			text.htmlText = value.toString();
			//text.setTextFormat(StyleManager.textFormat);
			text.height = text.textHeight + 5;
			this.width = text.width + 10;
			this.height = text.textHeight + 20;
		}
		
		private function createText():void{
			text=new TextField();			
			text.wordWrap = true;
			text.multiline = true;
			text.width = 180;
			var tf:TextFormat=Style.textFormat;
			tf.leading=4;
			text.defaultTextFormat = tf;
			text.selectable=false;
			text.x = text.y = 6;
			addChild(text);
		}
		
		override public function set targetX(value:Number):void{
			x = value;
			ajustPosition(44,44);
		}
		
		override public function set targetY(value:Number):void{
			y = value;
			ajustPosition(44,44);
		}
	}
}