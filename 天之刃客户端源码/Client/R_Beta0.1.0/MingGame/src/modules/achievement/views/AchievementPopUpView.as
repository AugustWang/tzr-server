package modules.achievement.views
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.achievement.vo.AchievementGroupVO;
	import modules.achievement.vo.AchievementVO;
	
	public class AchievementPopUpView extends UIComponent
	{
		private var finishQueue:Array;
		private var isPopUp:Boolean = false;
		
		
		private var nameText:TextField;
		private var icon:Image;
		private var pointText:TextField;
		private var desc:TextField;
		private var hideTimeOut:int;
		private var showTimeOut:int;
		
		public function AchievementPopUpView()
		{
			super();
			initView();
		}
		
		private function initView():void{
			width = 400;
			height = 50;
			mouseChildren = false;
			Style.setBorderSkin(this);
			
			var tf:TextFormat = Style.themeTextFormat;
			nameText = ComponentUtil.createTextField("",40,3,tf,150,20,this);
			nameText.textColor = 0x00ff00;
			icon = new Image();
			icon.x = 5;
			icon.y = 10;
			addChild(icon);
			
			pointText = ComponentUtil.createTextField("",350,3,tf,40,20,this);
			
			desc = ComponentUtil.createTextField("",40,22,tf,270,50,this);
			desc.wordWrap = true;
			desc.multiline = true;
			addChild(desc);
			
			var completeBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"complete_s");
			completeBg.y = 2;
			completeBg.x = 170;
			addChild(completeBg);
		}
		
		override public function set data(vo:Object):void{
			super.data = vo;
			if(vo is AchievementVO){
				var achievementVO:AchievementVO = vo as AchievementVO;
				nameText.text = "成就名称："+achievementVO.name;
				pointText.text = "+"+achievementVO.points;
				desc.text = achievementVO.desc;
				if(achievementVO.path && achievementVO.path !=""){
					icon.source = achievementVO.path;
				}else{
					icon.source = achievementVO.smallGroup.path;
				}
			}else if(vo is AchievementGroupVO){
				var groupVO:AchievementGroupVO = vo as AchievementGroupVO;
				nameText.text = "成就名称："+groupVO.name;
				pointText.text = "";
				desc.text = groupVO.desc;
				icon.source = achievementVO.smallGroup.path;
			}
		}
		
		public function show():void{
			isPopUp = true;
			y = GlobalObjectManager.GAME_HEIGHT-130;
			x = GlobalObjectManager.GAME_WIDTH-width >> 1;
			WindowManager.getInstance().openDialog(this,false);
			hideTimeOut = setTimeout(hide,10000);
		}
		
		public function hide():void{
			isPopUp = false;
			WindowManager.getInstance().closeDialog(this);
			showTimeOut = setTimeout(showPopUpVO,3000);
		}
		
		public function showPopUpVO():void{
			if(finishQueue.length > 0 ){
				addPopUpVO(finishQueue.shift());
			}
		}
		
		public function addPopUpVO(vo:Object):void{
			if(finishQueue == null){
				finishQueue = [];
			}
			if(isPopUp){
				finishQueue.push(vo);
			}else{
				data = vo;
				show();
			}
		}

	}
}