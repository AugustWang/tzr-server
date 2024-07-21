package modules.help.itemrender
{
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.text.TextField;
	
	public class ListItem extends UIComponent
	{
		//list文字
		private var listText:TextField;
		//数据源
		private var dataVO:Object;
		
		public function ListItem()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			// TODO Auto Generated method stub
			listText = ComponentUtil.createTextField( "", 5, 2, null, 300, 22, this ); /*个人拉镖*/
			listText.textColor = 0xFFFFFF;
			listText.multiline = listText.wordWrap = true;
		}
		
		override public function set data(data:Object):void{
			this.dataVO = data;
			listText.htmlText=data.question;
//			listText.htmlText="我<font color='#FFFF00'>爱</font>你";
		}
		
		override public function get data():Object{
			return this.dataVO;
		}
	}
}