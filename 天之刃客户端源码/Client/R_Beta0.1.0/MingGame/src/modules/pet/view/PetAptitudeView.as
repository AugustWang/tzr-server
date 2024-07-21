package modules.pet.view {
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
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
	import flash.utils.Dictionary;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_skin;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_info_tos;
	import proto.line.m_pet_refresh_aptitude_tos;

	public class PetAptitudeView extends UIComponent {
		private var d1:int=12300118;
		private var d2:int=12300119;
		private var d3:int=12300120;
		private var useDrug:int;
		private var useDrugName:String;
		private var drug:TextField;
		private var confirmBtn:Button;
		private var useItem:PetSkillItem;
		private var maxZiZhi:TextField;
		private var pvo:p_pet;
		private var outAttackZZ:TextField;
		private var inAttackZZ:TextField;
		private var outDefZZ:TextField;
		private var inDefZZ:TextField;
		private var zhongjiZZ:TextField;
		private var shengmingZZ:TextField;
		private var goodsList:List;

		private var xiLingDanItemVo1:BaseItemVO; //初级
		private var xiLingDanItemVo2:BaseItemVO;
		private var xiLingDanItemVo3:BaseItemVO; //高级
		
		public var headerContent:HeaderContent;

		public function PetAptitudeView() {
			this.width=287;
			this.height=366;
			init();
		}

		private function init():void {
			this.y=3;
			var part:Sprite=new Sprite();
			part.x=2;
			part.y=166;
			this.addChild(part);

			headerContent = new HeaderContent();
			headerContent.y = 2;
			addChild(headerContent);
			
			var tf:TextFormat=Style.textFormat;
			tf.color = 0xffffff;
			
			var line:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y=100;
			line.width=382;
			part.addChild(line);
			
			var txt1:TextField=ComponentUtil.createTextField("", 4, 10, tf, 220, 22, part);
			txt1.htmlText="从右侧选择需要洗灵的<font color=\"#00FF00\">宠物</font>和<font color=\"#00FF00\">洗灵丹</font>";
			var txt2:TextField=ComponentUtil.createTextField("", 4, 33, tf, 160, 22, part);
			txt2.htmlText="洗灵成功可提升宠物<font color=\"#00FF00\">基础资质</font>";
			
			tf.color = 0x00ff00;
			ComponentUtil.createTextField("宠物当前基础资质：", 4, 270-166, tf, 220, 22, part);
			tf.color = 0xffffff;
			outAttackZZ=ComponentUtil.createTextField("外攻资质：", 30, 290-166, tf, 250, 22, part);
			inAttackZZ=ComponentUtil.createTextField("内攻资质：", 30, 308-166, tf, 250, 22, part);
			outDefZZ=ComponentUtil.createTextField("外防资质：", 30, 326-166, tf, 250, 22, part);
			inDefZZ=ComponentUtil.createTextField("内防资质：", 30, 344-166, tf, 250, 22, part);
			zhongjiZZ=ComponentUtil.createTextField("重击资质：", 30, 362-166, tf, 250, 22, part);
			shengmingZZ=ComponentUtil.createTextField("生命资质：", 30, 380-166, tf, 250, 22, part);


			var money:TextField=ComponentUtil.createTextField("", 4, 53, tf, 160, 22, part);
			money.htmlText=HtmlUtil.font2("费用：", 0xFFFFFF) + HtmlUtil.font2("50文", 0xECE8BB);

			maxZiZhi=ComponentUtil.createTextField("", 4, 75, tf, 160, 22, part);

			var btnBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"btn_bg");
			btnBg.x = 260;
			btnBg.y = 138;
			part.addChild(btnBg);
			var confirmBtn:Button=ComponentUtil.createButton("", 272, 160, 74, 74, part);
			confirmBtn.addEventListener(MouseEvent.CLICK, onConfirm);
			confirmBtn.bgSkin=Style.getButtonSkin("name_xiling", "", "", null, GameConfig.T1_VIEWUI);
			
			
			var partPet2:UIComponent = ComponentUtil.createUIComponent(381,176,158,230);
			Style.setBorderSkin(partPet2);
			
			var tfy:TextFormat=new TextFormat(null, null, 0xffff00);
			
			ComponentUtil.createTextField("选择洗灵丹", 6, 5, tf, 146, 22, partPet2);
			drug=ComponentUtil.createTextField("最低需要", 6, 23, tf, 146, 22, partPet2);
			
			var arr:Array=new Array();
			xiLingDanItemVo1=ItemLocator.getInstance().getObject(d1);
			xiLingDanItemVo2=ItemLocator.getInstance().getObject(d2);
			xiLingDanItemVo3=ItemLocator.getInstance().getObject(d3);
			arr.push(xiLingDanItemVo1);
			arr.push(xiLingDanItemVo2);
			arr.push(xiLingDanItemVo3);
			
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

		public function updateList(pets:Array,count:int):void {
			headerContent.updateList(pets,count);
		}

		private function onPetItemClick(e:ItemEvent):void {
			var p:p_pet_id_name=e.selectItem as p_pet_id_name;
			var dic:Dictionary=PetDataManager.petInfos;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=p.pet_id;
			PetModule.getInstance().send(vo);
		}

		public function makeUseDrug(vo:p_pet):void {
			headerContent.updateInfo(vo);
			var p:p_pet_id_name=headerContent.getSelectedItem();
			if (p == null)
				return;
			if (vo.pet_id == p.pet_id) {
				var maxAptitude:int=PetConfig.getMaxAptitude(vo.type_id);
				var carryLevel:int=PetConfig.getPetTakeLevel(vo.type_id);

				if (carryLevel == 5 || carryLevel == 25) {
					useDrug=d1;
					useDrugName="【初级洗灵丹】";
				} else if (carryLevel == 50) {
					useDrug=d2;
					useDrugName="【中级洗灵丹】";
				} else {
					useDrug=d3;
					useDrugName="【高级洗灵丹】";
				}

				maxZiZhi.htmlText=HtmlUtil.font2("基础资质最高可到：", 0xFFFFFF) + HtmlUtil.font2(maxAptitude + "", 0xFF0000);

				drug.htmlText=HtmlUtil.font2("最低需要：", 0xFFFFFF) + HtmlUtil.font2(useDrugName, 0x3ce451);
				
				pvo=vo;
				var maxZZ:int=PetConfig.getMaxAptitude(pvo.type_id) - 200;
				var ziZhiColor:uint=vo.phy_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
				outAttackZZ.htmlText=coloring("外攻资质：", vo.phy_attack_aptitude, ziZhiColor);
				ziZhiColor=vo.magic_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
				inAttackZZ.htmlText=coloring("内攻资质：", vo.magic_attack_aptitude, ziZhiColor);
				ziZhiColor=vo.phy_defence_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
				outDefZZ.htmlText=coloring("外防资质：", vo.phy_defence_aptitude, ziZhiColor);
				ziZhiColor=vo.magic_defence_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
				inDefZZ.htmlText=coloring("内防资质：", vo.magic_defence_aptitude, ziZhiColor);
				ziZhiColor=vo.max_hp_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
				shengmingZZ.htmlText=coloring("生命资质：", vo.max_hp_aptitude, ziZhiColor);
				ziZhiColor=vo.double_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
				zhongjiZZ.htmlText=coloring("重击资质：", vo.double_attack_aptitude, ziZhiColor);
			}
		}

		private function coloring(s1:String, s2:int, color2:uint=0xECE8BB):String {
			var str:String=HtmlUtil.font2(s1, 0xAFE0EE) + HtmlUtil.font2(s2 + "", color2);
			return str;
		}

		private function onConfirm(e:MouseEvent):void {
			var item:p_pet_id_name=headerContent.list.selectedItem as p_pet_id_name;
			if (item == null) {
				Tips.getInstance().addTipsMsg("请先选择需要洗灵的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == item.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "洗灵", exeCallBack, null, "召回宠物");
				return;
			}
			var itemUse:BaseItemVO=goodsList.selectedItem as BaseItemVO;
			if (itemUse == null) {
				Tips.getInstance().addTipsMsg("请先选择洗灵丹");
				return;
			}
			var itemNum:int=PackManager.getInstance().getGoodsNumByTypeId(itemUse.typeId);
			if (itemNum <= 0) {
				Tips.getInstance().addTipsMsg("选择的洗灵丹数量不足");
				updateUseItemNum();
				return;
			}
			var vo:m_pet_refresh_aptitude_tos=new m_pet_refresh_aptitude_tos;
			vo.pet_id=item.pet_id;
			vo.item_type=itemUse.typeId;
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
			xiLingDanItemVo1.num=PackManager.getInstance().getGoodsNumByTypeId(d1);
			xiLingDanItemVo2.num=PackManager.getInstance().getGoodsNumByTypeId(d2);
			xiLingDanItemVo3.num=PackManager.getInstance().getGoodsNumByTypeId(d3);
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