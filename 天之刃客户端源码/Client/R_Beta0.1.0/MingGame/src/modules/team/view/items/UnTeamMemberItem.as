package modules.team.view.items
{
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	
	import proto.common.p_map_role;
	
	public class UnTeamMemberItem extends Sprite implements IDataRenderer
	{
		private var nameText:TextField;
		private var inviteText:TextField;
		private var levelText:TextField;
		private var catText:TextField;
		public function UnTeamMemberItem() {
			
			nameText = ComponentUtil.createTextField("",10,2,null,200, 20, this);
			nameText.textColor = 0x70dfe1;
			nameText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			levelText = ComponentUtil.createTextField("",100,2,null,100,20,this);
			levelText.textColor = 0x70dfe1;
			levelText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			catText = ComponentUtil.createTextField("",178,2,null,100,20,this);
			catText.textColor = 0x70dfe1;
			catText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			inviteText = ComponentUtil.createTextField("",230,2,null,60, 20, this);
			inviteText.htmlText = HtmlUtil.link(HtmlUtil.font("邀请加入","#00ff00"),"invite",true);
			inviteText.mouseEnabled = true;
			inviteText.addEventListener(TextEvent.LINK,linkHandler);	
		}
		
		private function linkHandler(event:TextEvent):void{
			var role:p_map_role = data as p_map_role;
			Dispatch.dispatch(ModuleCommand.START_TEAM, {"role_id": role.role_id,"type_id":0});
		}
		
		protected var _data:Object;
		public function set data(value:Object):void {
			_data = value;
			if(value){
				var role:p_map_role = value as p_map_role;
				if(role){
					nameText.text = role.role_name;
					catText.text = GameConstant.CATEGORY[role.category];
					levelText.text =role.level+"级";
				}
			}
		}
		
		public function get data():Object {
			return _data;
		}	
	}
}