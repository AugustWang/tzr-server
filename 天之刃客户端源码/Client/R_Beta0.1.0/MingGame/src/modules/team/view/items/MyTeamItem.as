package modules.team.view.items
{
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarBMC;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarII;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.team.TeamConstant;
	
	import proto.line.p_team_role;
	
	public class MyTeamItem extends UIComponent
	{
		private var jobBtn:Button;
		private var bodyContainer:UIComponent;
		private var levelText:TextField;
		private var nameText:TextField;
		private var avatar:AvatarII;
		private var headerIcon:Bitmap;
		private var indexIcon:Bitmap;
		private var categorText:TextField;
		public function MyTeamItem()
		{
			super();
			width = 126;
			height = 200;
			Style.setBorderSkin(this);
			
			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			tiao.width=118;
			tiao.y=170;
			tiao.x=4;
			addChild(tiao);
			
			avatar = new AvatarII();
			avatar.y = 140;
			avatar.x = 65;
			avatar.isPerson = true;
			addChild(avatar);
			
			var ctf:TextFormat = new TextFormat();
			ctf.color = 0x70dfe1;
			categorText = ComponentUtil.createTextField("",5,154,ctf,100,20,this);
			
			var ltf:TextFormat = new TextFormat();
			ltf.color = 0x70dfe1;
			ltf.align = TextFormatAlign.RIGHT;
			levelText = ComponentUtil.createTextField("",0,154,ltf,121,20,this);
			nameText = ComponentUtil.createTextField("",0,height - 27,Style.centerTextFormat,width,20,this);
			nameText.filters = FilterCommon.FONT_BLACK_FILTERS;
		}
		
		private var _jobType:int = TeamConstant.TEAM_DY;
		public function set jobType(value:int):void{
			_jobType = value;
			if(_jobType == TeamConstant.TEAM_DY){
				if(headerIcon && headerIcon.parent){
					headerIcon.parent.removeChild(headerIcon);
				}
			}else{
				if(!headerIcon){
					headerIcon = Style.getBitmap(GameConfig.T1_VIEWUI,"team_header_icon");
					headerIcon.x=headerIcon.y=6;
				}
				addChild(headerIcon);
			}
		}
		
		public function set index(value:int):void{
			indexIcon = Style.getBitmap(GameConfig.T1_VIEWUI,"team_member_icon_"+(value+1));
			indexIcon.x=103;
			indexIcon.y=6;
			addChild(indexIcon);
		}
		
		public function get jobType():int
		{
			return _jobType;
		}
		
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				var role:p_team_role = value as p_team_role;
				categorText.htmlText = HtmlUtil.font(GameConstant.CATEGORY[role.category],"#70dfe1");
				nameText.htmlText = HtmlUtil.font(role.role_name,"#fffd4b");
				levelText.htmlText = HtmlUtil.font(role.level+"级","#70dfe1");
				avatar.visible = true;
				avatar.category = role.category;
				avatar.sex = role.sex;
				avatar.initSkin(role.skin);
				avatar.play(AvatarConstant.ACTION_STAND,AvatarConstant.DIR_DOWN,8,true);
				indexIcon.visible=true;
			}else{
				categorText.text = "";
				nameText.text = "";
				levelText.text = "";
				avatar.stop();
				avatar.visible = false;
				indexIcon.visible = false;
			}
		}
	}
}