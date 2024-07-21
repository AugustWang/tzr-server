package modules.skillTree.views {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import modules.family.views.items.FamilySkillItem;
	import modules.pet.PetModule;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skillTree.views.items.SkillItem;
	import modules.skillTree.views.items.SkillPetGrowView;
	
	import proto.common.p_role_pet_grow;

	public class SkillPanel extends BasePanel {
		public var selectCategory:int=SkillConstant.CATEGORY_WARRIOR;
		public static var items:Dictionary=new Dictionary();

		private var skillItem:SkillTreeItem;
//		private var familySkill:FamilySkillTreeItem;
		private var lifeSkill:LifeSkillTreeItem;
		public var petGrow:SkillPetGrowView;

		private var skillUpGradePanel:SkillUpGradePanel
		private var nav:TabNavigation;
		private var bg:UIComponent;
		private var labels:Array;
		private var selectItem:Object;

		private var currentSilver:TextInput;
		private var currentExp:TextInput;
		/**
		 * 构造函数
		 */
		public function SkillPanel() {
			super("");
			width=561;
			height=466;

			addTitleBG(446);
			addImageTitle("title_skill");
			addContentBG(8,8,24);
			
			bg=ComponentUtil.createUIComponent(13,34,330,355);
			Style.setBorderSkin(bg);
			bg.x=13;
			bg.y=34;
			addChild(bg);

			nav=new TabNavigation();
			nav.removeTabContainerSkin();
			skillItem=new SkillTreeItem();
			skillItem.createBg('skillTreeBg');
//			familySkill=new FamilySkillTreeItem();
			lifeSkill=new LifeSkillTreeItem();
			petGrow=new SkillPetGrowView();
			createNav();
			nav.x=17;
			nav.width=530;
			nav.height=346;
			//变态需求 改变容器深度
			nav.addChild(nav.tabContainer);
			
			nav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onNavChangeHandler);
			addChild(nav);

			addEventListener(SkillConstant.EVENT_SKILL_ITEM_CLICK, skillItemClickHandler);

			skillUpGradePanel=new SkillUpGradePanel();
			skillUpGradePanel.initView();
			skillUpGradePanel.x=345;
			skillUpGradePanel.y=34;
			skillUpGradePanel.width=234;
			skillUpGradePanel.height=317;
			addChild(skillUpGradePanel);
			
			currentSilver = createTextInput("当前银子：",15,height - 77);
			currentExp = createTextInput("当前经验：",200,height - 77);
			updateMoneyExp();
		}

		private function createTextInput(proName:String,startX:int,startY:int):TextInput{
			var title:TextField = ComponentUtil.createTextField(proName,startX,startY,Style.themeTextFormat,NaN,20,this);
			title.textColor = 0xfffd4b;
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			title.width = title.textWidth+4;
			var textInput:TextInput = ComponentUtil.createTextInput(startX+title.width,startY,110,25,this);
			textInput.textField.textColor = 0xffb14b;
			textInput.enabled = false;
			return textInput;
		}
		
		public function createNav():void {
			if (nav.tabBar.buttonList.length > 0) {
				nav.tabBar.removeItems();
				nav.tabContainer.removeItems();
			}
			switch (GlobalObjectManager.getInstance().user.attr.category) {
				case 1:
					selectCategory = SkillConstant.CATEGORY_WARRIOR;
					nav.addItem(SkillConstant.CATEGORY_LABEL_WARRIOR, skillItem, 60, 25);
					break;
				case 2:
					selectCategory = SkillConstant.CATEGORY_ARCHER;
					nav.addItem(SkillConstant.CATEGORY_LABEL_ARCHER, skillItem, 60, 25);
					break;
				case 3:
					selectCategory = SkillConstant.CATEGORY_RANGER;
					nav.addItem(SkillConstant.CATEGORY_LABEL_RANGER, skillItem, 60, 25);
					break;
				case 4:
					selectCategory = SkillConstant.CATEGORY_PRIEST;
					nav.addItem(SkillConstant.CATEGORY_LABEL_PRIEST, skillItem, 60, 25);
					break;
			}
//			if (GlobalObjectManager.getInstance().user.attr.level >= 20) {
//				nav.addItem(SkillConstant.CATEGORY_LABEL_FAMILY, familySkill, 60, 25);
//			}
			nav.addItem(SkillConstant.CATEGORY_LABEL_PETGROW, petGrow, 60, 25);
			nav.addItem(SkillConstant.CATEGORY_LABEL_LIFE, lifeSkill, 60, 25);
			var l:int=nav.tabBar.buttonList.length;
			labels=[];
			for (var i:int=0; i < l; i++) {
				labels.push(nav.tabBar.buttonList[i].label);
			}
		}
		
		public function updateMoneyExp():void{
			currentSilver.text = MoneyTransformUtil.silverToOtherString(GlobalObjectManager.getInstance().user.attr.silver);
			currentExp.text = GlobalObjectManager.getInstance().user.attr.exp.toString();
		}
		
		public function skillItemClickHandler(event:DataEvent=null):void {
			event.stopPropagation();
			skillUpGradePanel.updata(SkillDataManager.getSkill(int(event.data)));
			setSelectItem(event.target);
		}
		
		public function setSelectSkill(id:int):void{
			skillUpGradePanel.updata(SkillDataManager.getSkill(id));
			setSelectItem(items[id]);
		}
		
		public function setSelectItem(item:Object):void {
			if (item == selectItem)
				return;
			if (item is FamilySkillItem) {

				item.selected=true;
				item.selectbg.visible=true;
			} else if (item is SkillItem) {
				item.select=true;
			}
			if (selectItem) {
				if (selectItem is FamilySkillItem) {
					selectItem.selected=false;
					selectItem.selectbg.visible=false;
				} else if (selectItem is SkillItem) {
					selectItem.select=false;
				}
			}
			selectItem=item;
		}

		public function seleteIndex(value:String):void {
			var index:int=0;
			if (value == "") {
				value = SkillConstant.categorys[SkillDataManager.getMaxCategory()]
			}
			switch (value) {
				case "":
					index=0;
					break;
				case SkillConstant.CATEGORY_LABEL_WARRIOR:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_WARRIOR);
					break;
				case SkillConstant.CATEGORY_LABEL_ARCHER:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_ARCHER);
					break;
				case SkillConstant.CATEGORY_LABEL_RANGER:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_RANGER);
					break;
				case SkillConstant.CATEGORY_LABEL_PRIEST:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_PRIEST);
					break;
				case SkillConstant.CATEGORY_LABEL_FAMILY:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_FAMILY);
					break;
				case SkillConstant.CATEGORY_LABEL_LIFE:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_LIFE);
					break;
				case SkillConstant.CATEGORY_LABEL_PETGROW:
					index=labels.indexOf(SkillConstant.CATEGORY_LABEL_PETGROW);
					break;
			}
			if (this.nav)
				this.nav.selectedIndex=index;
		}

		private function onNavChangeHandler(e:TabNavigationEvent):void {
			dispatchEvent(e);
			var btnLabel:String=nav.tabBar.buttonList[e.index].label;
			skillUpGradePanel.visible=true;
			nav.width = 320;
			//			bg.visible = true;
			switch (btnLabel) {
				case SkillConstant.CATEGORY_LABEL_WARRIOR:
					var skillId:int = int(GlobalObjectManager.getInstance().user.attr.category+"1101001");
					selectCategory=SkillConstant.CATEGORY_WARRIOR;
					skillUpGradePanel.updata(SkillDataManager.getSkill(skillId));
					setSelectItem(items[skillId]);
					break;
				case SkillConstant.CATEGORY_LABEL_FAMILY:
					selectCategory=SkillConstant.CATEGORY_FAMILY;
					skillUpGradePanel.updata(SkillDataManager.getSkill(71109001));
					updata();
					setSelectItem(items[71109001]);
					break;
				case SkillConstant.CATEGORY_LABEL_LIFE:
					selectCategory=SkillConstant.CATEGORY_LIFE;
					skillUpGradePanel.updata(SkillDataManager.getSkill(9999991));
					updata();
					setSelectItem(items[9999991]);
					break;
				case SkillConstant.CATEGORY_LABEL_PETGROW:
					skillUpGradePanel.visible=false;
					//PetModule.getInstance().toPetGrowInfo();
					//bg.visible = false;
					nav.width = 520;
					break;
			}
		}

		/**
		 * 确定按钮点击函数
		 */
		private function onOKHandler(event:MouseEvent):void {
			closeWindowHandler(null);
		}


		/**
		 * 关闭按钮点击函数
		 * @param event
		 */
		private function closeWindowHandler(event:CloseEvent):void {
			WindowManager.getInstance().removeWindow(this);
		}

		/**
		 *
		 * 刷新界面
		 *
		 */
		public function updata():void {
			switch (selectCategory) {
				case SkillConstant.CATEGORY_WARRIOR:
				case SkillConstant.CATEGORY_ARCHER:
				case SkillConstant.CATEGORY_RANGER:
				case SkillConstant.CATEGORY_PRIEST:
					if (!skillItem.hasTree) {
						skillItem.createTree(SkillDataManager.getCategory(selectCategory));
					} else {
						skillItem.check();
					}
					break;
				case SkillConstant.CATEGORY_FAMILY:
//					if (!familySkill.hasTree) {
//						familySkill.createTree(SkillDataManager.getCategory(SkillConstant.CATEGORY_FAMILY));
//					} else {
//						familySkill.check();
//					}
					break;
				case SkillConstant.CATEGORY_LIFE:
					if (!lifeSkill.hasTree) {
						lifeSkill.createTree(SkillDataManager.getCategory(SkillConstant.CATEGORY_LIFE));
					} else {
						lifeSkill.check();
					}
					break;
			}
			if(skillUpGradePanel.skillVO)skillUpGradePanel.updata(skillUpGradePanel.skillVO);
		}
		
		public function updatePetGrowInfo(info:p_role_pet_grow, configs:Array):void{
			petGrow.update(info,configs);
		}
	}
}