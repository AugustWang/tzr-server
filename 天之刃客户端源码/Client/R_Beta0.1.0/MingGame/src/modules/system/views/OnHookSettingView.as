package modules.system.views {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.ming.ui.controls.Slider;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.style.StyleManager;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.scene.SceneDataManager;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	import modules.system.SystemConfig;

	public class OnHookSettingView extends Sprite implements ISetting {
		private var c1:Sprite;
		private var c2:Sprite;
		private var c3:Sprite;
		
		private var monsterList:Canvas;
		
		private var equipsColor:ColorCheckBox;
		private var othersColor:ColorCheckBox;
		private var autoJoinTeam:CheckBox;
		
		private var hpCheckBox:CheckBox;
		private var hp:TextInput;
		private var hpUseItems:UseItems;
		private var mpCheckBox:CheckBox;
		private var mp:TextInput;
		private var mpUseItems:UseItems;
		private var petCheckBox:CheckBox;
		private var pet:TextInput;
		private var petUseItems:UseItems;
		private var backTown:CheckBox;
		
		private var pickEquip:CheckBox;
		private var pickOther:CheckBox;
		
		private var autoSkill:CheckBox;
		private var autoPetSkill:CheckBox;
		private var skill1:AutoSkillItem;
		private var skill2:AutoSkillItem;
		private var skill3:AutoSkillItem;
		private var skill4:AutoSkillItem;
		private var skill5:AutoSkillItem;
		private var skill6:AutoSkillItem;
		private var skill7:AutoSkillItem;
		private var skill8:AutoSkillItem;
		private var skill9:AutoSkillItem;
		private var skill10:AutoSkillItem;


		private var gdata:AutoSystemVo=AutoSystemVo.instance

		private var selectedAll:Boolean; //选择全部怪，还是不选择全部怪
		
		public static const chkTF:TextFormat = new TextFormat("",12,0xa0ecef);
		public function OnHookSettingView() {
			super();
			initView();
			addEventListener(DragItemEvent.DRAG_THREW, onDragThrew);
		}

		private function initView():void {
			var chkTf:TextFormat = Style.textFormat;
			chkTf.color = 0xa0ecef;
			
			c3=createBorder(0, 0, 539, 120);
			c2=createBorder(0, 122, 273, 210);
			c1=createBorder(276, 122, 263, 210);
			
			hpCheckBox = ComponentUtil.createCheckBox("",10,10,c1);
			mpCheckBox = ComponentUtil.createCheckBox("",10,66,c1);
			petCheckBox = ComponentUtil.createCheckBox("",10,124,c1);
			
			ComponentUtil.createTextField("生命值小于        %时，自动使用生命药", 30, 10, null, 250, 22, c1,wrapperTextHandler);
			ComponentUtil.createTextField("内力值小于        %时，自动使用内力药", 30, 66, null, 250, 22, c1,wrapperTextHandler);
			ComponentUtil.createTextField("宠物血小于        %时，自动使用宠物药", 30, 124, null, 250, 22, c1,wrapperTextHandler);
			hp=createTextInput(92, 	11, c1);
			mp=createTextInput(92, 67, c1);
			pet=createTextInput(92, 125, c1);
			
			hpUseItems = new UseItems();
			hpUseItems.y = 28;
			hpUseItems.x = 30;
			c1.addChild(hpUseItems);
			
			mpUseItems = new UseItems();
			mpUseItems.y = 84;
			mpUseItems.x = 30;
			c1.addChild(mpUseItems);
			
			petUseItems = new UseItems();
			petUseItems.y = 142;
			petUseItems.x = 30;
			c1.addChild(petUseItems);
			
			backTown=ComponentUtil.createCheckBox("药品耗尽时，自动使用回城卷", 10, 180, c1);
			backTown.textFormat = chkTf
			backTown.textFilter = FilterCommon.FONT_BLACK_FILTERS;

			equipsColor=new ColorCheckBox();
			equipsColor.label="拾取装备";
			equipsColor.x=10;
			equipsColor.y=10;
			c2.addChild(equipsColor);
			othersColor=new ColorCheckBox();
			othersColor.label="拾取道具";
			othersColor.x=10;
			othersColor.y=33;
			c2.addChild(othersColor);
			
			autoJoinTeam = new CheckBox();
			autoJoinTeam.textFormat = Style.textFormat;
			autoJoinTeam.x = 10;
			autoJoinTeam.y = 58;
			autoJoinTeam.text = "自动自动入队";
			autoJoinTeam.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			autoJoinTeam.textFormat = chkTf;
			c2.addChild(autoJoinTeam);
		
			
			autoSkill=ComponentUtil.createCheckBox("自动释放技能", 10, 85, c2);
			autoSkill.textFormat = chkTf;
			autoSkill.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			
			var c33:Sprite=new Sprite;
			skill1=createSkillItem();
			skill2=createSkillItem();
			skill3=createSkillItem();
			skill4=createSkillItem();
			skill5=createSkillItem();
			skill6=createSkillItem();
			skill7=createSkillItem();
			skill8=createSkillItem();
			skill9=createSkillItem();
			skill10=createSkillItem();
			sonOfBitch(c33, [skill1, skill2, skill3, skill4, skill5,skill6,skill7,skill8,skill9,skill10]);
			c33.x=10;
			c33.y = 110;
			LayoutUtil.layoutGrid(c33,5,10,6);
			c2.addChild(c33);
			LayoutUtil.layoutVectical(c3, 3, 10);
			autoPetSkill=ComponentUtil.createCheckBox("自动释放宠物技能", 128, 85, c2);
			autoPetSkill.textFormat = chkTf;
			autoPetSkill.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			var tip:TextField=ComponentUtil.createTextField("地图怪物列表", 5, 6, null, 200, NaN, c3);
			tip.filters = FilterCommon.FONT_BLACK_FILTERS;
			monsterList=new Canvas;
			monsterList.bgSkin = Style.getPanelContentBg();
			monsterList.width=519;
			monsterList.height=85;
			monsterList.x=10;
			monsterList.y=30;
			c3.addChild(monsterList);
			
			var simpleMonsterBtn:Button = ComponentUtil.createButton("普通怪",295,5,70,25,c3);
			simpleMonsterBtn.data = "simple"
			simpleMonsterBtn.addEventListener(MouseEvent.CLICK,onSelectMonsterType);
			var advanceMonsterBtn:Button = ComponentUtil.createButton("高级怪",375,5,70,25,c3);
			advanceMonsterBtn.data = "hide";
			advanceMonsterBtn.addEventListener(MouseEvent.CLICK,onSelectMonsterType);
			var allMonsterBtn:Button = ComponentUtil.createButton("全部怪",455,5,70,25,c3);
			allMonsterBtn.data = "all";
			allMonsterBtn.addEventListener(MouseEvent.CLICK,onSelectMonsterType);


			var tf:TextField=ComponentUtil.createTextField("", 10, 258, null, 240, 50, c3);
			tf.mouseEnabled=true;
			tf.addEventListener(TextEvent.LINK, onTextLink);
			tf.textColor=0xffff00;
			tf.htmlText="小提示：京城-张三丰，可进行<a href='event:prompt'><u>" + HtmlUtil.font("离线挂机", "#00ff00") + "</u></a>";
			tf.wordWrap=true;
		}

		
		private function wrapperTextHandler(text:TextField):void{
			text.textColor = 0xa0ecef;
			text.filters = FilterCommon.FONT_BLACK_FILTERS;
		}
		
		private function onSliderChange(event:Event):void{
			var target:Slider = event.currentTarget as Slider;
			switch(target.name){
				case "roleHP": hp.text = target.value.toString();break;
				case "roleMP": mp.text = target.value.toString();break;
				case "petHP": pet.text = target.value.toString();break;
			}
		}
		
		private var alertKey:String="";
		private function onTextLink(event:TextEvent):void {
			Dispatch.dispatch(ModuleCommand.OPEN_TRAIN);
		}

		private function yesHandler():void {
			var faction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String="1" + faction + "000109";
			PathUtil.carryNPC(npcId);
		}

		private function noHandler():void {
			var faction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String="1" + faction + "000109";
			PathUtil.findNPC(npcId);
		}

		private function onSelectMonsterType(e:MouseEvent):void {
			switch (e.currentTarget.data) {
				case "simple":
					updateSelectedMonster(1);
					break;
				case "hide":
					updateSelectedMonster(2);
					break;
				case "all":
					if (selectedAll == false) {
						updateSelectedMonster(3);
					} else {
						updateSelectedMonster(5); //全部不选
					}
					selectedAll=!selectedAll;
					break;
			}
		}

		//更新怪物打钩,1,普通怪。2,高级怪，3,全部怪。4，systemConfig记录的怪
		private function updateSelectedMonster(type:int=1):void {
			for (var i:int=0; i < monsterList.numChildren; i++) {
				var c:CheckBox=monsterList.getChildAt(i) as CheckBox;
				c.selected=false;
				if (c) {
					var mt:MonsterType=c.data as MonsterType;
					switch (type) {
						case 1:
							if (mt.rarity == 1) {
								c.selected=true;
							}
							break;
						case 2:
							if (mt.rarity > 1) {
								c.selected=true;
							}
							break;
						case 3:
							c.selected=true;
							break;
						case 4:
							if (SystemConfig.hitMonsters[mt.type]) {
								c.selected=true;
							}
							break;
						default:
							break;
					}
				}
			}
		}

		private function setMonsterNames(monsters:Dictionary):void {
			var monsterNams:Array=[];
			var simple:Array=[];
			var high:Array=[];
			for each (var monster:MonsterType in monsters) {
				monsterNams.push(monster.monstername);
				if (monster.rarity == 1) {
					simple.push(monster);
				} else if (monster.rarity > 1) {
					high.push(monster);
				}
			}
			resetTargetList(simple.concat(high));
		}

		//切地图时宠物列表
		private function resetTargetList(arr:Array):void {
			while (monsterList.numChildren > 0) {
				var t:CheckBox=monsterList.getChildAt(monsterList.numChildren - 1) as CheckBox;
				if (t) {
					t.dispose();
				}
			}
			for (var i:int=0; i < arr.length; i++) {
				var px:Number=i % 4 * 120 + 4;
				var py:Number=int(i / 4) * 20+3;
				var mt:MonsterType=arr[i];
				var str:String=mt.monstername.length > 4 ? (mt.monstername.substr(0, 4) + "..") : mt.monstername;
				var c:CheckBox=ComponentUtil.createCheckBox(str + "(" + mt.level + "级)", px, py, monsterList);
				c.textFormat = chkTF;
				c.textFilter = FilterCommon.FONT_BLACK_FILTERS;
				c.addEventListener(MouseEvent.ROLL_OVER, showCheckBoxTip);
				c.addEventListener(MouseEvent.ROLL_OUT, hideTip);
				c.data=mt;
				if (mt.rarity > 1) {
					c.htmlText=HtmlUtil.font(str + "(" + mt.level + "级)", "#ff0000");
				}
			}
		}

		private function showCheckBoxTip(e:MouseEvent):void {
			var c:CheckBox=e.target as CheckBox;
			if (c) {
				ToolTipManager.getInstance().show(c.data.monstername, 0);
			}
		}

		private function hideTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		//跟进checkBox找出要打的怪
		private function getAttackMonsters():Dictionary {
			var dict:Dictionary=new Dictionary;
			for (var i:int=0; i < monsterList.numChildren; i++) {
				var c:CheckBox=monsterList.getChildAt(i) as CheckBox;
				if (c) {
					if (c.selected == true) {
						dict[c.data.type]=c.data;
					}
				}
			}
			return dict;
		}

		private function createBorder(x:Number, y:Number, w:Number=268, h:Number=127):Sprite {
			var border:UIComponent = ComponentUtil.createUIComponent(x,y,w,h);
			Style.setBorderSkin(border);
			addChild(border);
			return border;
		}

		private function createSkillItem():AutoSkillItem {
			var item:AutoSkillItem=new AutoSkillItem();
			item.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			item.addEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
			item.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
			return item;
		}

		private function mouseOverHandler(event:MouseEvent):void {
			var item:AutoSkillItem=event.currentTarget as AutoSkillItem;
			if (item.data is SkillVO) {
				ToolTipManager.getInstance().show(SkillDataManager.createHotKeyTooltip(item.data as SkillVO), 500, 0, 0, "goodsToolTip");
			}
		}

		private function mouseOutHandler(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onDragThrew(event:DragItemEvent):void {
			var item:AutoSkillItem=event.dragTarget.parent as AutoSkillItem;
			if (item) {
				item.disposeContent();
			}
		}

		private function onMouseDown(event:MouseEvent):void {
			var item:AutoSkillItem=event.currentTarget as AutoSkillItem;
			if (item && item.data) {
				DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.SETTINGSKILL_ITEM, item.data);
			}
		}

		private function createTextInput(x:Number, y:Number, parent:Sprite, min:int=1, max:int=99):TextInput {
			var t:TextInput=new TextInput;
			t.restrict="[0-9]";
			t.x=x;
			t.y=y;
			t.width=30;
			t.height=20;
			t.maxChars = 3;
			t.addEventListener(Event.CHANGE, onChange);
			parent.addChild(t);
			function onChange(evt:Event):void {
				var size:int=parseInt(t.text);
				if (size > max) {
					t.text=max.toString();
				}
				if (size < min) {
					t.text=min.toString();
				}
			}
			return t;
		}

		private function sonOfBitch(parent:Sprite, arr:Array):void {
			for (var i:int=0; i < arr.length; i++) {
				parent.addChild(arr[i]);
			}
		}

		public function save():void {
			
			SystemConfig.autoUseHP = hpCheckBox.selected;
			SystemConfig.autoUseMP = mpCheckBox.selected;
			SystemConfig.autoUsePet = petCheckBox.selected;
			SystemConfig.hp=int(hp.text) / 100;
			SystemConfig.mp=int(mp.text) / 100;
			SystemConfig.pet=int(pet.text) / 100;
			SystemConfig.autobuyHC=backTown.selected;

			SystemConfig.hpUseBitToBig = hpUseItems.selectedIndex == 0  ? true : false;
			SystemConfig.mpUseBitToBig = mpUseItems.selectedIndex == 0  ? true : false;
			SystemConfig.petUseBitToBig = petUseItems.selectedIndex == 0  ? true : false;
			
			SystemConfig.autoPickEquip=equipsColor.selected;
			SystemConfig.autoPickother=othersColor.selected;
			SystemConfig.pickEquipColors=equipsColor.selectedColors;
			SystemConfig.pickOtherColors=othersColor.selectedColors;

			SystemConfig.autoAcceptTeam = autoJoinTeam.selected;
			
			SystemConfig.autoSkill=autoSkill.selected;
			SystemConfig.autoPetSkill=autoPetSkill.selected;
			SystemConfig.skills=[skill1.data, skill2.data, skill3.data, skill4.data, skill5.data, skill6.data, skill7.data, skill8.data, skill9.data, skill10.data];
			SystemConfig.hitMonsters=getAttackMonsters();

		}

		public function skillReset():void {
			skill1.data=SystemConfig.skills[0];
			skill2.data=SystemConfig.skills[1];
			skill3.data=SystemConfig.skills[2];
			skill4.data=SystemConfig.skills[3];
			skill5.data=SystemConfig.skills[4];
			skill6.data=SystemConfig.skills[5];
			skill7.data=SystemConfig.skills[6];
			skill8.data=SystemConfig.skills[7];
			skill9.data=SystemConfig.skills[8];
			skill10.data=SystemConfig.skills[9];
		}

		public function reset():void {
			SystemConfig.resetAutoSetting();
			init();
		}

		public function init():void {
			hpCheckBox.setSelected(SystemConfig.autoUseHP);
			mpCheckBox.setSelected(SystemConfig.autoUseMP);
			petCheckBox.setSelected(SystemConfig.autoUsePet);
			hp.text=String(SystemConfig.hp * 100);
			mp.text=String(SystemConfig.mp * 100);
			pet.text=String(SystemConfig.pet * 100);
			
			hpUseItems.selectedIndex = SystemConfig.hpUseBitToBig ? 0 : 1;
			mpUseItems.selectedIndex = SystemConfig.mpUseBitToBig ? 0 : 1;
			petUseItems.selectedIndex = SystemConfig.petUseBitToBig ? 0 : 1;
			
			backTown.selected=SystemConfig.autobuyHC;

			equipsColor.selected=SystemConfig.autoPickEquip;
			othersColor.selected=SystemConfig.autoPickother;

			equipsColor.selectedColors=SystemConfig.pickEquipColors;
			othersColor.selectedColors=SystemConfig.pickOtherColors;

			autoJoinTeam.setSelected(SystemConfig.autoAcceptTeam);
			
			autoSkill.selected=SystemConfig.autoSkill;
			autoPetSkill.selected=SystemConfig.autoPetSkill;
			skill1.data=SystemConfig.skills[0];
			skill2.data=SystemConfig.skills[1];
			skill3.data=SystemConfig.skills[2];
			skill4.data=SystemConfig.skills[3];
			skill5.data=SystemConfig.skills[4];
			skill6.data=SystemConfig.skills[5];
			skill7.data=SystemConfig.skills[6];
			skill8.data=SystemConfig.skills[7];
			skill9.data=SystemConfig.skills[8];
			skill10.data=SystemConfig.skills[9];
			setMonsterNames(SceneDataManager.getMonsters());
			updateSelectedMonster(4); //保存的那些怪打钩
			SystemConfig.hitMonsters=getAttackMonsters();
		}

		//换地图时执行
		public function changeHitMonster():void {
			setMonsterNames(SceneDataManager.getMonsters());
			updateSelectedMonster(4);
			SystemConfig.hitMonsters=getAttackMonsters();
		}
		
		public function teamCheckBoxChange():void{
			autoJoinTeam.setSelected(SystemConfig.autoAcceptTeam);
		}
		
		public function onHPAutoChange(per:int):void {
			hp.text=per.toString();
		}
		
		public function onMPAutoChange(per:int):void {
			mp.text=per.toString();
		}
	}
}
import com.common.FilterCommon;
import com.common.GameColors;
import com.ming.ui.controls.CheckBox;
import com.ming.ui.controls.RadioButton;
import com.ming.ui.controls.RadioButtonGroup;
import com.utils.ComponentUtil;

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextFormat;

class ColorCheckBox extends Sprite {
	private var mainChk:CheckBox;

	private var white:CheckBox;
	private var green:CheckBox;
	private var blue:CheckBox;
	private var purple:CheckBox;
	private var orange:CheckBox;

	public function ColorCheckBox() {
		mainChk=ComponentUtil.createCheckBox("", 0, 0, this);
		mainChk.addEventListener(Event.CHANGE, onChanged);
	}

	public function get selectedColors():Array {
		var colors:Array=[white.selected, green.selected, blue.selected, purple.selected, orange.selected];
		return colors;
	}

	public function set selectedColors(value:Array):void {
		white.selected=value[0];
		green.selected=value[1];
		blue.selected=value[2];
		purple.selected=value[3];
		orange.selected=value[4];
	}

	public function get selected():Boolean {
		return mainChk.selected;
	}

	public function set selected(value:Boolean):void {
		mainChk.selected=value;
	}

	public function set label(value:String):void {
		mainChk.text=value;
		mainChk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
		createChildren();
	}

	private function onChanged(event:Event):void {
		white.selected=green.selected=blue.selected=purple.selected=orange.selected=mainChk.selected;
	}

	private function createChildren():void {
		var startX:Number=mainChk.width;
		var tf:TextFormat = Style.textFormat;
		tf.color = GameColors.COLOR_VALUES[1];
		white=ComponentUtil.createCheckBox("白", startX, 0, this, wrapper);
		white.textFormat = tf;
		tf.color = GameColors.COLOR_VALUES[2];
		green=ComponentUtil.createCheckBox("绿", startX + 34, 0, this, wrapper);
		green.textFormat = tf;
		tf.color = GameColors.COLOR_VALUES[3];
		blue=ComponentUtil.createCheckBox("蓝", startX + 68, 0, this, wrapper);
		blue.textFormat = tf;
		tf.color = GameColors.COLOR_VALUES[4];
		purple=ComponentUtil.createCheckBox("紫", startX + 102, 0, this, wrapper);
		purple.textFormat = tf;
		tf.color = GameColors.COLOR_VALUES[5];
		orange=ComponentUtil.createCheckBox("橙", startX + 136, 0, this, wrapper);
		orange.textFormat = tf;
		onChanged(null);
	}

	private function wrapper(ck:CheckBox):void {
		ck.width = 35;
		ck.textFilter = FilterCommon.FONT_BLACK_FILTERS;
		ck.addEventListener(Event.CHANGE, onCheckBoxChanged);
	}

	private function onCheckBoxChanged(event:Event):void {
		var ck:CheckBox=CheckBox(event.currentTarget);
		if (ck.selected && mainChk.selected == false) {
			mainChk.setSelected(true);
		}
	}
}
class UseItems extends RadioButtonGroup{
	public var bitToBig:RadioButton;
	public var bigToBit:RadioButton;
	public function UseItems():void{
		super();
		direction = RadioButtonGroup.VERTICAL;
		space = 1;
		height = 32;
		var tf:TextFormat = Style.textFormat;
		tf.color = 0xffff00;
		
		bigToBit = new RadioButton("从大到小自动使用药品");
		bigToBit.textFilter = FilterCommon.FONT_BLACK_FILTERS;
		bigToBit.textFormat = tf;
		addItem(bigToBit);
		
		bitToBig = new RadioButton("从小到大自动使用药品");
		bitToBig.textFilter = FilterCommon.FONT_BLACK_FILTERS;
		bitToBig.textFormat = tf;
		addItem(bitToBig);
		
	}
}