package modules.pet.view {
	import com.common.Constant;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.net.connection.Connection;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetConstant;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;
	import modules.vip.VipDataManager;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_skin;
	import proto.line.m_pet_add_understanding_tos;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_info_tos;

	public class PetSavvyView extends UIComponent {
		private static const succs:Array=[100, 85, 83, 30, 73, 63, 25, 52, 40, 20, 38, 25, 15, 13, 12, 0];
		private static const failBack:Array=[0, 0, 0, 0, 4, 4, 4, 7, 7, 7, 10, 10, 10, 10, 10, ""];
		private var ziZhiPro:Array=["+0", "+50", "+100", "+150", "+250", "+350", "+450", "+600", "+750", "+900", "+1050", "+1200", "+1400", "+1600", "+1800", "+2000", ""];
		private var f1:int=12300121; //初中高3中提悟符的item_id
		private var f2:int=12300122;
		private var f3:int=12300123;
		private var wxbaohu:int=12300124; //悟性保护符TYPEID
		private var usefu:int;
		private var usefuName:String;
		private var curSucc:String;
		private var wuxing:TextField;
		private var wuxingNext:TextField;
		private var wuxing_back:TextField;
		private var wuxing_back2:TextField;
		private var fu:TextField;
		private var succ:TextField;
		private var money:TextField;
		private var useProtect:CheckBox;
		private var confirmBtn:Button;
		private var pvo:p_pet;
		private var goodsList:List;
		private var tiWuFuItemVo1:BaseItemVO; //初级
		private var tiWuFuItemVo2:BaseItemVO;
		private var tiWuFuItemVo3:BaseItemVO; //高级
		
		public var headerContent:HeaderContent;
		public function PetSavvyView() {
			this.width=287;
			this.height=366;
			init();
		}

		private function init():void {
			this.y=3;
			
			headerContent = new HeaderContent();
			headerContent.y = 2;
			addChild(headerContent);
			
			var part:Sprite=new Sprite();;
			part.x=2;
			part.y=166;
			this.addChild(part);
			var tf:TextFormat=Style.textFormat;

			var line:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y=112;
			line.width=382;
			part.addChild(line);
			
			var txt1:TextField=ComponentUtil.createTextField("", 4, 10, tf, 220, 22, part);
			txt1.htmlText="从右侧选择需要提悟的<font color=\"#00FF00\">宠物</font>和<font color=\"#00FF00\">提悟符</font>";
			var txt2:TextField=ComponentUtil.createTextField("", 4, 33, tf, 160, 22, part);
			txt2.htmlText="提悟成功可提升宠物<font color=\"#00FF00\">资质</font>";

			var txt3:TextField=ComponentUtil.createTextField("", 4, 75, tf, 160, 22, part);
			txt3.htmlText="悟性最高可到：<font color=\"#FFFF00\">15</font>";

			wuxing=ComponentUtil.createTextField("", 4, 275, tf, 200, 22, part);
			wuxingNext=ComponentUtil.createTextField("下一等级 所有资质加100", 4, 300-166, tf, 200, 22, part);
			succ=ComponentUtil.createTextField("提悟成功：", 4, 325-166, tf, 220, 22, part);
			succ.mouseEnabled=true;
			succ.addEventListener(TextEvent.LINK, succLinkHandler);
			wuxing_back=ComponentUtil.createTextField("", 4, 350-166, tf, 160, 22, part);
			wuxing_back2=ComponentUtil.createTextField("", 4, 375-166, tf, 160, 22, part);
			wuxing_back.textColor=0xffff00;

			var money:TextField=ComponentUtil.createTextField("", 4, 53, tf, 160, 22, part);
			money.htmlText=HtmlUtil.font2("费用：", 0xFFFFFF) + HtmlUtil.font2("10两", 0xECE8BB);
			var btnBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"btn_bg");
			btnBg.x = 260;
			btnBg.y = 152;
			part.addChild(btnBg);
			confirmBtn=ComponentUtil.createButton("", 272, 172, 74, 74, part);
			confirmBtn.addEventListener(MouseEvent.CLICK, onConfirm);
			confirmBtn.bgSkin=Style.getButtonSkin("name_tiwu", "", "", null, GameConfig.T1_VIEWUI);
			

			useProtect=new CheckBox;
			useProtect.textFormat=Constant.TEXTFORMAT_DEFAULT;
			useProtect.text="使用悟性保护符";
			useProtect.x=240;
			useProtect.y=290-166;
			useProtect.addEventListener(Event.CHANGE, onProtectChanged);
			part.addChild(useProtect);

			var partPet2:UIComponent = ComponentUtil.createUIComponent(381,176,158,230);
			Style.setBorderSkin(partPet2);
			
			var tfy:TextFormat=new TextFormat(null, null, 0xffff00);
		
			ComponentUtil.createTextField("选择提悟符", 6, 4, tfy, 146, 22, partPet2);
			fu=ComponentUtil.createTextField("最低需要", 6, 25, tf, 146, 22, partPet2);
		
			var arr:Array=new Array();
			tiWuFuItemVo1=ItemLocator.getInstance().getObject(f1);
			tiWuFuItemVo2=ItemLocator.getInstance().getObject(f2);
			tiWuFuItemVo3=ItemLocator.getInstance().getObject(f3);
			arr.push(tiWuFuItemVo1);
			arr.push(tiWuFuItemVo2);
			arr.push(tiWuFuItemVo3);
			
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
			goodsList.verticalScrollPolicy=ScrollPolicy.OFF;
			partPet2.addChild(goodsList);
			addChild(partPet2);

		}

		private function succLinkHandler(e:Event):void {
			Dispatch.dispatch(ModuleCommand.VIP_PANEL);
		}

		public function updateList(pets:Array,count:int):void {
			headerContent.updateList(pets,count);
		}

		private function onPetItemClick(e:ItemEvent):void {
			var p:p_pet_id_name=e.selectItem as p_pet_id_name;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=p.pet_id;
			vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
			PetModule.getInstance().send(vo);
		}

		public function makeUseFu(info:p_pet):void {
			headerContent.updateInfo(info);
			var p:p_pet_id_name=headerContent.getSelectedItem();
			if (p == null)
				return;
			if (info.pet_id == p.pet_id) {

				wuxing.htmlText="当前悟性：" + info.understanding + " （所有资质<font color=\'#00ff00\'>" + ziZhiPro[info.understanding] + "</font>）";
				wuxingNext.htmlText="下一等级所有资质<font color=\'#00ff00\'>" + ziZhiPro[info.understanding + 1] + "</font>";
				wuxingNext.visible=true;
				if (info.understanding < 0 || info.understanding > 15) {
					throw new Error("宠物技能超出范围:" + info.understanding);
				}
				wuxing_back.text="失败时悟性掉回：" + failBack[info.understanding];
				wuxing_back2.visible=true;
				confirmBtn.enabled=true;
				fu.visible=true;
				if (info.understanding >= 0 && info.understanding < 4) {
					usefu=f1;
					usefuName="【初级提悟符】";
					wuxing_back2.text="悟性到4时不再掉落";
				} else if (info.understanding == 4) {
					usefu=f1;
					usefuName="【初级提悟符】";
					wuxing_back.text="失败时悟性不掉落";
					wuxing_back2.visible=false;
				} else if (info.understanding >= 5 && info.understanding < 7) {
					usefu=f2;
					usefuName="【中级提悟符】";
					wuxing_back2.text="悟性到7时不再掉落";
				} else if (info.understanding == 7) {
					usefu=f2;
					usefuName="【中级提悟符】";
					wuxing_back.text="失败时悟性不掉落";
					wuxing_back2.visible=false;
				} else if (info.understanding >= 8 && info.understanding < 10) {
					usefu=f2;
					usefuName="【中级提悟符】";
					wuxing_back2.text="悟性到10时不再掉落";
				} else if (info.understanding == 10) {
					usefu=f3;
					usefuName="【高级提悟符】";
					wuxing_back.text="失败时悟性不掉落";
					wuxing_back2.visible=false;
				} else if (info.understanding >= 11 && info.understanding < 15) {
					usefu=f3;
					usefuName="【高级提悟符】";
					wuxing_back2.text="悟性最高可达15";
				} else {
					usefu=0;
					fu.visible=false;
					wuxing_back2.text="该宠物已达顶级悟性！";
					wuxingNext.visible=false;
					confirmBtn.enabled=false;
				}
				fu.htmlText=HtmlUtil.font2("最低需要：", 0xffffff) + HtmlUtil.font2(usefuName, 0x3ce451);
				curSucc=succs[info.understanding] + "%";
				succ.htmlText=HtmlUtil.font2("提悟", 0xffffff) + HtmlUtil.font2(curSucc, 0x3ce451) + HtmlUtil.font2("成功 ", 0xffffff) + HtmlUtil.font2(VipDataManager.getInstance().getPetUnderstandingRateAdd(), 0xff0000);
				pvo=info;
			}
		}
		private var recordFailBack:String="";

		private function onProtectChanged(e:Event):void {
			if (useProtect.selected == true) {
				recordFailBack=wuxing_back.text;
				var item:BaseItemVO=PackManager.getInstance().getGoodsVOByType(wxbaohu);
				if (item == null) {
					Tips.getInstance().addTipsMsg("【悟性保护符】数量不足");
					useProtect.selected=false;
				} else {
					wuxing_back.text="失败时悟性不掉回";
				}
			} else {
				wuxing_back.text=recordFailBack;
			}
		}

		/**
		 * 使用哪种提悟符规则
		 * @param e
		 *
		 */
		private function onConfirm(e:MouseEvent):void {
			var item:p_pet_id_name=headerContent.list.selectedItem as p_pet_id_name;
			if (item == null) {
				Tips.getInstance().addTipsMsg("请先选择需要提悟的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == item.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "提悟", exeCallBack, null, "召回宠物");
				return;
			}
			var itemUse:BaseItemVO=goodsList.selectedItem as BaseItemVO;
			if (itemUse == null) {
				Tips.getInstance().addTipsMsg("请先选择提悟符");
				return;
			}
			var itemNum:int=PackManager.getInstance().getGoodsNumByTypeId(itemUse.typeId);
			if (itemNum <= 0) {
				Tips.getInstance().addTipsMsg("选择的提悟符数量不足");
				updateUseItemNum();
				return;
			}
			var vo:m_pet_add_understanding_tos=new m_pet_add_understanding_tos;
			vo.pet_id=item.pet_id;
			vo.item_type=itemUse.typeId;
			vo.use_protect=useProtect.selected;
			PetModule.getInstance().send(vo);
		}

		private function exeCallBack():void {
			if (PetInfoView.callBackAbled == false) {
				Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
				return;
			}
			var vo:m_pet_call_back_tos=new m_pet_call_back_tos;
			vo.pet_id=PetDataManager.thePet.pet_id;
			Connection.getInstance().sendMessage(vo);
			PetInfoView.setSummonAbledFalse(); //限制按钮时间
			PetInfoView.setCallBackAbledFalse();
		}

		public function updateUseItemNum(e:Event=null):void {
			tiWuFuItemVo1.num=PackManager.getInstance().getGoodsNumByTypeId(f1);
			tiWuFuItemVo2.num=PackManager.getInstance().getGoodsNumByTypeId(f2);
			;
			tiWuFuItemVo3.num=PackManager.getInstance().getGoodsNumByTypeId(f3);
			;
			goodsList.invalidateList();
		}

		public function stopAvatar():void {
			headerContent.stopAvatar();
		}

		public function startAvatar():void {
			headerContent.startAvatar();
		}
	}
}