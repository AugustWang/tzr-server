package modules.help
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.Dispatch;
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	import modules.ModuleCommand;
	import modules.educate.EducateModule;
	import modules.friend.FriendsModule;
	import modules.market.MarketModule;
	import modules.finery.FineryModule;
	import modules.rank.RankModule;
	
	public class IntroducePanel extends BasePanel
	{
		private var scrollText:VScrollText;
		public var closeFunc:Function;
		public function IntroducePanel(key:String=null)
		{
			super(key);
		}
		
		override protected function init():void{
			width = 482;
			height = 386;
			
			mouseEnabled=true;
			mouseChildren=true;
			
			addContentBG(5,5);
			var bg:UIComponent = ComponentUtil.createUIComponent(9,8,465,332);
			Style.setBorderSkin(bg);
			addChild(bg);
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF6F5CD);
			tf.leading = 5;
			
			scrollText = new VScrollText();
			scrollText.x = 8;
			scrollText.y = 2;
			scrollText.width = 456;
			scrollText.height = 326;
			scrollText.direction = ScrollDirection.RIGHT;
			scrollText.textField.defaultTextFormat = tf;
			scrollText.addEventListener(TextEvent.LINK, onTextLink);
			bg.addChild(scrollText);
		}
			
		public function onTextLink(e:TextEvent):void
		{
			switch(e.text){
				case "ui_tiangongkaiwu":
					Dispatch.dispatch(ModuleCommand.OPEN_EQUIP_BOX);
					break;
				case "ui_pet_tiwu":
					Dispatch.dispatch(ModuleCommand.OPEN_PET_SAVVY);
					break;
				case "ui_pet_xiling":
					Dispatch.dispatch(ModuleCommand.OPEN_PET_APTITUDE);
					break;
				case "ui_pet_xunlian":
					Dispatch.dispatch(ModuleCommand.OPEN_PET_FEED);
					break;
				case "ui_skill_xunchong":
					Dispatch.dispatch(ModuleCommand.OPEN_TRAIN_PET);
					break;
				case "ui_market":
					MarketModule.getInstance().openMarketView();
					break;
				case "ui_market_pet":
					MarketModule.getInstance().openMarketView(111);
					break;
				case "ui_act_jingyan":
					ActivityModule.getInstance().openActivityWin(2);//活动-经验
					break;
				case "ui_act_libao":
					ActivityModule.getInstance().openActivityWin(5);//活动-礼包
					break;
				case "ui_act_jiangli":
					ActivityModule.getInstance().openActivityWin(6)//活动-奖励
					break;
				case "ui_shop":
					Dispatch.dispatch(ModuleCommand.OPEN_SHOP_PANEL);
					break;
				case "ui_shop_pet":
					Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP);
					break;
				case "ui_ranking_shenbing":
					RankModule.getInstance().openRankWindow(2);//神兵
					break;
				case "ui_social_zhaoshifu":
					FriendsModule.getInstance().openEducateView();
					EducateModule.getInstance().getEducateView().changeView(0);
					break;
				case "ui_social_zhaotudi":
					FriendsModule.getInstance().openEducateView();
					EducateModule.getInstance().getEducateView().changeView(1);
					break;
				case "ui_social_zongzu":
					FriendsModule.getInstance().openFamilyView();
					break;
				case "ui_pet_skill":
					Dispatch.dispatch(ModuleCommand.OPEN_PET_SKILL);
					break;
				case "ui_cailiaohecheng":
					Dispatch.dispatch(ModuleCommand.OPEN_EQUIP_COMPOSE);
					break;
				case "ui_zhuangbeijinglian":
					Dispatch.dispatch(ModuleCommand.OPEN_EQUIP_REFINE);
					break;
				case "goto_poyanghu":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100135");
					break;
				case "goto_npc_shitu":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100121");
					break;
				case "goto_npc_zongzu":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100120");
					break;
				case "goto_npc_tiejiang":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100114");
					break;
				case "goto_npc_fangju":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100122");
					break;
				case "goto_npc_wuqi":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100113");
					break;
				case "goto_npc_zhangsanfeng":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100136");
					break;
				case "goto_npc_baozang":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100129");
					break;
				case "goto_npc_yunbiao":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100102");
					break;
				case "goto_npc_shangmao":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100104");
					break;
				case "goto_npc_citan":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100105");
					break;
				case "goto_npc_chefu":
					PathUtil.findNpcAndOpen("1" + GlobalObjectManager.getInstance().getRoleFactionID() + "100100");
					break;
			}
		}
		
		private function onMouseClick(event:MouseEvent):void{
			closeWindow();
		}
		
		private var introduceId:int;
		public function setIntroduceId(id:int):void{
			introduceId = id;
			if(IntroduceHelper.getInstance().init){
				var desc:Object = IntroduceHelper.getInstance().getIntroduce(id);
				if(desc){
					this.title = desc.name;
					scrollText.htmlText = desc.desc;
				}
			}else{
				IntroduceHelper.getInstance().load()
				IntroduceHelper.getInstance().addEventListener(Event.COMPLETE,onCompelete);
			}
		}
		
		private function onCompelete(event:Event):void{
			setIntroduceId(introduceId);
		}
		
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow();
			if(closeFunc != null){
				closeFunc.apply(null,null);
			}
		}
		
	}
}