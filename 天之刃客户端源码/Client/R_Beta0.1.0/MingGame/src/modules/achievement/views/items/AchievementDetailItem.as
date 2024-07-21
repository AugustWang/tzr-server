package modules.achievement.views.items
{
	import com.common.GlobalObjectManager;
	import com.components.GoodsBox;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.achievement.AchievementConstant;
	import modules.achievement.AchievementModule;
	import modules.achievement.vo.AchievementVO;
	
	public class AchievementDetailItem extends UIComponent
	{
		private var nameText:TextField;
		private var icon:Image;
		private var pointText:TextField;
		private var desc:TextField;
		private var goodsSprite:Sprite;
		private var goodsArray:Array;
		
		private var stepText:TextField;
		private var stepBar:ProgressBar;
		private var takeReward:Button;
		private var statusIcon:Bitmap;
		private var finishName:TextField;
		public function AchievementDetailItem()
		{
			super();
			width = 410;
			height = 62;
			Style.setBorder1Skin(this);
			
			var tf:TextFormat = Style.themeTextFormat;
			
			nameText = ComponentUtil.createTextField("",40,3,tf,150,20,this);
			nameText.textColor = 0x00ff00;
			icon = new Image();
			icon.x = 5;
			icon.y = 17;
			addChild(icon);
			
			pointText = ComponentUtil.createTextField("",350,3,tf,40,20,this);
			
			desc = ComponentUtil.createTextField("",40,22,tf,270,50,this);
			desc.wordWrap = true;
			desc.multiline = true;
			addChild(desc);
			
			goodsSprite = new Sprite();
			goodsSprite.y = 20;
			addChild(goodsSprite);
			goodsArray = [];
			
			statusIcon = new Bitmap();
			statusIcon.x = 160;
			statusIcon.y = 5;
			addChild(statusIcon);
		}
		
		private var achievementVO:AchievementVO = data as AchievementVO;
		override public function set data(value:Object):void{
			super.data = value;
			if(achievementVO){
				achievementVO.removeEventListener(Event.CHANGE,changeHandler);
			}
			achievementVO = data as AchievementVO;
			if(achievementVO){
				achievementVO.addEventListener(Event.CHANGE,changeHandler);
				nameText.text = "成就名称："+achievementVO.name;
				pointText.text = "+"+achievementVO.points;
				if(achievementVO.desc){
					desc.text = achievementVO.desc;
				}else{
					desc.text = "";
				}
				if(achievementVO.path && achievementVO.path !=""){
					icon.source = achievementVO.path;
				}else{
					icon.source = achievementVO.smallGroup.path;
				}
				var size:int = achievementVO.goods ? achievementVO.goods.length : 0;
				var i:int = 1;
				var needCreate:int = size - goodsArray.length;
				var goodsBox:GoodsBox;
				if(needCreate > 0){
					while(i <= needCreate){
						goodsArray.push(new GoodsBox());
						needCreate--;
					}
				}else if(needCreate < 0){
					while(needCreate < 0){
						goodsBox = goodsArray.pop();
						if(goodsBox && goodsBox.parent){
							goodsBox.parent.removeChild(goodsBox);
						}
						needCreate++;
					}
				}
				for(i=0;i<size;i++){
					goodsBox = goodsArray[i];
					goodsBox.x = i*38;
					goodsBox.baseItemVO = achievementVO.goods[i];
					goodsSprite.addChild(goodsBox);
				}
				if(goodsBox){
					goodsSprite.x = 400 - (goodsBox.x+36);
				}
				changeHandler(null);
			}
			
		}
		
		private function changeHandler(event:Event):void{
			if(achievementVO.totalStep > 0){
				showStepBar();
			}else{
				hideStepBar();
			}
			if(achievementVO.bigGroup.global == 0){
				if(achievementVO.state == AchievementConstant.STATE_FINISH && achievementVO.hasGoodsReward){
					showTakeRewardButton();
				}else{
					hideTakeRewardButton();
				}
			}else{
				var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
				if(achievementVO.state == AchievementConstant.STATE_FINISH && achievementVO.hasGoodsReward && userId == achievementVO.roleId){
					showTakeRewardButton();
				}else{
					hideTakeRewardButton();
				}
			}
			if(achievementVO.state != AchievementConstant.STATE_DOING && achievementVO.bigGroup.global == 1){
				if(finishName == null){
					finishName = ComponentUtil.createTextField("成就完成者：",40,40,Style.themeTextFormat,150,25,this);
					finishName.textColor = 0xffff00;
				}
				finishName.htmlText = "成就完成者："+HtmlUtil.font(achievementVO.roleName,"#ffffff");
			}else if(finishName){
				finishName.htmlText = "";
			}
			initStatusIcon();
		}
		
		private function initStatusIcon():void{
			if(achievementVO.state == 3 || (achievementVO.state == 2 && !achievementVO.hasGoodsReward)){
				statusIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"lingqu");
				statusIcon.width = 63;
				statusIcon.height = 46;
			}else if(achievementVO.state == 2){
				statusIcon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"complete_s");
				statusIcon.width = 63;
				statusIcon.height = 46;
			}else{
				statusIcon.bitmapData = null;
			}
		}
		
		private function showStepBar():void{
			if(stepBar == null){
				stepText = ComponentUtil.createTextField("完成进度：",40,40,Style.themeTextFormat,70,25,this);
				stepText.textColor = 0xffff00;
				stepBar = new ProgressBar();
				stepBar.bgSkin = Style.getSkin("processBarBg",GameConfig.ACHIEVEMENT_UI,new Rectangle(10,3,101,2));
				stepBar.bar = Style.getBitmap(GameConfig.ACHIEVEMENT_UI,"processBar");
				stepBar.x = stepText.x+stepText.width+5;
				stepBar.y = stepText.y+4;
				stepBar.width = 100;
				stepBar.height = 14;
				addChild(stepBar); 
			}
			stepText.visible = true;
			stepBar.visible = true;
			stepBar.htmlText = achievementVO.currentStep+"/"+achievementVO.totalStep;
			stepBar.value = achievementVO.currentStep/achievementVO.totalStep;
		}
		
		private function hideStepBar():void{
			if(stepText){
				stepText.visible = false;
			}
			if(stepBar){
				stepBar.visible = false;
			}
		}
		
		private function showTakeRewardButton():void{
			if(takeReward == null){
				takeReward = ComponentUtil.createButton("领取奖励",265,35,60,25,this);
				takeReward.addEventListener(MouseEvent.CLICK,takeRewardHandler);
			}
			takeReward.visible = true;
		}
		
		private function hideTakeRewardButton():void{
			if(takeReward){
				takeReward.visible = false;
			}
		}
		
		private function takeRewardHandler(event:MouseEvent):void{
			AchievementModule.getInstance().getAchievementAward(achievementVO.id);	
		}
	}
}