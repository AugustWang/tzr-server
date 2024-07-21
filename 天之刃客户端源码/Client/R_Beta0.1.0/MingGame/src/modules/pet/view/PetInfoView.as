package modules.pet.view {

	import com.common.FlashObjectManager;
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.net.connection.Connection;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.KeyUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.PetSkillVO;
	import modules.pet.config.PetConfig;
	import modules.playerGuide.PlayerGuideModule;
	import modules.shop.ShopConstant;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	import modules.skillTree.SkillTreeModule;
	
	import proto.common.p_pet;
	import proto.common.p_pet_attr_assign;
	import proto.common.p_pet_id_name;
	import proto.common.p_pet_skill;
	import proto.common.p_skin;
	import proto.line.m_pet_add_bag_tos;
	import proto.line.m_pet_add_life_tos;
	import proto.line.m_pet_attr_assign_tos;
	import proto.line.m_pet_change_name_toc;
	import proto.line.m_pet_change_pos_tos;
	import proto.line.m_pet_info_tos;
	import proto.line.m_pet_refining_exp_tos;

	public class PetInfoView extends UIComponent {
		public static const CALL_BACK_EVENT:String="CALL_BACK_EVENT";
		public static const SUMMON_EVENT:String="SUMMON_EVENT";
		public static const THROW_EVENT:String="THROW_EVENT";
		public static const PET_STORE_EVENT:String="PET_STORE_EVENT";
		public static const PROPERTY_EVENT:String="PROPERTY_EVENT";
		//////////////////
		public static var summonAbled:Boolean=true; //限制按钮时间
		public static var callBackAbled:Boolean=true;
		public static var retireAbled:Boolean=true; //限制点击
		private static var summonTimeID:int;
		private static var callBackTimeID:int;
		private var btns:Array=[];
		private var skills:Array=[];
		public var pvo:p_pet;
		private var colors:Array=["白", "绿", "蓝", "紫", "橙", "金"];
		private var ziZhiPro:Array=["", "+50", "+100", "+150", "+250", "+350", "+450", "+600", "+750", "+900", "+1050", "+1200", "+1400", "+1600", "+1800", "+2000"];
		private var avatar:Avatar;
		private var skin:p_skin;
		private var takeLevel:TextField;
		private var sex:TextField;
		private var color:TextField;
		private var bang:TextField;
		private var typeName:TextField;
		private var attackType:TextField;
		private var petName:TextField;
		private var petLevel:TextField;
		private var petCouple:TextField;
		private var petHp:TextField;
		private var petLife:TextField;
		private var petExp:TextField;
		private var wuxing:TextField;
		private var liliang:TextField;
		private var zhili:TextField;
		private var tizhi:TextField;
		private var jingshen:TextField;
		private var minjie:TextField;
		private var remainPoint:TextField;
		private var propertyConfim:Button;
		private var outAttackZZ:TextField;
		private var inAttackZZ:TextField;
		private var outDefZZ:TextField;
		private var inDefZZ:TextField;
		private var zhongjiZZ:TextField;
		private var shengmingZZ:TextField;
		private var outAttack:TextField;
		private var inAttack:TextField;
		private var outDef:TextField;
		private var inDef:TextField;
		private var zhongji:TextField;
		private var petNameListTxt:TextField;
		public var list:List;
		private var addPetTxt:TextField;
		private var upBtn:Sprite;
		private var downBtn:Sprite;
		public static var upDownAbled:Boolean=true;
		private var chengHao:ComboBox;
		//////////////////////////
		private var qianneng:int;
		private var liliangC:int;
		private var zhiliC:int;
		private var minjieC:int;
		private var jingshenC:int;
		private var tizhiC:int;
		private var step:PetNumberSteper;
		////////////////////////
		public var selectedPetId:int; //正在看的那只

		private var nav:TabNavigation;

		private var partPetDesc:Sprite;
		private var partPetAttr:Sprite;
		private var callBackBtn:Button;
		public var summonBtn:Button;

		private var petReNameView:PetReNameView;

		public function PetInfoView() {
			init();
		}

		private function init():void {
			this.y=4;
			width=525;
			height=400;
			var part1:UIComponent = ComponentUtil.createUIComponent(2,2,280,164);
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
			avatar.x=140;
			avatar.y=136;
			part1.addChild(avatar);
			var tf:TextFormat=new TextFormat(null, null, 0xcccccc, null);
			var tfb:TextFormat=new TextFormat(null, null, 0xAFE0EE, null);
			var tfy:TextFormat=new TextFormat(null, null, 0xffff00, null);
			takeLevel=ComponentUtil.createTextField("可携带等级：", 4, 2, tf, 160, 22, part1, doToolTip, "takeLevel");
			typeName=ComponentUtil.createTextField("类型：", 4, 20, tfb, 160, 22, part1);
			bang=ComponentUtil.createTextField("绑定", 4, 38, tf, 160, 22, part1);

			color=ComponentUtil.createTextField("颜色：", 220, 2, tf, 160, 22, part1, doToolTip, "color");
			sex=ComponentUtil.createTextField("性别：", 220, 20, tf, 160, 22, part1);
			attackType=ComponentUtil.createTextField("内外攻：", 220, 38, tf, 160, 22, part1, doToolTip, "attackType");
			var smeltTxt:TextField=ComponentUtil.createTextField("", 10, 140, tf, 60, 24, part1);
			smeltTxt.htmlText="<a href=\"event:throw\"><font color='#00FF00'><u>宠物退役</u></font></a>";
			smeltTxt.addEventListener(TextEvent.LINK, toRetire);
			smeltTxt.mouseEnabled=true;
//			smeltTxt.visible=false; //先屏蔽功能

			var throwTxt:TextField=ComponentUtil.createTextField("放生宠物", 220, 140, tf, 60, 24, part1);
			throwTxt.htmlText="<a href=\"event:throw\"><font color='#00FF00'><u>放生宠物</u></font></a>";
			throwTxt.addEventListener(TextEvent.LINK, toThrow);
			throwTxt.mouseEnabled=true;

			//////////////////////
			var part2:Sprite=new Sprite();
			part2.x=2;
			part2.y=168;
			var btf:TextFormat=new TextFormat(null, null, 0xcccccc, null);
			var petSkillPart:Sprite=new Sprite();
			petSkillPart.x=4;
			petSkillPart.y=2;
			var img2:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"name_petSkill");
			img2.y =7;
			img2.x=5;
			petSkillPart.addChild(img2);
			part2.addChild(petSkillPart);
			for (var i:int=0; i < 16; i++) {
				var psi:PetSkillLearnItem=new PetSkillLearnItem;
				psi.x=45 + (i % 8) * 39;
				psi.y=2 + int(i / 8) * 37;
				skills.push(psi);
				part2.addChild(psi);
			}
			////////////////////////////////
			var part3:Sprite=new Sprite();
			part3.x=2;
			part3.y=254;
			var arr:Array=new Array();
			for (i=0; i < 6; i++) {
				var tmpBG:UIComponent=new UIComponent();
				tmpBG.width=136 - int(i % 2) * 36;
				tmpBG.height=25;
				tmpBG.bgSkin = Style.getInstance().textInputSkin;
				tmpBG.x=64 + (i % 2) * 210;
				tmpBG.y=4 + int(i / 2) * 24;
				arr[i]=tmpBG;
				part3.addChild(tmpBG);
			}
			ComponentUtil.createTextField("宠物名称：", 4, 2, tf, 160, 22, part3);
			petName=ComponentUtil.createTextField("", 2, 0, tf, 130, 22, arr[0]);
			var reNameTxt:TextField=ComponentUtil.createTextField("改名", 101, 0, tf, 50, 22, arr[0]);
			reNameTxt.htmlText="<a href=\"event:reName\"><font color='#00FF00'><u>改名</u></font></a>";
			reNameTxt.addEventListener(TextEvent.LINK, doReName);
			reNameTxt.mouseEnabled=true;
			ComponentUtil.createTextField("寿命：", 206, 2, tf, 60, 22, part3, doToolTip, "petLife");
			petLife=ComponentUtil.createTextField("", 2, 0, tf, 100, 22, arr[1]);
			var addLifeTxt:TextField=ComponentUtil.createTextField("延寿", 70, 0, tf, 50, 22, arr[1]);
			addLifeTxt.htmlText="<a href=\"event:addLife\"><font color='#00FF00'><u>延寿</u></font></a>";
			addLifeTxt.addEventListener(TextEvent.LINK, AddLife);
			addLifeTxt.mouseEnabled=true;
			ComponentUtil.createTextField("融合度：", 206, 25, tf, 160, 22, part3, doToolTip, "petCouple");
			petCouple=ComponentUtil.createTextField("", 2, 0, tf, 100, 22, arr[3]);
			ComponentUtil.createTextField("生命值：", 4, 25, tf, 160, 22, part3, doToolTip, "petHp");
			petHp=ComponentUtil.createTextField("", 2, 0, tf, 130, 22, arr[2]);
			ComponentUtil.createTextField("宠物等级：", 206, 48, tf, 160, 22, part3, doToolTip, "petLevel");
			petLevel=ComponentUtil.createTextField("", 2, 0, tf, 100, 22, arr[5]);
			ComponentUtil.createTextField("经验：", 4, 48, tf, 160, 22, part3);
			petExp=ComponentUtil.createTextField("", 2, 0, tf, 130, 22, arr[4]);

			//////////////////////////

			///////////////////
			var part4:Sprite=Style.getBlackSprite(99, 164, 0, 0.2);
			part4.x=282;
			part4.y=2;
			var listBar:Bitmap =Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			listBar.width = 98;
			upBtn=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"upIcon"); //下
			downBtn=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"downIcon"); //下
			upBtn.buttonMode=true;
			downBtn.buttonMode=true;
			upBtn.x=86;
			upBtn.y=5;
			downBtn.x=74;
			downBtn.y=5;
			downBtn.addEventListener(MouseEvent.ROLL_OVER, upDownOver);
			upBtn.addEventListener(MouseEvent.ROLL_OVER, upDownOver);
			downBtn.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
			upBtn.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
			downBtn.addEventListener(MouseEvent.CLICK, onClickDown);
			upBtn.addEventListener(MouseEvent.CLICK, onClickUp);
			part4.addChild(listBar);
			part4.addChild(upBtn);
			part4.addChild(downBtn);
			petNameListTxt=ComponentUtil.createTextField("宠物背包", 4, 0, tf, 94, 22, part4);
			list=new List;
			list.verticalScrollPolicy="off";
			list.bgSkin=null;
			list.labelField="name";
			list.width=96;
			list.height=118;
			list.y=25;
			list.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			part4.addChild(list);
			addPetTxt=ComponentUtil.createTextField("", 20, 142, null, 96, 22, part4);
			addPetTxt.mouseEnabled=true;
			addPetTxt.htmlText="<a href=\"event:add_pet\"><font color='#00FF00'><u>扩展宠物栏</u></font></a>";
			addPetTxt.addEventListener(TextEvent.LINK, onClickAddPet);
			addPetTxt.addEventListener(MouseEvent.ROLL_OVER, showAddPetTip);
			addPetTxt.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
			////////////////////
			var part5:Sprite=Style.getBlackSprite(145, 143, 0, 0);
			part5.y=235;
			liliang=ComponentUtil.createTextField("力量：", 4, 2, tf, 120, 22, part5, doToolTip, "liliang");
			zhili=ComponentUtil.createTextField("智力：", 4, 20, tf, 120, 22, part5, doToolTip, "zhili");
			minjie=ComponentUtil.createTextField("敏捷：", 4, 38, tf, 120, 22, part5, doToolTip, "minjie");
			jingshen=ComponentUtil.createTextField("精神：", 4, 56, tf, 120, 22, part5, doToolTip, "jingshen");
			tizhi=ComponentUtil.createTextField("体质：", 4, 74, tf, 120, 22, part5, doToolTip, "tizhi");
			remainPoint=ComponentUtil.createTextField("潜能：", 4, 104, null, 126, 22, part5, doToolTip, "remainPoint");
			var refreshPointTxt:TextField=ComponentUtil.createTextField("洗     点", 4, 121, null, 118, 22, part5, doToolTip, "xiling");
			refreshPointTxt.htmlText="<a href=\"event:add_understanding\"><font color='#00FF00'><u>洗点</u></font></a>";
			refreshPointTxt.addEventListener(TextEvent.LINK, onClickXiLing);
			for (i=0; i < 10; i++) {
				var bt:String=i < 5 ? "add" : "reduce";
				var bx:Number=int(i / 5) * 22 + 98;
				var by:Number=int(i % 5) * 20 + 4;
				var addBtn:Button=createButton("", bx, by, part5, bt);
				addBtn.name=i + "";
				addBtn.addEventListener(MouseEvent.CLICK, addproperty);
				btns.push(addBtn);
			}
			propertyConfim=ComponentUtil.createButton("确定", 89, 106, 50, 22, part5);
			propertyConfim.addEventListener(MouseEvent.CLICK, onComfirmProperty);
			step=new PetNumberSteper;
			part5.addChild(step);
			var part6:Sprite=Style.getBlackSprite(145, 130, 0, 0);
			part6.y=103;
			wuxing=ComponentUtil.createTextField("悟性：", 4, 2, tf, 120, 22, part6, doToolTip, "wuxing");
			var addSavvyTxt:TextField=ComponentUtil.createTextField("提悟", 106, 2, tf, 50, 22, part6);
			addSavvyTxt.htmlText="<a href=\"event:add_understanding\"><font color='#00FF00'><u>提悟</u></font></a>";
			addSavvyTxt.addEventListener(TextEvent.LINK, toAddSavvyView);
			addSavvyTxt.mouseEnabled=true;
			outAttackZZ=ComponentUtil.createTextField("外攻资质：", 4, 20, tf, 120, 22, part6, doToolTip, "outAttackZZ");
			inAttackZZ=ComponentUtil.createTextField("内攻资质：", 4, 38, tf, 120, 22, part6, doToolTip, "inAttackZZ");
			outDefZZ=ComponentUtil.createTextField("外防资质：", 4, 56, tf, 120, 22, part6, doToolTip, "outDefZZ");
			inDefZZ=ComponentUtil.createTextField("内防资质：", 4, 74, tf, 120, 22, part6, doToolTip, "inDefZZ");
			zhongjiZZ=ComponentUtil.createTextField("重击资质：", 4, 92, tf, 120, 22, part6, doToolTip, "zhongjiZZ");
			shengmingZZ=ComponentUtil.createTextField("生命资质：", 4, 110, tf, 120, 22, part6, doToolTip, "shengmingZZ");
			///////////////////
			var part7:Sprite=Style.getBlackSprite(145, 102, 0, 0);
			outAttack=ComponentUtil.createTextField("外功攻击：", 4, 2, tf, 120, 22, part7, doToolTip, "outAttack");
			inAttack=ComponentUtil.createTextField("内功攻击：", 4, 22, tf, 120, 22, part7, doToolTip, "inAttack");
			outDef=ComponentUtil.createTextField("外功防御：", 4, 42, tf, 120, 22, part7, doToolTip, "outDef");
			inDef=ComponentUtil.createTextField("内功防御：", 4, 62, tf, 120, 22, part7, doToolTip, "inDef");
			zhongji=ComponentUtil.createTextField("重击：", 4, 82, tf, 120, 22, part7, doToolTip, "zhongji");
			var petGrowTxt:TextField=ComponentUtil.createTextField("驯宠能力", 88, 82, tf, 50, 22, part7);
			petGrowTxt.htmlText="<a href=\"event:pet_grow\"><font color='#00FF00'><u>驯宠能力</u></font></a>";
			petGrowTxt.addEventListener(TextEvent.LINK, toPetGrowView);
			petGrowTxt.mouseEnabled=true;
			var part8:Sprite=new Sprite()
			ComponentUtil.createTextField("如何获得宠物？", 2, 2, tfy, 120, 22, part8);
			var part8Txt1:TextField=ComponentUtil.createTextField("1. 达到5级完成主线任务\n可获得萌宠——大白兔", 2, 32, tf, 142, 34, part8);
			var part8Txt2:TextField=ComponentUtil.createTextField("", 2, 70, tf, 142, 70, part8);
			part8Txt2.htmlText="2. 经<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>宠物驯养师</u></font></a>传送到神\n农架，击杀对应形象怪物\n可获得宠物召唤符";
			part8Txt2.addEventListener(TextEvent.LINK, gotoNpc);
			part8Txt2.mouseEnabled=true;
			var part8Txt3:TextField=ComponentUtil.createTextField("", 2, 124, tf, 142, 34, part8);
			part8Txt3.htmlText="3. <a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>宠物商店</u></font></a>有大量强力宠\n物出售";
			part8Txt3.addEventListener(TextEvent.LINK, toPetStore);
			part8Txt3.mouseEnabled=true;

			var part9:Sprite=new Sprite();
			part9.y=167;
			ComponentUtil.createTextField("如何强化宠物？", 2, 2, tfy, 120, 22, part9);
			var part9Txt1:TextField=ComponentUtil.createTextField("", 2, 25, tf, 142, 22, part9);
			part9Txt1.htmlText="1. 让宠物学习强力<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>技能</u></font></a>";
			part9Txt1.addEventListener(TextEvent.LINK, toPetSkillView);
			part9Txt1.mouseEnabled=true;
			var part9Txt2:TextField=ComponentUtil.createTextField("", 2, 48, tf, 142, 34, part9);
			part9Txt2.htmlText="2. 给宠物<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>洗灵</u></font></a>可改变基础\n资质";
			part9Txt2.addEventListener(TextEvent.LINK, toPetAptitudeView);
			part9Txt2.mouseEnabled=true;
			var part9Txt3:TextField=ComponentUtil.createTextField("", 2, 84, tf, 142, 34, part9);
			part9Txt3.htmlText="3. 给宠物<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>提悟</u></font></a>可提升宠物\n资质";
			part9Txt3.addEventListener(TextEvent.LINK, toAddSavvyView);
			part9Txt3.mouseEnabled=true;
			var part9Txt4:TextField=ComponentUtil.createTextField("", 2, 120, tf, 142, 34, part9);
			part9Txt4.htmlText="4. 提升<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>驯宠能力</u></font></a>可增加出\n战宠物战斗属性";
			part9Txt4.addEventListener(TextEvent.LINK, toPetGrowView);
			part9Txt4.mouseEnabled=true;
			var part9Txt5:TextField=ComponentUtil.createTextField("", 2, 156, tf, 142, 34, part9);
			part9Txt5.htmlText="5. <a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>宠物训练</u></font></a>可增加宠物经\n验";
			part9Txt5.addEventListener(TextEvent.LINK, toPetFeedView);
			part9Txt5.mouseEnabled=true;

			partPetDesc=new Sprite();
			partPetDesc.x = 5;
			partPetDesc.addChild(part8);
			partPetDesc.addChild(part9);

			partPetAttr=new Sprite();
			partPetAttr.x=partPetAttr.y=2;
			partPetAttr.addChild(part5);
			partPetAttr.addChild(part6);
			partPetAttr.addChild(part7);
			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			tiao.width=140;
			var tiao2:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			tiao2.width=140;
			tiao.x=tiao2.x=2;
			tiao.y=part7.height;
			tiao2.y=part6.height + part7.height;
			partPetAttr.addChild(tiao);
			partPetAttr.addChild(tiao2);

			nav=new TabNavigation();
			nav.addItem("属性", partPetAttr, 60, 26);
			nav.addItem("查看帮助", partPetDesc, 60, 26);
			nav.y=2;
			nav.x=382;
			nav.width=158;
			nav.height=407;
			Style.setBorderSkin(nav.tabContainer);
			nav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onNavChangeHandler);


			this.addChild(part1);
			this.addChild(part2);
			this.addChild(part3);
			this.addChild(part4);
			this.addChild(nav);
			var petStoreBtn:Button=ComponentUtil.createButton("宠物商店", 68, 100, 65, 25, part3);
			var showPetBtn:Button=ComponentUtil.createButton("发到聊天", 257, 100, 65, 25, part3);
			var btnBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"btn_bg");
			btnBg.x = 160;
			btnBg.y = 78;
			part3.addChild(btnBg);propertyConfim
			summonBtn=ComponentUtil.createButton("", 172, 100, 70, 70, part3);
			summonBtn.bgSkin=Style.getButtonSkin("name_chuzhan", "", "", null, GameConfig.T1_VIEWUI);
			summonBtn.addEventListener(MouseEvent.ROLL_OVER, onSummonOver);
			summonBtn.addEventListener(MouseEvent.ROLL_OUT, onSummonOut);
			summonBtn.addEventListener(MouseEvent.CLICK, toSummon);
			callBackBtn=ComponentUtil.createButton("", 172, 100, 70, 70, part3);
			callBackBtn.bgSkin=Style.getButtonSkin("name_zhaohui", "", "", null, GameConfig.T1_VIEWUI);
			callBackBtn.addEventListener(MouseEvent.ROLL_OVER, onSummonOver);
			callBackBtn.addEventListener(MouseEvent.ROLL_OUT, onSummonOut);
			callBackBtn.addEventListener(MouseEvent.CLICK, toCallBack);
			callBackBtn.visible=false;
			showPetBtn.setToolTip("点击可发送宠物信息到聊天频道。\n快捷发送：按ctrl并左键点击宠物名。", 200);
			petStoreBtn.addEventListener(MouseEvent.CLICK, toPetStore);
			showPetBtn.addEventListener(MouseEvent.CLICK, toShowPet);
//			reButton(false);
			resetProBtn();
			partPetDesc=Style.getBlackSprite(111, 111, 0, 0.2);
			partPetAttr=Style.getBlackSprite(111, 111, 0, 0.2);
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

		private function onClickXiLing(e:TextEvent):void {
			Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP, ShopConstant.PEI_CHONG_WU_YANG_CHENG);
		}

		public function getSunmmonBtnPoint():Point {
			if (summonBtn) {
				return summonBtn.localToGlobal(new Point(0, 0));
			}
			return new Point(0, 0);
		}

		private function upDownOver(e:MouseEvent):void {
			var tar:Sprite=e.target as Sprite;
			if (tar == upBtn) {
				ToolTipManager.getInstance().show("向上调整选中宠物的顺序", 100);
			} else {
				ToolTipManager.getInstance().show("向下调整选中宠物的顺序", 100);
			}
		}

		private function hideToolTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onClickUp(e:MouseEvent):void {
			if (upDownAbled == true) {
				var p:p_pet_id_name=list.selectedItem as p_pet_id_name;
				if (p) {
					var index:int=list.selectedIndex;
					var vo:m_pet_change_pos_tos=new m_pet_change_pos_tos;
					vo.pet_id=p.pet_id;
					index--;
					if (index < 0) {
						index=list.dataProvider.length - 1;
					}
					vo.pos=index;
					Connection.getInstance().sendMessage(vo);
					upDownAbled=false;
				} else {
					Dispatch.dispatch(ModuleCommand.TIPS, "请先选中列表中要调整顺序的宠物");
				}
			}
		}

		private function onClickDown(e:MouseEvent):void {
			if (upDownAbled == true) {
				var p:p_pet_id_name=list.selectedItem as p_pet_id_name;
				if (p) {
					var index:int=list.selectedIndex;
					var vo:m_pet_change_pos_tos=new m_pet_change_pos_tos;
					vo.pet_id=p.pet_id;
					index++;
					if (index > list.dataProvider.length - 1) {
						index=0;
					}
					vo.pos=index;
					Connection.getInstance().sendMessage(vo);
					upDownAbled=false;
				} else {
					Dispatch.dispatch(ModuleCommand.TIPS, "请先选中列表中要调整顺序的宠物");
				}
			}
		}

		private function onSummonOver(e:MouseEvent):void {
			var tar:Button=e.target as Button;
			if (tar == summonBtn) {
				ToolTipManager.getInstance().show("出战宠物（W）", 100);
			} else if (tar == callBackBtn) {
				ToolTipManager.getInstance().show("召回宠物（W）", 100);
			}
		}

		private function onSummonOut(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function focusInHandler(e:FocusEvent):void {
			IME.enabled=true;
		}

		public function updateList(pets:Array, bagContent:int):void {
			petNameListTxt.htmlText="宠物列表 " + pets.length + "/" + bagContent;
			if (pets.length == 0) {
				doEmpty();
			} else {
				for (var i:int=0; i < pets.length; i++) {
					var idName:p_pet_id_name=pets[i] as p_pet_id_name;
					idName.name="<font color='" + GameColors.getHtmlColorByIndex(idName.color) + "'>" + idName.name + "</font>";
				}
				list.dataProvider=pets;
				makeListSelect(); //搞个默认选中
			}
			upDownAbled=true;
			addPetTxt.visible=pets.length < 5;
		}

		public function update(vo:p_pet):void {
			if (list.dataProvider == null || list.dataProvider.length <= 0)
				return;
			var p:p_pet_id_name=list.dataProvider[list.selectedIndex] as p_pet_id_name;
			if (p == null)
				return;
			PetDataManager.petInfos[vo.pet_id]=vo;
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
				this.pvo=vo;
				PetDataManager.selectedPet=vo;
				if (PetDataManager.isBattle == false) {
					Dispatch.dispatch(ModuleCommand.BATTLE_PET_CHANGE);
				}
			}
			if (PetDataManager.isBattle == false) {
				summonBtn.visible=true;
				callBackBtn.visible=false;
			} else {
				summonBtn.visible=false;
				callBackBtn.visible=true;
			}
			selectedPetId=vo.pet_id;
			for (var i:int=0; i < 12; i++) {
				skills[i].data=null;
				(skills[i] as PetSkillLearnItem).removeEventListener(MouseEvent.MOUSE_DOWN, onDragSkill);
			}
			for (i=0; i < vo.skills.length; i++) {
				var ps:p_pet_skill=vo.skills[i];
				var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
				var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
				skills[i].data=petSkill;
				if (petSkill.skill_type < 10 || petSkill.skill_type > 100) { //群攻技能或者神技并且是出战宠物的技能，才能拖
					(skills[i] as PetSkillLearnItem).addEventListener(MouseEvent.MOUSE_DOWN, onDragSkill);
				}
			}
			takeLevel.htmlText=coloring("等级要求：", PetConfig.getPetTakeLevel(pvo.type_id));
			sex.htmlText=coloring2("性别：", vo.sex == 1 ? "雄" : "雌");
			color.htmlText=HtmlUtil.font2("颜色：", 0xAFE0EE) + HtmlUtil.font2(colors[vo.color - 1], GameColors.COLOR_VALUES[vo.color]);
			bang.text=vo.bind == true ? "绑定" : "不绑定";
			typeName.htmlText="类型：<font color='#FFF799'>" + PetConfig.getPetMsg(pvo.type_id) + "</font>";
			attackType.htmlText=HtmlUtil.font2(vo.attack_type == 1 ? "外攻" : "内攻", 0xfff799);
			petName.htmlText=coloring2("", vo.pet_name);
			petLevel.htmlText=coloring("", vo.level);
			petCouple.htmlText=coloring("", 0);
			petLife.htmlText=coloring("", vo.life);
			petExp.htmlText=coloring2("", vo.exp + " / " + vo.next_level_exp);
			wuxing.htmlText=coloring("悟性：", vo.understanding);
			liliang.htmlText=coloring("力量：", vo.str); //力量
			zhili.htmlText=coloring("智力：", vo.int2);
			tizhi.htmlText=coloring("体质：", vo.con);
			jingshen.htmlText=coloring("精神：", vo.men);
			minjie.htmlText=coloring("敏捷：", vo.dex);
			remainPoint.htmlText=HtmlUtil.font("潜能：", "#00ff00") + HtmlUtil.font(vo.remain_attr_points + "", "#00ff00");
			var proZZ:String=ziZhiPro[vo.understanding];
			var maxZZ:int=PetConfig.getMaxAptitude(pvo.type_id) - 200;
			var ziZhiColor:uint=vo.phy_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			outAttackZZ.htmlText=coloring("外攻资质：", vo.phy_attack_aptitude, ziZhiColor) + HtmlUtil.font2(proZZ, 0x00ff00);
			ziZhiColor=vo.magic_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			inAttackZZ.htmlText=coloring("内攻资质：", vo.magic_attack_aptitude, ziZhiColor) + HtmlUtil.font2(proZZ, 0x00ff00);
			ziZhiColor=vo.phy_defence_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			outDefZZ.htmlText=coloring("外防资质：", vo.phy_defence_aptitude, ziZhiColor) + HtmlUtil.font2(proZZ, 0x00ff00);
			ziZhiColor=vo.magic_defence_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			inDefZZ.htmlText=coloring("内防资质：", vo.magic_defence_aptitude, ziZhiColor) + HtmlUtil.font2(proZZ, 0x00ff00);
			ziZhiColor=vo.max_hp_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			shengmingZZ.htmlText=coloring("生命资质：", vo.max_hp_aptitude, ziZhiColor) + HtmlUtil.font2(proZZ, 0x00ff00);
			ziZhiColor=vo.double_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			zhongjiZZ.htmlText=coloring("重击资质：", vo.double_attack_aptitude, ziZhiColor) + HtmlUtil.font2(proZZ, 0x00ff00);
			var pet_max_hp:int=vo.max_hp - vo.max_hp_grow_add;
			if (PetDataManager.thePet != null && vo.pet_id == PetDataManager.thePet.pet_id) {
				petHp.htmlText=coloring2("", vo.hp + " / " + pet_max_hp);
				if (vo.max_hp_grow_add > 0) {
					petHp.htmlText+=HtmlUtil.font2("+" + vo.max_hp_grow_add, 0x00ff00);
				}
				outAttack.htmlText=coloring3("外功攻击：", vo.phy_attack - vo.phy_attack_grow_add, vo.phy_attack_grow_add);
				inAttack.htmlText=coloring3("内功攻击：", vo.magic_attack - vo.magic_attack_grow_add, vo.magic_attack_grow_add);
				outDef.htmlText=coloring3("外功防御：", vo.phy_defence - vo.phy_defence_grow_add, vo.phy_defence_grow_add);
				inDef.htmlText=coloring3("内功防御：", vo.magic_defence - vo.magic_defence_grow_add, vo.magic_defence_grow_add);
			} else {
				petHp.htmlText=coloring2("", vo.hp + " / " + pet_max_hp);
				outAttack.htmlText=coloring("外功攻击：", vo.phy_attack - vo.phy_attack_grow_add);
				inAttack.htmlText=coloring("内功攻击：", vo.magic_attack - vo.magic_attack_grow_add);
				outDef.htmlText=coloring("外功防御：", vo.phy_defence - vo.phy_defence_grow_add);
				inDef.htmlText=coloring("内功防御：", vo.magic_defence - vo.magic_defence_grow_add);
			}
			zhongji.htmlText=coloring("重击：", Math.floor(vo.double_attack / 100)) + "%";
			//////////////////
			clearProperty();
			makeListSelect();
//			reButton(vo.remain_attr_points > 0);
			resetProBtn();
		}

		private function onDragSkill(e:MouseEvent):void {
			if (PetDataManager.thePet != null && pvo != null && PetDataManager.thePet.pet_id == pvo.pet_id) { //群攻技能并且是出战宠物的技能，才能拖
				var item:PetSkillLearnItem=e.currentTarget as PetSkillLearnItem;
				if (item.data != null) {
					DragItemManager.instance.startDragItem(item, item.img, DragConstant.SKILL_ITEM, item.data.skill)
				}
			}
		}

		private function doReName(e:TextEvent):void {
			if (pvo == null) {
				Tips.getInstance().addTipsMsg("请先选中要改名的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == pvo.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "改名", toCallBack, null, "召回宠物");
				return;
			}
			if (!petReNameView) {
				petReNameView=new PetReNameView();
				petReNameView.x=(1002 - petReNameView.width) * 0.5;
				petReNameView.y=(GlobalObjectManager.GAME_HEIGHT - petReNameView.height) * 0.5;
			}
			petReNameView.pet_id=pvo.pet_id;
			petReNameView.x=this.stage.mouseX + 30;
			petReNameView.y=this.stage.mouseY - 50;
			WindowManager.getInstance().openDialog(petReNameView);
		}


		private function AddLife(e:TextEvent):void {
			if (pvo == null) {
				Tips.getInstance().addTipsMsg("请先选中要延寿的宠物");
				return;
			}
			Alert.show("花费1元宝可延长宠物寿命200点\n也可在宠物商店购买延寿丹进行延寿", "提示", toAddLife, null, "确定", "", null, false, true, null);
		}

		private function toAddLife():void {
			var vo:m_pet_add_life_tos=new m_pet_add_life_tos;
			vo.pet_id=selectedPetId;
			vo.add_type=0;
			PetModule.getInstance().send(vo);
		}

		private function gotoNpc(e:TextEvent):void {
			if (e.text == "goto_pet_npc") {
				ChatModule.getInstance().chat.gotoPetNpc();
			}
		}

		private function toAddSavvyView(e:TextEvent):void {
			PetModule.getInstance().mediator.showPanel("提悟");
		}

		private function toPetGrowView(e:TextEvent):void {
			SkillTreeModule.getInstance().openSkillTree(SkillConstant.CATEGORY_LABEL_PETGROW);
		}

		private function toPetSkillView(e:Event):void {
			PetModule.getInstance().mediator.showPanel("技能");
		}

		private function toPetAptitudeView(e:Event):void {
			PetModule.getInstance().mediator.showPanel("洗灵");
		}

		private function toPetFeedView(e:Event):void {
			PetModule.getInstance().mediator.showPanel("训练");
		}


		public function updateName(vo:m_pet_change_name_toc):void {
			var p:p_pet_id_name=list.selectedItem as p_pet_id_name;
			if (p != null && p.pet_id == vo.pet_id) {
				petName.htmlText=coloring2("", vo.pet_name);
			}
			var arr:Array=list.dataProvider;
			for (var i:int=0; i < arr.length; i++) {
				if (arr[i].pet_id == vo.pet_id) {
					arr[i].name=vo.pet_name;
					break;
				}
			}
			list.dataProvider=arr;
		}

		public function updateLife(pet_id:int, life:int):void {
			if (pvo == null || pvo.pet_id != pet_id) {
				return;
			} else {
				petLife.htmlText=coloring("", life);
			}
		}

		private function makeListSelect():void { //到这里已经判断过list.length，一定不为0
			if (selectedPetId == 0) {
				list.selectedIndex=0;
				var idName:p_pet_id_name=list.dataProvider[0];
				var vo:m_pet_info_tos=new m_pet_info_tos;
				vo.pet_id=idName.pet_id;
				vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
				PetModule.getInstance().send(vo);
			} else {
				var arr:Array=PetDataManager.petList;
				for (var i:int=0; i < arr.length; i++) {
					var p:p_pet_id_name=arr[i];
					if (p.pet_id == selectedPetId) {
						list.selectedIndex=i;
						break;
					}
				}
			}
		}


		private function onItemClick(e:ItemEvent):void {
			var ipname:p_pet_id_name=e.selectItem as p_pet_id_name;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=ipname.pet_id;
			vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
			PetModule.getInstance().send(vo);
			if (KeyUtil.getInstance().isKeyDown(InputKey.CONTROL)) {
				var color:String=GameColors.getHtmlColorByIndex(ipname.color);
				var str:String="<a href='event:pet_info:" + ipname.pet_id + "'><u><font color='" + color + "'>[" + ipname.name + "]</font></u></a>";
				ChatModule.getInstance().showPet(str);

			}
		}

		private function toShowPet(e:MouseEvent):void {
			var ipname:p_pet_id_name=list.selectedItem as p_pet_id_name;
			if (ipname != null) {
				var color:String=GameColors.getHtmlColorByIndex(ipname.color);
				var str:String="<a href='event:pet_info:" + ipname.pet_id + "'><u><font color='" + color + "'>[" + ipname.name + "]</font></u></a>";
				ChatModule.getInstance().showPet(str);
			}
		}

		private function toCallBack(e:MouseEvent=null):void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召回宠物");
				return;
			}
			if (callBackAbled == false) {
				Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
				return;
			}
			var evt:ParamEvent=new ParamEvent(CALL_BACK_EVENT);
			this.dispatchEvent(evt);
			setCallBackAbledFalse(); //限制时间
			setSummonAbledFalse(); //限制按钮时间
		}


		private function toSummon(e:MouseEvent):void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召唤宠物");
				return;
			}
			if (summonAbled == false) {
				Tips.getInstance().addTipsMsg("10秒后才能再次召唤宠物");
				return;
			}
			if (this.pvo == null) {
				Alert.show("请选择要出战的宠物", "提示", null, null, "确定", "", null, false);
				return;
			}
			var evt:ParamEvent=new ParamEvent(SUMMON_EVENT, pvo.pet_id);
			this.dispatchEvent(evt);
			setSummonAbledFalse(); //限制按钮时间
			setCallBackAbledFalse();
			if (PlayerGuideModule.getInstance().currentType == PlayerGuideModule.PET_WINDOW) {
				PetModule.getInstance().mediator.getPanel().closeWindow();
			}
		}

		private function toThrow(e:TextEvent):void {
			if (this.pvo == null) {
				Alert.show("请选择要放生的宠物", "提示", null, null, "确定", "", null, false);
				return;
			}
			var evt:ParamEvent=new ParamEvent(THROW_EVENT, pvo);
			this.dispatchEvent(evt);
		}

		private function toRetire(e:TextEvent):void {
			if (retireAbled == true) { //限制不能快速点
				if (this.pvo == null) {
					Alert.show("请选择要退役的宠物", "提示", null, null, "确定", "", null, false);
				} else {
					retireAbled=false;
					var vo:m_pet_refining_exp_tos=new m_pet_refining_exp_tos;
					vo.pet_id=this.pvo.pet_id;
					Connection.getInstance().sendMessage(vo);
				}
			}
		}

		private function toPetStore(e:Event):void {
			var evt:Event=new Event(PET_STORE_EVENT);
			this.dispatchEvent(evt);
		}


		private function addproperty(e:MouseEvent):void {
			var btn:Button=e.currentTarget as Button;
			var s:int=int(btn.name);
			var type:int=s % 5 + 1;
			var isAdd:Boolean=s < 5;
			if (isAdd == true && qianneng >= 30) {
				step.reset(btn.x + 20, btn.y, qianneng, type, changProperty);
			} else {
				changProperty(type, isAdd);
			}
		}

		private function changProperty(type:int, add:Boolean, value:int=1):void {
			switch (type) {
				case 1:
					if (add == true) {
						if (qianneng > 0) {
							liliangC+=value;
							qianneng-=value;
						}
					} else {
						if (liliangC > 0) {
							liliangC-=value;
							qianneng+=value;
						}
					}
					liliang.htmlText=coloring("力量：", pvo.str + liliangC);
					break;
				case 2:
					if (add == true) {
						if (qianneng > 0) {
							zhiliC+=value;
							qianneng-=value;
						}
					} else {
						if (zhiliC > 0) {
							zhiliC-=value;
							qianneng+=value;
						}
					}
					zhili.htmlText=coloring("智力：", pvo.int2 + zhiliC);
					break;
				case 3:
					if (add == true) {
						if (qianneng > 0) {
							minjieC+=value;
							qianneng-=value;
						}
					} else {
						if (minjieC > 0) {
							minjieC-=value;
							qianneng+=value;
						}
					}
					minjie.htmlText=coloring("敏捷：", pvo.dex + minjieC);
					break;
				case 4:
					if (add == true) {
						if (qianneng > 0) {
							jingshenC+=value;
							qianneng-=value;
						}
					} else {
						if (jingshenC > 0) {
							jingshenC-=value;
							qianneng+=value;
						}
					}
					jingshen.htmlText=coloring("精神：", pvo.men + jingshenC);
					break;
				case 5:
					if (add == true) {
						if (qianneng > 0) {
							tizhiC+=value;
							qianneng-=value;
						}
					} else {
						if (tizhiC > 0) {
							tizhiC-=value;
							qianneng+=value;
						}
					}
					tizhi.htmlText=coloring("体质：", pvo.con + tizhiC);
					break;
				default:
					break;
			}
			remainPoint.htmlText=HtmlUtil.font("潜能：", "#00ff00") + HtmlUtil.font(qianneng + "", "#00ff00");
			resetProBtn(); //设置加减按钮
		}

		private function onComfirmProperty(e:MouseEvent):void {
			if (liliangC == 0 && zhiliC == 0 && minjieC == 0 && jingshenC == 0 && tizhiC == 0) {
				Alert.show("属性点未分配", "提示", null, null, "确定", "取消", null, false);
				return;
			}
			var vo:m_pet_attr_assign_tos=new m_pet_attr_assign_tos;
			vo.pet_id=pvo.pet_id;
			var liliang:p_pet_attr_assign=new p_pet_attr_assign;
			var zhili:p_pet_attr_assign=new p_pet_attr_assign;
			var minjie:p_pet_attr_assign=new p_pet_attr_assign;
			var jingshen:p_pet_attr_assign=new p_pet_attr_assign;
			var tizhi:p_pet_attr_assign=new p_pet_attr_assign;
			liliang.assign_type=1;
			liliang.assign_value=liliangC;
			zhili.assign_type=2;
			zhili.assign_value=zhiliC;
			minjie.assign_type=3;
			minjie.assign_value=minjieC;
			jingshen.assign_type=4;
			jingshen.assign_value=jingshenC;
			tizhi.assign_type=5;
			tizhi.assign_value=tizhiC;
			vo.assign_info=[liliang, zhili, minjie, jingshen, tizhi];
			var evt:ParamEvent=new ParamEvent(PROPERTY_EVENT, vo);
			this.dispatchEvent(evt);
		}

		public function clearProperty():void {
			qianneng=pvo.remain_attr_points;
			liliangC=0;
			zhiliC=0;
			minjieC=0;
			jingshenC=0;
			tizhiC=0;
		}

		//制造颜色
		private function coloring(s1:String, s2:int, color2:uint=0xECE8BB):String {
			var str:String=HtmlUtil.font2(s1, 0xAFE0EE) + HtmlUtil.font2(s2 + "", color2);
			return str;
		}

		//制造颜色
		private function coloring2(s1:String, s2:String):String {
			var str:String=HtmlUtil.font2(s1, 0xAFE0EE) + HtmlUtil.font2(s2, 0xECE8BB);
			return str;
		}

		//制造颜色
		private function coloring3(s1:String, s2:int, s3:int):String {

			var str:String=HtmlUtil.font2(s1, 0xAFE0EE) + HtmlUtil.font2(s2 + "", 0xECE8BB);
			if (s3 > 0) {
				str+=HtmlUtil.font2("+" + s3, 0x00ff00);
			}
			return str;
		}

		private function createButton(id:String, xValue:int, yValue:int, parent:Sprite, type:String="add"):Button {
			var btn:Button=new Button();
			btn.name=id;
			btn.width=btn.height=20;
			btn.label="";
			if (type == "add") {
				Style.setaddBtnStyle(btn);
			} else {
				Style.setreduceBtnStyle(btn);
			}
			btn.x=xValue;
			btn.y=yValue;
			btn.addEventListener(MouseEvent.CLICK, addproperty);
			parent.addChild(btn);
			return btn;
		}

		private function reButton(value:Boolean):void {
			for (var i:int=0; i < btns.length; i++) {
				var btn:Button=btns[i];
				btn.visible=value;
			}
			propertyConfim.visible=value;
		}

		private function resetProBtn():void {
			if (qianneng <= 0) {
				for (var i:int=0; i < 5; i++) {
					btns[i].visible=false;
				}
				if (liliangC > 0 || zhiliC > 0 || minjieC > 0 || jingshenC > 0 || tizhiC > 0) {
					FlashObjectManager.setFlash(propertyConfim);
				}
			} else {
				for (i=0; i < 5; i++) {
					btns[i].visible=true;
				}
				FlashObjectManager.colseFlash(propertyConfim);
			}
			btns[5].visible=liliangC > 0;
			btns[6].visible=zhiliC > 0;
			btns[7].visible=minjieC > 0;
			btns[8].visible=jingshenC > 0;
			btns[9].visible=tizhiC > 0;
			for (i=0; i < btns.length; i++) {
				if (btns[i].visible == true) {
					if (propertyConfim.visible == false) {
						propertyConfim.visible=true;
					}
					return;
				}
			}
			propertyConfim.visible=false;
		}

		public function doEmpty():void {
			this.pvo=null;
			selectedPetId=0;
			if (avatar != null) {
				avatar.visible=false;
			}
			for (var i:int=0; i < 12; i++) {
				skills[i].data=null;
			}
			takeLevel.htmlText=coloring2("等级要求：", "");
			sex.htmlText=coloring2("性别：", "");
			color.htmlText=HtmlUtil.font2("颜色：", 0xAFE0EE);
			bang.text="";
			typeName.htmlText="";
			attackType.htmlText="";
			petName.htmlText=coloring2("", "");
			petLevel.htmlText=coloring2("", "");
			petHp.htmlText=coloring2("", "");
			petLife.htmlText=coloring2("", "");
			petExp.htmlText=coloring2("", "");
			wuxing.htmlText=coloring2("悟性：", "");
			liliang.htmlText=coloring2("力量：", ""); //力量
			zhili.htmlText=coloring2("智力：", "");
			tizhi.htmlText=coloring2("体质：", "");
			jingshen.htmlText=coloring2("精神：", "");
			minjie.htmlText=coloring2("敏捷：", "");
			remainPoint.htmlText=HtmlUtil.font("潜能：", "#00ff00");
			outAttackZZ.htmlText=coloring2("外攻资质：", "");
			inAttackZZ.htmlText=coloring2("内攻资质：", "");
			outDefZZ.htmlText=coloring2("外防资质：", "");
			inDefZZ.htmlText=coloring2("内防资质：", "");
			shengmingZZ.htmlText=coloring2("生命资质：", "");
			zhongjiZZ.htmlText=coloring2("重击资质：", "");
			outAttack.htmlText=coloring2("外功攻击：", "");
			inAttack.htmlText=coloring2("内功攻击：", "");
			outDef.htmlText=coloring2("外功防御：", "");
			inDef.htmlText=coloring2("内功防御：", "");
			zhongji.htmlText=coloring2("重击：", "");
			//////////////////
			list.dataProvider=null;
//			reButton(false);
			resetProBtn();
		}

		//重置时间限制
		public static function setSummonAbledFalse():void {
			summonAbled=false;
			LoopManager.clearTimeout(summonTimeID);
			summonTimeID=LoopManager.setTimeout(function s():void {
					summonAbled=true
				}, 10000);
		}

		public static function setCallBackAbledFalse():void {
			callBackAbled=false;
			LoopManager.clearTimeout(callBackTimeID);
			callBackTimeID=LoopManager.setTimeout(function s():void {
					callBackAbled=true
				}, 5000);
		}

		public function resetSummonBtn(useSummon:Boolean):void {
			summonBtn.visible=useSummon;
			callBackBtn.visible=!useSummon;
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
				case "petCouple":
					str="宠物融合功能，暂未开放，敬请期待。";
					break;
				case "petHp":
					str="宠物生命值不足时，可使用宠物药提升";
					break;
				case "petLife":
					str="寿命为0时，宠物将无法出战。\n（可到宠物驯养师处进行延寿）";
					break;
				case "wuxing":
					str="提升悟性可增加宠物资质，悟性最高为15";
					break;
				case "liliang":
					str="力量点数影响宠物的外功攻击";
					break;
				case "zhili":
					str="智力点数影响宠物的内功攻击";
					break;
				case "minjie":
					str="敏捷点数影响宠物的内外功防御";
					break;
				case "jingshen":
					str="精神点数影响宠物特殊技能效果（暂未开放）";
					break;
				case "tizhi":
					str="体质点数影响宠物的血量";
					break;
				case "remainPoint":
					str="宠物升级将获得一定可自由分配的潜能点\n点击“+”“-”可分配";
					break;
				case "outAttackZZ":
					str="影响每力量点增加的外功攻击";
					break;
				case "inAttackZZ":
					str="影响每智力点增加的内功攻击";
					break;
				case "outDefZZ":
					str="影响每敏捷点增加的外功防御";
					break;
				case "inDefZZ":
					str="影响每敏捷点增加的内功防御";
					break;
				case "zhongjiZZ":
					str="影响每体质点增加的重击";
					break;
				case "shengmingZZ":
					str="影响每体质点增加的生命值";
					break;
				case "outAttack":
					str="外攻：宠物对敌人造成外功伤害的能力";
					break;
				case "inAttack":
					str="内攻：宠物对敌人造成内功伤害的能力";
					break;
				case "outDef":
					str="外防：宠物抵抗外功伤害的能力";
					break;
				case "inDef":
					str="内防：宠物抵抗内功伤害的能力";
					break;
				case "zhongji":
					str="重击：触发重击时，将打出双倍伤害";
					break;
				case "petLevel":
					str="跟随主人战斗或进行宠物训练可提升宠物等级\n宠物等级不可超过主人";
					break;
				case "xiling":
					str="购买【宠物洗髓丹】给宠物重新分配潜能点";
					break;
				default:
					break;
			}
			if (str != "") {
				ToolTipManager.getInstance().show(str);
			}
		}

		private function onNavChangeHandler(e:TabNavigationEvent):void {
			dispatchEvent(e);
			var btnLabel:String=nav.tabBar.buttonList[e.index].label;
			switch (btnLabel) {
				case "属性":
					break;
				case "查看帮助":
					break;
			}

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