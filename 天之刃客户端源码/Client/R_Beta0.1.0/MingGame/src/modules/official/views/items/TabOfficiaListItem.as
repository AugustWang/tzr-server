package modules.official.views.items
{
	import com.common.GameConstant;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	import modules.official.views.vo.OfficalMemberVO;
	
	public class TabOfficiaListItem extends Sprite implements IDataRenderer
	{
		public static const nameTitles:Array = ["王","阁","将","锦"];
		private var text:TextField;
		private var image:Image;
		public function TabOfficiaListItem(){
			text = ComponentUtil.createTextField("",40,4,null,NaN,25,this);
			image = new Image();
			image.x = 5;
			image.width = 25;
			image.height = 25;
			addChild(image);
			this.mouseChildren = false;
		}
		
		private var _data:Object;
		public function set data(value:Object):void{
			this._data = value;
			if(_data){
				wrapperContent();
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		private function setOnline(online:Boolean):void{
			if(info.online){
				filters = [];
			}else{
				filters = [new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
			}
		}
		
		private var info:OfficalMemberVO;
		public function wrapperContent():void{
			info = data as OfficalMemberVO;
			if(info){
				image.source = GameConstant.getHeadImage(info.head);
				text.htmlText = info.roleName+HtmlUtil.font("("+nameTitles[info.officeId]+")","#ffff00");
			}
		}
	}
}