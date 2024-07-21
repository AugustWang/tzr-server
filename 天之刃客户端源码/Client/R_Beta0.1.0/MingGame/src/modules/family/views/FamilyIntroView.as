package modules.family.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyModule;
	
	public class FamilyIntroView extends Sprite
	{
		private var familyInfoBg:Sprite;
		
		public function FamilyIntroView(){
			init();
		}
		
		private function init():void{
			var titleBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			titleBg.x = 3;
			titleBg.y = 2;
			titleBg.width = 460;
			addChild(titleBg);
			
			var textTitle:TextField = ComponentUtil.createTextField("门派介绍", 210, 4, null, 100);
			textTitle.textColor =0xFFFF00;
			addChild(textTitle);
			
			var tf:TextFormat = new TextFormat;
			tf.leading = 8;
			tf.color = 0xFFFFFF;
			var textDesc:TextField = ComponentUtil.createTextField("", 5, 35, tf, 425);
			textDesc.text = "1. 等级10级以上可加入门派，20级以上可创建门派；\n2. 参加门派拉镖、打门派BOSS等门派活动可获海量经验奖励，快速升级；\n3. 加入门派，参加国运拉镖、跑商等活动可获巨额的银子回报；";
			this.addChild(textDesc);
			
			var midBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			midBg.x = 3;
			midBg.y = 106;
			midBg.width = 460;
			addChild(midBg);
			
			
			var textTitle2:TextField = ComponentUtil.createTextField("加入门派", 210, 107, null, 100);
			textTitle2.textColor =0xFFFF00;
			addChild(textTitle2);
			
			var textJoinDesc:TextField = ComponentUtil.createTextField("", 5, 135, null, 425);
			textJoinDesc.htmlText = "闯荡江湖，缔造传奇，你需要强大的门派做后盾。";
			this.addChild(textJoinDesc);
			
			var btnJoin:Button = ComponentUtil.createButton("加入门派", 205, 165, 70, 25, this);
			btnJoin.addEventListener(MouseEvent.CLICK, joinFamily);
			
			var btmBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			btmBg.x = 3;
			btmBg.y = 200;
			btmBg.width = 459;
			addChild(btmBg);
			
			var textTitle3:TextField = ComponentUtil.createTextField("创建门派", 210, 201, null, 100);
			textTitle3.textColor =0xFFFF00;
			addChild(textTitle3);
			
			var textJoinJoin:TextField = ComponentUtil.createTextField("", 5, 230, null, 422);
			textJoinJoin.multiline = true;
			textJoinJoin.htmlText = "呼朋唤友，自立门户，打造强横势力，共铸天之刃。";
			this.addChild(textJoinJoin);
			
			var btnCreate:Button = ComponentUtil.createButton("创建门派", 205, 266, 70, 25, this);
			btnCreate.addEventListener(MouseEvent.CLICK, createFamily);
		}
		
		private function joinFamily(e:Event):void
		{
			(this.parent.parent.parent as NoFamilyView).tab.selectedIndex = 1;
		}
		
		private function createFamily(e:Event):void
		{
			FamilyModule.getInstance().openCreateFamily();
		}
	}
}