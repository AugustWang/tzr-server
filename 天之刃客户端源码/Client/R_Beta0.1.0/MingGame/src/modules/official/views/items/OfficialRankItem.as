package modules.official.views.items
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.line.p_faction_online_rank;
	
	public class OfficialRankItem extends Sprite implements IDataRenderer
	{
		private static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		
		private var level:TextField;
		private var nameText:TextField;
		private var state:TextField;
		public function OfficialRankItem(){
			
			level = ComponentUtil.createTextField("",40,4,tf,55,25,this);
			nameText = ComponentUtil.createTextField("",40,4,tf,110,25,this);
			state = ComponentUtil.createTextField("",40,4,tf,68,25,this);
			LayoutUtil.layoutHorizontal(this);
			this.mouseChildren = false;
		}
		
		private var _data:Object;
		public function set data(value:Object):void{
			this._data = value;
			if(_data){
				var vo:p_faction_online_rank = data as p_faction_online_rank;
				level.text = vo.role_level.toString();
				nameText.text = vo.role_name;
				state.text = "在线";
			}
		}
		
		public function get data():Object{
			return _data;
		}
	}
}