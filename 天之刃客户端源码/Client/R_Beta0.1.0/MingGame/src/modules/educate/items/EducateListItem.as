package modules.educate.items
{
	import com.ming.core.IDataRenderer;
	
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import modules.educate.EducateConstant;
	
	import proto.line.p_educate_role_info;
	
	public class EducateListItem extends Sprite implements IDataRenderer
	{
		private var text:TextField;
		public function EducateListItem(){
			text = ComponentUtil.createTextField("",10,4,null,NaN,25,this);
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
			if(online){
				filters = [];
			}else{
				filters = [new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
			}
		}
		
		private var info:p_educate_role_info;
		public function wrapperContent():void{
			info = data as p_educate_role_info;
			if(info){
				text.htmlText = info.name+HtmlUtil.font("("+EducateConstant.RELATIVES[info.relation]+")","#ffff00");
				setOnline(info.online);
			}
		}
	}
}