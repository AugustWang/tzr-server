package modules.friend.views.items
{
	import com.ming.core.IDataRenderer;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class GroupItem extends Sprite implements IDataRenderer
	{
		private var text:TextField;
		public function GroupItem():void{
			text = new TextField();
			text.selectable = false;
			addChild(text);
		}
		
		private var _data:Object;
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
			text.x = 5;
			text.htmlText = "<font color='#ffffff'>" + data.name + "  ("+data.count+")" + "</font>";		
		}
	}
}