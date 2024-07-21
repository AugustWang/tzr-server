package modules.pet.view

{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	1

	import flashx.textLayout.formats.Float;

	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;

	import proto.common.p_pet;
	import proto.common.p_pet_feed;
	import proto.common.p_pet_id_name;
	import proto.common.p_skin;
	import proto.line.m_pet_feed_begin_toc;
	import proto.line.m_pet_feed_begin_tos;
	import proto.line.m_pet_feed_commit_toc;
	import proto.line.m_pet_feed_commit_tos;
	import proto.line.m_pet_feed_give_up_toc;
	import proto.line.m_pet_feed_give_up_tos;
	import proto.line.m_pet_feed_info_toc;
	import proto.line.m_pet_feed_info_tos;
	import proto.line.m_pet_feed_over_toc;
	import proto.line.m_pet_feed_star_up_toc;
	import proto.line.m_pet_feed_star_up_tos;
	import proto.line.m_pet_info_tos;
	import modules.vip.VipModule;
	import flash.display.Bitmap;
	import modules.shop.ShopModule;

	public class PetFeedView extends UIComponent {
		private var levelTxt:TextField;
		private var expTxt:TextField;
		private var itemNumTxt:TextField;
		private var todayFeedNumTxt:TextField;
		private var starLevelTxt:TextField;
		private var levelExpTxt:TextField;
		private var nextLevelExpTxt:TextField;
		private var feedTypeTxt:TextField;
		private var feedTimeTxt:TextField;
		private var freeStarUpTxt:TextField;
		private var starUpPriceTxt:TextField;
		private var starUpTipTxt:TextField;
		private var useGoldCommitTxt:TextField;
		private var extraFeedGoldTxt:TextField;
		
		private var goodsList:List;
		private var partPet:Sprite;

		private var beginBtn:Button;
		private var giveUpBtn:Button;
		private var commitBtn:Button;
		private var starUpBtn:Button;


		private var pvo:p_pet_feed;
		private var commitType:int;
		private var itemNum:int;
		private var timer:Timer;
		private var timeLeft:int=0;
		private var alertStr:String;
		private var xunLianPaiItemVo:BaseItemVO;
		private var petLevel:int=0;
		private var petExp:int=0;
		private var petNextExp:int=0;

		public var headerContent:HeaderContent;
		
		public function PetFeedView() {
			this.width=470;
			this.height=275;
			init();
		}

		private function init():void {
			this.y=3;
			var tf:TextFormat=new TextFormat(null, null, 0xFFFFFF);
			var tfg:TextFormat=new TextFormat(null, null, 0x3ce451);
			var tfw:TextFormat=new TextFormat(null, null, 0xffffff);
			var tfy:TextFormat=new TextFormat(null, null, 0xffff00);
			var btfg:TextFormat=new TextFormat(null, null, 0x3ce451, true);

			headerContent = new HeaderContent();
			headerContent.y = 2;
			addChild(headerContent);
			
			var part3:Sprite=new Sprite();
			part3.y=167;
			part3.x=2;

			var line:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y=141;
			line.width=382;
			part3.addChild(line);

			levelTxt=ComponentUtil.createTextField("宠物等级：", 8, 20, tf, 160, 22, part3);
			expTxt=ComponentUtil.createTextField("宠物经验：", 188, 20, tfw, 180, 22, part3);

			var tmpTxt:TextField=ComponentUtil.createTextField("", 4, 2, btfg, 250, 22, part3);
			tmpTxt.htmlText="星级持续一周，周一凌晨<font color='#FFFF00'>  00:00 </font> 回归1星";
			starLevelTxt=ComponentUtil.createTextField("训练星级：", 8, 44, tf, 250, 22, part3);
			levelExpTxt=ComponentUtil.createTextField("训练获得经验：", 8, 68, tf, 126, 22, part3);
			nextLevelExpTxt=ComponentUtil.createTextField("下一星奖励：", 188, 68, tf, 128, 22, part3);
			feedTypeTxt=ComponentUtil.createTextField("训练方式：", 8, 92, tf, 160, 22, part3);
			todayFeedNumTxt=ComponentUtil.createTextField("今天训练次数:", 188, 92, tf, 160, 22, part3);
			feedTimeTxt=ComponentUtil.createTextField("持续时间：    训练期间宠物不能出战", 8, 116, tf, 254, 22, part3);


			useGoldCommitTxt=ComponentUtil.createTextField("", 105, 215, tf, 200, 22, part3);
			useGoldCommitTxt.htmlText="<font color='#FFFF00'>5</font> 元宝";
			extraFeedGoldTxt=ComponentUtil.createTextField("", 105, 215, tf, 60, 22, part3);
			freeStarUpTxt=ComponentUtil.createTextField("", 245, 215, tf, 80, 22, part3);
			freeStarUpTxt.htmlText="免费 <font color='#FFFF00'>1</font> 次";
			starUpPriceTxt=ComponentUtil.createTextField("", 245, 215, tf, 80, 22, part3);
			starUpPriceTxt.htmlText="<font color='#FFFF00'>5</font> 元宝";
			starUpTipTxt=ComponentUtil.createTextField("已经达到最高星级", 220, 215, tf, 130, 22, part3);
			
			var tip:TextField = ComponentUtil.createTextField("", 8,145, tf, 365, 40, part3);
			tip.wordWrap = true;
			tip.multiline = true;
			tip.htmlText = "训练可以帮助你的宠物"+HtmlUtil.font("快速成才","#00ff00")+"，提升星级后宠物训练"+HtmlUtil.font("得到更多的宠物经验","#00ff00");

			beginBtn=ComponentUtil.createButton("开始训练", 85, 185, 80, 24, part3);
			beginBtn.addEventListener(MouseEvent.CLICK, toBeginFeed);


			starUpBtn=ComponentUtil.createButton("提升星级", 210, 185, 80, 24, part3);
			starUpBtn.addEventListener(MouseEvent.CLICK, toStarUp);


			commitBtn=ComponentUtil.createButton("立即完成", 85, 185, 80, 24, part3);
			commitBtn.addEventListener(MouseEvent.CLICK, commit);


			giveUpBtn=ComponentUtil.createButton("放弃训练", 210, 185, 80, 24, part3);
			giveUpBtn.addEventListener(MouseEvent.CLICK, toGiveUp);

			if (timer == null) {
				timer=new Timer(1000, 0);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
			}

			var partPet2:UIComponent = ComponentUtil.createUIComponent(384,176,158,230);
			Style.setBorderSkin(partPet2);
			
			itemNumTxt=ComponentUtil.createTextField("宠物训练牌数量：",6, 5, tf, 160, 22, partPet2);
			
			xunLianPaiItemVo=ItemLocator.getInstance().getObject(12300134);
			var arr:Array=new Array();
			arr.push(xunLianPaiItemVo);
			
			goodsList=new List();
			goodsList.itemSkinLeft = 40;
			goodsList.itemSkinRight = 10;
			goodsList.x=6;
			goodsList.y=43;
			goodsList.bgSkin=null;
			goodsList.width=150;
			goodsList.height=184;
			goodsList.itemHeight=36;
			goodsList.itemRenderer=GoodsListRender;
			goodsList.addEventListener(TextEvent.LINK, updateUseItemNum);
			goodsList.dataProvider=arr;
			partPet2.addChild(goodsList);
			addChild(partPet2);

			this.addChild(part3);

		}

		public function updateList(pets:Array,count:int):void {
			headerContent.updateList(pets,count);
		}

		public function updateFeed(feedVo:p_pet_feed):void {

			this.pvo=feedVo;
			var strTmp:String="";
			for (var i:int=0; i < pvo.star_level; i++) {
				strTmp=strTmp + "★";
			}

			if (pvo.star_level <= 2)
				starLevelTxt.htmlText=HtmlUtil.font2("训练星级：", 0xAFE1EC) + HtmlUtil.font2(strTmp, 0xFFFFFF);
			else if (pvo.star_level <= 4)
				starLevelTxt.htmlText=HtmlUtil.font2("训练星级：", 0xAFE1EC) + HtmlUtil.font2(strTmp, 0x00CC99);
			else if (pvo.star_level <= 6)
				starLevelTxt.htmlText=HtmlUtil.font2("训练星级：", 0xAFE1EC) + HtmlUtil.font2(strTmp, 0x40DEF9);
			else if (pvo.star_level <= 8)
				starLevelTxt.htmlText=HtmlUtil.font2("训练星级：", 0xAFE1EC) + HtmlUtil.font2(strTmp, 0xFE00E9);
			else
				starLevelTxt.htmlText=HtmlUtil.font2("训练星级：", 0xAFE1EC) + HtmlUtil.font2(strTmp, 0xFF9000);

			levelExpTxt.htmlText=HtmlUtil.font2("训练获得经验：", 0xAFE1EC) + HtmlUtil.font2(pvo.last_feed_exp + "", 0xFFFF00);
			if (pvo.star_level < 9) {
				var nextLevelExp:int=getNextStarLevelExp(pvo.star_level + 1);
				nextLevelExpTxt.htmlText=HtmlUtil.font2("下一星奖励：", 0xAFE1EC) + HtmlUtil.font2(nextLevelExp + "", 0xFFFF00);
			} else
				nextLevelExpTxt.htmlText=HtmlUtil.font2("已达最高星级", 0xFFFF00);
			feedTypeTxt.htmlText=HtmlUtil.font2("训练方式：", 0xAFE1EC) + HtmlUtil.font2(getFeedTypeString(pvo.feed_type), 0xFFFF00);
			todayFeedNumTxt.htmlText=HtmlUtil.font2("今天训练次数： <font color='#00FF00'>" + pvo.feed_time + "</font><font color='#FFFF00'>/6</font>", 0xAFE1EC);
			starUpBtn.showToolTip=false;
			starUpTipTxt.visible=false;

			if (headerContent.list != null && headerContent.list.dataProvider != null) {

				for (var j:int=0; j < 5; j++) {
					if (headerContent.list.dataProvider[j] == null)
						break;
					var pet:p_pet_id_name=headerContent.list.dataProvider[j] as p_pet_id_name;
//					pet.name=pet.name.replace("<font color='#8d8d8d'>", "");
//					pet.name=pet.name.replace("</font>", "");
					if (pet.pet_id == pvo.pet_id && pvo.state == 3) {
//						pet.name="<font color='#8d8d8d'>" + pet.name + "</font>";
						headerContent.list.dataProvider[j]=pet;
					}
					headerContent.list.refreshItem(headerContent.list.dataProvider[j]);
				}
			}

			//如果有宠物处于训练状态
			if (pvo.state == 3) {
				extraFeedGoldTxt.visible=false;
				beginBtn.visible=false;
				starUpBtn.visible=false;
				commitBtn.visible=true;
				giveUpBtn.visible=true;
				freeStarUpTxt.visible=false;
				starUpPriceTxt.visible=false;
				timeLeft=pvo.feed_over_tick;
				if (timeLeft <= 0) {
					feedTimeTxt.htmlText="<font color='#FFFF00'>已经完成</font>    训练期间宠物不能出战";
					useGoldCommitTxt.visible=false;
					commitBtn.label="完成训练";
					giveUpBtn.enabled=false;
				} else {
					useGoldCommitTxt.visible=true;
					commitBtn.label="立即完成";
					giveUpBtn.enabled=true;
				}
				if (timeLeft > 0 && timer.running == false)
					timer.start();
			} else {
				feedTimeTxt.htmlText=HtmlUtil.font2("持续时间：<font color='#FFFF00'>" + int(pvo.feed_tick / 60) + "分钟</font>    训练期间宠物不能出战", 0xAFE1EC);
				beginBtn.visible=true;
				if (pvo.feed_time >= 6) {
					beginBtn.label="强行训练";
					extraFeedGoldTxt.visible=true;
					extraFeedGoldTxt.htmlText="<font color='#FFFF00'>" + getExtraFeedGold(pvo.feed_time) + "</font> 元宝";
				} else {
					beginBtn.label="开始训练";
					extraFeedGoldTxt.visible=false;
				}
				starUpBtn.visible=true;
				starUpBtn.enabled=true;
				commitBtn.visible=false;
				giveUpBtn.visible=false;
				useGoldCommitTxt.visible=false;
				if (pvo.star_up_flag) {
					if (pvo.free_star_up_flag) {
						freeStarUpTxt.visible=true;
						starUpPriceTxt.visible=false;
					} else {
						starUpPriceTxt.visible=true;
						freeStarUpTxt.visible=false;
					}
				} else {
					freeStarUpTxt.visible=false;
					starUpPriceTxt.visible=false;
					starUpBtn.showToolTip=true;
					starUpBtn.visible=false;
					if (pvo.star_level == 9) {
						starUpBtn.enabled=false;
						starUpTipTxt.visible=true;

					} else
						starUpBtn.setToolTip("必须完成1次当前星级的训练，才能提升到下一星级");
				}
				if (timer.running)
					timer.stop();
			}

		}

		private function getExtraFeedGold(feedTime:int):int {
			if (feedTime < 6)
				return 0;
			else if (feedTime < 11)
				return (feedTime - 5) * 2;
			else if (feedTime < 21)
				return (feedTime - 10) * 3 + 10;
			else
				return (feedTime - 20) * 5 + 40;
		}

		private function getNextStarLevelExp(starLevel:int):Number {
			var s:Number=Math.pow(1, 1.7);
			var baseExp:Number=Math.floor(Math.pow(GlobalObjectManager.getInstance().user.attr.level, 1.7)) * 10 + 2000;
			if (starLevel == 1)
				return baseExp;
			else if (starLevel == 2)
				return baseExp * 2;
			else if (starLevel == 3)
				return baseExp * 3;
			else if (starLevel == 4)
				return baseExp * 6;
			else if (starLevel == 5)
				return baseExp * 8;
			else if (starLevel == 6)
				return baseExp * 10;
			else if (starLevel == 7)
				return baseExp * 12;
			else if (starLevel == 8)
				return baseExp * 19;
			else
				return baseExp * 25;
		}

		public function updatePetLevelAndExp(petVo:p_pet):void {
			headerContent.updateInfo(petVo);
			var item:p_pet_id_name=headerContent.getSelectedItem();
			if (item == null)
				return;
			if (petVo.pet_id == item.pet_id) {
				levelTxt.htmlText=HtmlUtil.font2("宠物等级： ", 0xAFE1EC) + HtmlUtil.font2(petVo.level + "", 0xFFFF00);
				expTxt.htmlText="宠物经验：" + HtmlUtil.font2(petVo.exp + " / " + petVo.next_level_exp, 0xECE8BB);
				petLevel = petVo.level;
				petExp = petVo.exp;
				petNextExp = petVo.next_level_exp;
			}
		}

		private function onPetItemClick(e:ItemEvent):void {
			var ipname:p_pet_id_name=e.selectItem as p_pet_id_name;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=ipname.pet_id;
			vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
			PetModule.getInstance().send(vo);

		}



		private function toBeginFeed(e:MouseEvent):void {
			var item:p_pet_id_name=headerContent.list.selectedItem as p_pet_id_name;
			if (item == null) {
				Alert.show("请先选择宠物", "提示", null, null, "确定", "", null, false);
				return;
			}

			if (GlobalObjectManager.getInstance().user.attr.gold + GlobalObjectManager.getInstance().user.attr.gold_bind < getExtraFeedGold(pvo.feed_time)) {
				alertStr=Alert.show("您的元宝不足，无法强行训练！<font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
				return;
			}
			if (itemNum <= 0) {
				alertStr=Alert.show("宠物训练牌不足，可在<font color='#00FF00'><a href='event:openStore;'><u>宠物商店</u></a></font>处购买！", "提示", null, null, "确定", "", null, false, false, null, openStore);
				return;
			}
			if(GlobalObjectManager.getInstance().user.attr.level <= petLevel && petExp + pvo.last_feed_exp >= petNextExp)
			{
				alertStr=Alert.show("宠物等级不可超过主人等级，此时训练将无法获得经验。", "提示", null, null, "确定", "", null, false, false, null, null);
				return;
			}
			var vo:m_pet_feed_begin_tos=new m_pet_feed_begin_tos;
			vo.pet_id=item.pet_id;
			PetModule.getInstance().send(vo);

		}

		private function toStarUp(e:MouseEvent):void {
			if (freeStarUpTxt.visible == false && GlobalObjectManager.getInstance().user.attr.gold_bind + GlobalObjectManager.getInstance().user.attr.gold < 5) {
				alertStr=Alert.show("您的元宝不足，无法提升星级！<font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
				return;
			}
			if (pvo.star_up_flag == false) {
				Alert.show("必须完成1次当前星级的训练，才能提升到下一星级", "提示", null, null, "确定", "", null, false, false, null);
				return;
			}
			var vo:m_pet_feed_star_up_tos=new m_pet_feed_star_up_tos;
			PetModule.getInstance().send(vo);

		}

		private function commit(e:MouseEvent):void {
			if (commitBtn.label == "立即完成") {
				if (GlobalObjectManager.getInstance().user.attr.gold_bind + GlobalObjectManager.getInstance().user.attr.gold >= 5)
					toCommit(2);
				else
					alertStr=Alert.show("您的元宝不足，无法立即完成！<font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
			} else
				toCommit(1);
		}

		private function toCommit(type:int):void {
			var vo:m_pet_feed_commit_tos=new m_pet_feed_commit_tos;
			vo.pet_id=pvo.pet_id;
			vo.type=type;
			PetModule.getInstance().send(vo);
		}

		private function toGiveUp(e:MouseEvent):void {
			Alert.show("放弃训练将失去1次训练机会，宠物不能获得经验", "提示", toRealGiveUp, null, "确定", "取消", null, true, true, null);
		}

		private function toRealGiveUp():void {
			var vo:m_pet_feed_give_up_tos=new m_pet_feed_give_up_tos;
			vo.pet_id=pvo.pet_id;
			PetModule.getInstance().send(vo);
		}

		public function feedOver(pet_id:int):void {
			timeLeft=0;
			BroadcastModule.getInstance().popupWindowMsg("宠物训练结束，请按X打开宠物训练面板领取训练奖励。");
		}

		public function updateUseItemNum(e:Event=null):void {
			itemNum=PackManager.getInstance().getGoodsNumByTypeId(12300134);
			itemNumTxt.htmlText=HtmlUtil.font2("宠物训练牌数量：", 0xAFE1EC) + HtmlUtil.font2(itemNum + "", 0xFFFF00);
			xunLianPaiItemVo.num=itemNum;
			goodsList.refreshItem(xunLianPaiItemVo);
		}

		public function toGetFeedInfo():void {
			var vo:m_pet_feed_info_tos=new m_pet_feed_info_tos;
			PetModule.getInstance().send(vo);
		}

		private function getFeedTypeString(type:int):String {
			if (type == 1)
				return "给宠物洗澡";
			else if (type == 2)
				return "带领宠物散步";
			else if (type == 3)
				return "训练宠物战斗";
			else if (type == 4)
				return "带领宠物打猎";
			else if (type == 5)
				return "带领宠物游泳";
			else if (type == 6)
				return "和宠物玩耍";
			else
				return "给宠物喂食";
		}


		private function openPay(e:TextEvent):void {
			Alert.removeAlert(alertStr);
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);
		}

		private function openStore(e:TextEvent):void {
			ShopModule.getInstance().openPetShop();
			Alert.removeAlert(alertStr);
		}

		private function onTimer(e:TimerEvent=null):void {
			timeLeft--;
			if (timeLeft >= 0)
				feedTimeTxt.htmlText="<font color='#FFFF00'>" + DateFormatUtil.formatTime(timeLeft) + "</font>    训练期间宠物不能出战";
			else {
				feedTimeTxt.htmlText="<font color='#FFFF00'>已经完成</font>    训练期间宠物不能出战";
				useGoldCommitTxt.visible=false;
				commitBtn.label="完成训练";
				giveUpBtn.enabled=false;
				timer.stop();
			}
		}

		public function stopAvatar():void {
			headerContent.stopAvatar();
		}

		public function startAvatar():void {
			headerContent.startAvatar();
		}

	}
}