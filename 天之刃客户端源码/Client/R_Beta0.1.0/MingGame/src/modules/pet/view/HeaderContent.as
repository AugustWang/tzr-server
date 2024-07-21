package modules.pet.view
{
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.PackManager;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;
	import modules.shop.ShopConstant;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_skin;
	import proto.line.m_pet_add_bag_tos;
	import proto.line.m_pet_add_skill_grid_tos;
	import proto.line.m_pet_info_tos;
	
	public class HeaderContent extends Sprite
	{
		private static const openSkillMoney:Array=[0, 0, 0, 0, 0, 5, 9, 14, 20, 29, 39, 49, 59];
		public var pvo:p_pet;
		private var skin:p_skin;
		private var avatar:Avatar;
		private var takeLevel:TextField;
		private var sex:TextField;
		private var color:TextField;
		private var bang:TextField;
		private var typeName:TextField;
		private var attackType:TextField;
		private var takePetCount:TextField;
		public var list:List;
		private var leftTopContainer:UIComponent;
		private var selectedPet:p_pet_id_name;
		private var colors:Array=["白", "绿", "蓝", "紫", "橙", "金"];
		private var part1:UIComponent;
		
		public function HeaderContent()
		{
			var tf:TextFormat=new TextFormat(null, null, 0xffffff);
			tf.leading=4;
			var tfy:TextFormat=new TextFormat(null, null, 0xffff00);
			var tfr:TextFormat=new TextFormat(null, null, 0xff0000);
			var tfg:TextFormat=new TextFormat(null, null, 0x00ff00);
			
			part1 = ComponentUtil.createUIComponent(2,2,380,164);
			Style.setBorderSkin(part1);
			var img:Image = new Image();
			img.width = 273;
			img.height = 152;
			img.mouseChildren = img.mouseEnabled = false;
			img.source = GameConfig.getBackImage("petInfoBg");
			img.x = part1.width - img.width >> 1;
			img.y = part1.height - img.height >> 1;
			part1.addChild(img);
			
			var avatarBg:Image = new Image();
			avatarBg.width = 213;
			avatarBg.height = 153;
			avatarBg.x = part1.width - avatarBg.width >> 1;
			avatarBg.y = part1.height - avatarBg.height >> 1;
			avatarBg.mouseChildren = avatarBg.mouseEnabled = false;
			avatarBg.source = GameConfig.getBackImage("petAvatarBg");
			part1.addChild(avatarBg);
			
			avatar=new Avatar;
			avatar.x=190;
			avatar.y=136;
			part1.addChild(avatar);
			
			var tfb:TextFormat=new TextFormat(null, null, 0xFFFFFF, null);
			takeLevel=ComponentUtil.createTextField("可携带等级：", 4, 2, tf, 160, 22, part1, doToolTip, "takeLevel");
			typeName=ComponentUtil.createTextField("类型：", 4, 20, tfb, 160, 22, part1);
			bang=ComponentUtil.createTextField("绑定", 4, 38, tf, 160, 22, part1);
			
			color=ComponentUtil.createTextField("颜色：", 300, 2, tf, 160, 22, part1, doToolTip, "color");
			sex=ComponentUtil.createTextField("性别：", 300, 20, tf, 160, 22, part1);
			attackType=ComponentUtil.createTextField("内外攻：", 300, 38, tf, 160, 22, part1, doToolTip, "attackType");
			
			leftTopContainer=ComponentUtil.createUIComponent(381,2,158,171);
			Style.setBorderSkin(leftTopContainer);
			
			var listBar:Bitmap =Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			listBar.x = listBar.y = 1
			listBar.width = 155;
			leftTopContainer.addChild(listBar);
			
			takePetCount = ComponentUtil.createTextField("携带宠物数量：1/6",5,2,tfy,120,20,leftTopContainer);
			
			list=new List;
			list.x=2;
			list.y=23;
			list.bgSkin=null;
			list.width=154;
			list.height=125;
			list.itemHeight=25;
			list.itemRenderer=PetListRender;
			list.addEventListener(ItemEvent.ITEM_CLICK, onPetItemClick);
			leftTopContainer.addChild(list);
			
			var addPetTxt:TextField = ComponentUtil.createTextField("",8, 146, null, 96, 22, leftTopContainer);
			addPetTxt.mouseEnabled=true;
			addPetTxt.htmlText="<a href=\"event:add_pet\"><font color='#00FF00'><u>扩展宠物栏</u></font></a>";
			addPetTxt.addEventListener(TextEvent.LINK, onClickAddPet);
			addPetTxt.addEventListener(MouseEvent.ROLL_OVER, showAddPetTip);
			addPetTxt.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
			
			addChild(part1);
			addChild(leftTopContainer);
			
		}
		
		private function showAddPetTip(e:MouseEvent):void {
			ToolTipManager.getInstance().show("使用宠物笼可扩展宠物背包，您的宠物背包最多可扩展到5格", 0);
		}
		
		private function onClickAddPet(e:TextEvent):void {
			var tool:Array=PackManager.getInstance().getGoodsByType(12300131);
			if (tool.length > 0) {
				Alert.show("是否确定使用1个【宠物笼】，扩展1格宠物背包？", "扩展宠物栏", yesAddPet);
			} else {
				Alert.show("背包中没有【宠物笼】，是否购买？？", "扩展宠物栏", yesBuyTool);
			}
		}
		
		private function yesBuyTool():void {
			Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP, ShopConstant.PEI_CHONG_WU_YANG_CHENG);
		}
		
		private function yesAddPet():void {
			Connection.getInstance().sendMessage(new m_pet_add_bag_tos());
		}
		
		public function showPetSkillLink(value:Boolean):void{
			if(value){
				var openSkillTxt:TextField=ComponentUtil.createTextField("", 290, 140, null, 100, 20, part1);
				openSkillTxt.htmlText="<a href=\"event:openSkill\"><font color='#00FF00'><u>扩展技能栏</u></font>";
				openSkillTxt.mouseEnabled=true;
				openSkillTxt.addEventListener(TextEvent.LINK, openSkill);
			}else if(openSkillTxt){
				openSkillTxt.removeEventListener(TextEvent.LINK, openSkill);
				part1.removeChild(openSkillTxt);
			}
		}
		
		private function onPetItemClick(e:ItemEvent):void {
			selectedPet=e.selectItem as p_pet_id_name;
			var p:p_pet_id_name=e.selectItem as p_pet_id_name;
			var dic:Dictionary=PetDataManager.petInfos;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=p.pet_id;
			vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
			PetModule.getInstance().send(vo);
		}
		
		public function get selectedItem():p_pet_id_name{
			return list.selectedItem as p_pet_id_name;
		}
		
		private function openSkill(e:TextEvent):void {
			selectedPet = list.selectedItem as p_pet_id_name;
			if (selectedPet == null) {
				Tips.getInstance().addTipsMsg("请先选择要扩展技能栏的宠物");
				return;
			}
			if (this.pvo) {
				if (this.pvo.max_skill_grid < openSkillMoney.length - 1 && this.pvo.max_skill_grid > 0) {
					Alert.show("扩展技能栏需要" + openSkillMoney[this.pvo.max_skill_grid + 1] + "元宝，确定扩展吗？", "消费提示", yesOpenSkill);
				} else {
					Tips.getInstance().addTipsMsg("技能栏已经达到最大数");
				}
			} else {
				Tips.getInstance().addTipsMsg("请先选择要扩展技能栏的宠物");
			}
		}
		
		private function yesOpenSkill():void {
			var vo:m_pet_add_skill_grid_tos=new m_pet_add_skill_grid_tos;
			vo.pet_id=selectedPet.pet_id;
			Connection.getInstance().sendMessage(vo);
		}
		
		private function doToolTip(txt:TextField):void {
			txt.mouseEnabled=true;
			txt.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			txt.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
		}
		
		private function onRollOver(e:MouseEvent):void {
			var str:String="";
			switch ((e.currentTarget as TextField).name) {
				case "takeLevel":
					str="";
					break;
				case "attackType":
					str="影响宠物对敌人的伤害类型";
					break;
				case "color":
					str="宠物颜色，由宠物资质和悟性影响";
					break;
			}
			if (str != "") {
				ToolTipManager.getInstance().show(str);
			}
		}
		
		private function hideToolTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}
		
		public function updateList(pets:Array,count:int):void {
			takePetCount.text = "携带宠物数量："+pets.length+"/"+count;
			list.dataProvider=pets;
		}
		
		public function updateInfo(vo:p_pet):void {
			var p:p_pet_id_name = getSelectedItem();
			if(p == null)return;
			if (vo.pet_id == p.pet_id) {
				skin=new p_skin;
				skin.skinid=PetConfig.getPetSkin(vo.type_id);
				if (avatar.skinData == null) {
					avatar.initSkin(skin);
				} else {
					avatar._bodyLayer.y=0;
					avatar.updataSkin(skin);
				}
				var skinid:int=PetConfig.getPetSkin(vo.type_id);
				avatar.play(AvatarConstant.ACTION_STAND, 6, PetDataManager.getStandSpeed(skinid));
				avatar.visible=true;
				if (skinid == 10086 || skinid == 10089 || skinid == 10090 || skinid == 10092 || skinid == 10108) {
					skinid == 10108 ? avatar._bodyLayer.y=66 : avatar._bodyLayer.y=40;
				}
				pvo=vo;
				
			}
			takeLevel.htmlText=coloring("等级要求：", PetConfig.getPetTakeLevel(pvo.type_id));
			sex.htmlText=coloring2("性别：", vo.sex == 1 ? "雄" : "雌");
			color.htmlText=HtmlUtil.font2("颜色：", 0xAFE0EE) + HtmlUtil.font2(colors[vo.color - 1], GameColors.COLOR_VALUES[vo.color]);
			bang.text=vo.bind == true ? "绑定" : "不绑定";
			typeName.htmlText="类型：<font color='#FFF799'>" + PetConfig.getPetMsg(pvo.type_id) + "</font>";
			attackType.htmlText=HtmlUtil.font2(vo.attack_type == 1 ? "外攻" : "内攻", 0xfff799);
		}
		
		public function getSelectedItem():p_pet_id_name{
			if (list.dataProvider == null || list.dataProvider.length <= 0)
				return null;
			var p:p_pet_id_name=list.dataProvider[list.selectedIndex] as p_pet_id_name;
			if (p == null) {
				p=list.dataProvider[0];
			}
			return p;
		}
		
		//制造颜色
		private function coloring2(s1:String, s2:String):String {
			var str:String=HtmlUtil.font2(s1, 0xffffff) + HtmlUtil.font2(s2, 0xECE8BB);
			return str;
		}
		
		//制造颜色
		private function coloring(s1:String, s2:int, color2:uint=0xECE8BB):String {
			var str:String=HtmlUtil.font2(s1, 0xffffff) + HtmlUtil.font2(s2 + "", color2);
			return str;
		}
		
		public function stopAvatar():void {
			if (avatar)
				avatar.stop();
		}
		
		public function startAvatar():void {
			if (avatar)
				avatar.resume();
		}
	}
}