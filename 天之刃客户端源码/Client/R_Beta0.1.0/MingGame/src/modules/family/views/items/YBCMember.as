package modules.family.views.items
{
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import proto.line.p_family_ybc_member_info;
	
	public class YBCMember extends Sprite implements IDataRenderer
	{
		public static const STATUS:Array = ["","正常","远离","下线"];
		private var nameText:TextField;
		private var stateText:TextField;
		public var tf:TextFormat = Style.themeTextFormat;
		public function YBCMember()
		{
			super();
			tf.align = TextFormatAlign.CENTER;
			nameText = ComponentUtil.createTextField("",0,2,tf,180,25,this);
			stateText = ComponentUtil.createTextField("",180,2,tf,84,25,this);
		}
		
		private var _data:Object
		public function set data(value:Object):void{
			_data = value;
			if(_data){
				nameText.text = p_family_ybc_member_info(_data).role_name;
				var state:int = p_family_ybc_member_info(_data).status;
				stateText.text = STATUS[state];
			}
		}
		
		private function setFilters():void{
			if(_data.status > 1){
				tf.color = 0xCCCCCC;
			}else{
				tf.color = 0xAFE1EC;
			}
			nameText.setTextFormat(tf);
			stateText.setTextFormat(tf);
		}
		
		public function get data():Object{
			return _data;
		}
	}
}