package modules.greenHand.view.item
{
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class DiretoryItemRender extends UIComponent
	{
		private var titleTxt:TextField;
		public function DiretoryItemRender()
		{
			super();
			var icon:Sprite = Style.getViewBg("taskIcon");
			this.addChild(icon);
			icon.x = 2;
			icon.y = 2;
			
			titleTxt = ComponentUtil.createTextField("",icon.x + icon.width + 2,icon.y -1,null,145,23,this);
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(value){
				titleTxt.htmlText ="<font color='#AFE1EC'>"+ value.question+"</font>";
			}
		}
	}
}