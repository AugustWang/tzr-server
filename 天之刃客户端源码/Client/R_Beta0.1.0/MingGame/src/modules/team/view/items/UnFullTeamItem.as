package modules.team.view.items
{
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.globals.GameConfig;
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
	
	import modules.team.TeamModule;
	
	import proto.line.p_team_nearby;
	
	public class UnFullTeamItem extends Sprite implements IDataRenderer
	{
		private var nameText:TextField;
		private var autoBitmap:Bitmap;
		private var levelText:TextField;
		private var inviteText:TextField;
		
		public function UnFullTeamItem() {
			
			nameText = ComponentUtil.createTextField("",10,2,null,200,20, this);
			nameText.textColor = 0x70dfe1;
			nameText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			levelText = ComponentUtil.createTextField("",100,2,null,100,20,this);
			levelText.textColor = 0x70dfe1;
			levelText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			autoBitmap = new Bitmap();
			autoBitmap.x = 188;
			autoBitmap.y = 4;
			addChild(autoBitmap);
			
			inviteText = ComponentUtil.createTextField("",230,2,null,60, 20, this);
			inviteText.htmlText = HtmlUtil.link(HtmlUtil.font("申请加入","#00ff00"),"invite",true);
			inviteText.mouseEnabled = true;
			inviteText.addEventListener(TextEvent.LINK,linkHandler);	
		}
		
		private function linkHandler(event:TextEvent):void{
			TeamModule.getInstance().pro.onApplyTeamTos(data.role_id);
		}
		
		protected var _data:Object;
		public function set data(value:Object):void {
			_data = value;
			if(data){
				var role:p_team_nearby = data as p_team_nearby;
				nameText.text = role.role_name;
				levelText.text = role.level+"级"+" （"+role.cur_team_number+"/"+role.sum_team_number +"）";
				if(role.auto_accept_team){
					autoBitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"team_auto_icon");
				}else{
					autoBitmap.bitmapData = null;
				}
			}else{
				autoBitmap.bitmapData = null;
			}
		}
		
		public function get data():Object {
			return _data;
		}	
	}
}