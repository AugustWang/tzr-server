package modules.skillTree.views {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	import com.utils.PathUtil;
	
	import flash.display.Bitmap;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.scene.SceneDataManager;
	import modules.shop.ShopModule;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.ConditionVO;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;

	public class SkillUpGradePanel extends UIComponent {
		private static const UPGRADE:int=1;
		private static const NO_UPGRADE:int=2;

		private var icon:Image;
		private var nameTxt:TextField;
		
		private var skillTypeText:TextInput;
		private var skillDistanceText:TextInput;
		private var skillCDText:TextInput;
		private var skillConsumeText:TextInput;
		
		//private var skillFunctionText:TextField;
		private var skillDesc:TextField;
		
		private var conditionTxt:TextField;
		private var upgradeBtn:Button;
		private var conditionTxtFormat:TextFormat;
		private var categoryPoints:Array=["", "已学战士点数：", "已学射手点数：", "已学侠客点数：", "已学医仙点数："]

		private var initEnd:Boolean=false;

		public var skillVO:SkillVO;
		public var state:int;

		public function SkillUpGradePanel() {
		}

		public function initView():void {

			mouseEnabled = false;
			
			var iconBg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			addChild(iconBg);
			iconBg.x=5;
			iconBg.y=6;

			//左上角图标
			icon=new Image();
			addChild(icon);
			icon.x=9;
			icon.y=10;

			nameTxt=new TextField();
			addChild(nameTxt);
			nameTxt.mouseEnabled = false;
			nameTxt.x=60;
			nameTxt.y=16;
			nameTxt.width = 140;
			var nameTxtFormat:TextFormat=new TextFormat();
			nameTxtFormat.size=14;
			nameTxtFormat.color=0xFFFFFF;

			nameTxt.defaultTextFormat=nameTxtFormat
			nameTxt.filters=FilterCommon.FONT_BLACK_FILTERS;
			
			nameTxtFormat.size = 12;
			nameTxtFormat.color = 0xffffff;
			
			skillTypeText = createTextInput("技能类型：",5,48);
			skillDistanceText = createTextInput("释放距离：",5,73);
			skillCDText = createTextInput("冷却时间：",5,98);
			skillConsumeText = createTextInput("消耗内力：",5,123);
			
			nameTxtFormat.color = 0xffd69b;
			skillDesc = new TextField();
			skillDesc.multiline = true;
			skillDesc.wordWrap = true;
			skillDesc.mouseEnabled=false;
			skillDesc.x = 5;
			skillDesc.y = 171;
			skillDesc.defaultTextFormat = nameTxtFormat;
			skillDesc.filters=FilterCommon.FONT_BLACK_FILTERS;
			skillDesc.width = 190;
			skillDesc.height = 80;
			addChild(skillDesc);

			conditionTxt=new TextField();
			addChild(conditionTxt);
			conditionTxt.width=190;
			conditionTxt.height=130;
			conditionTxt.x=5;
			conditionTxt.y=253;
			conditionTxt.wordWrap=true;
			conditionTxt.selectable=false;
			conditionTxtFormat=new TextFormat();
			conditionTxtFormat.leading=3;
			conditionTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			conditionTxt.defaultTextFormat=conditionTxtFormat;
			
			conditionTxt.addEventListener(TextEvent.LINK,openShopBuyView);

			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),3,150,this)
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.SKILL_UI,"skillDesc"),5,153,this);
			
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),3,230,this)
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.SKILL_UI,"skillCondition"),5,233,this);
			
			upgradeBtn=ComponentUtil.createButton("升级",125,355,70,25,this);
			upgradeBtn.textColor=0xffff00;
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpdataHandler);

			initEnd=true;
		}
		
		private function createTextInput(proName:String,startX:int,startY:int):TextInput{
			var title:TextField = ComponentUtil.createTextField(proName,startX,startY,Style.themeTextFormat,NaN,20,this);
			title.textColor = 0xfffd4b;
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			title.width = title.textWidth+4;
			var textInput:TextInput = ComponentUtil.createTextInput(startX+title.width,startY,110,25,this);
			textInput.leftPadding = 3;
			textInput.textField.textColor = 0xffb14b;
			textInput.enabled = false;
			return textInput;
		}
		
		private function openShopBuyView(event:TextEvent):void
		{
			var bookID:int = SkillDataManager.getBookID(skillVO.sid);
			ShopModule.getInstance().requestShopItem(30100,bookID, new Point(stage.mouseX-178, stage.mouseY-90),3);
		}

		private function onLink(event:TextEvent):void {
			if (event.text == "findNPC") {
				switch (SceneDataManager.mapData.map_id) {
					case 11000:
						PathUtil.findNpcAndOpen("11000108");
						break;
					case 12000:
						PathUtil.findNpcAndOpen("12000108");
						break;
					case 13000:
						PathUtil.findNpcAndOpen("13000108");
						break;
					case 11100:
						PathUtil.findNpcAndOpen("11100116");
						break;
					case 12100:
						PathUtil.findNpcAndOpen("12100116");
						break;
					case 13100:
						PathUtil.findNpcAndOpen("13100116");
						break;
				}
				switch (GlobalObjectManager.getInstance().user.base.faction_id) {
					case 1:
						PathUtil.findNpcAndOpen("11100116");
						break;
					case 2:
						PathUtil.findNpcAndOpen("12100116");
						break;
					case 3:
						PathUtil.findNpcAndOpen("13100116");
						break;
				}
			}
		}

		private var clickEnable:Boolean=true;
		private function onUpdataHandler(event:MouseEvent):void {
			if (clickEnable) {
				clickEnable=false;
				LoopManager.setTimeout(function fun():void {
						clickEnable=true
					}, 1000);
			} else {
				return;
			}
			if (skillVO.max_level == skillVO.level) {
				Tips.getInstance().addTipsMsg("该技能已经达到最高级！")
				BroadcastSelf.getInstance().appendMsg("该技能已经达到最高级！")
				return;
			}
			if (state == 0) {
				var msg:String="";
				var cs:Array=skillVO.levels[skillVO.level].conditions;
				for (var i:int=0; i < cs.length; i++) {
					if (!ckeckCondition(cs[i] as ConditionVO)) {
						switch (cs[i].name) {
							case "pre_role_level":
								msg="等级不够！";
								showError(msg);
								return;
							case "pre_skill":
								msg="前置技能未达到相应等级！";
								showError(msg);
								return;
							case 'need_item':
								msg="缺少技能书！";
								showError(msg);
								return;
							case 'need_silver':
								msg="银子不足！";
								showError(msg);
								return;
							case 'consume_exp':
								msg="经验不足！";
								showError(msg);
								return;
						}
					}
				}
			}
			var dataEvent:DataEvent=new DataEvent(SkillConstant.EVENT_SKILL_UPGRADE, true);
			
			dataEvent.data=skillVO.sid.toString();
			dispatchEvent(dataEvent);
		}

		private function ckeckCondition(c:ConditionVO):Boolean {

			if (c.data == '' || c.data == "0")
				return true;
			switch (c.name) {
				case 'pre_role_level':
					if (int(c.data) > GlobalObjectManager.getInstance().user.attr.level)
						return false;
					break;
				case 'pre_skill':
					var temp:Array=c.data.split(',');
					for (var i:int=0; i < temp.length; i+=2) {
						if (!checkPredecessorSkill(temp[i], temp[i + 1]))
							return false;
					}
					break;
				case 'need_item':
					if (PackManager.getInstance().getGoodsByType(int(c.data)).length == 0)
						return false;
					break;
				case 'need_silver':
					if (int(c.data) > (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().
						user.attr.silver_bind))
						return false;
					break;
				case 'consume_exp':
					if (Number(c.data) > GlobalObjectManager.getInstance().user.attr.exp)
						return false;
					break;
			}
			return true;
		}

		private function checkPredecessorSkill(skillID:int, skillLevel:int):Boolean {
			return SkillDataManager.getSkill(skillID).level >= skillLevel;
		}

		private function showError(msg:String):void {
			Tips.getInstance().addTipsMsg(msg)
			BroadcastSelf.getInstance().appendMsg(msg)
			return;
		}


		public function updata($skill:SkillVO):void {
			skillVO=$skill;
			if (!initEnd) {
				initView();
			}
			updateDescrition();
			if ($skill.category == SkillConstant.CATEGORY_FAMILY) {
				upgradeBtn.visible=false;
				conditionTxt.htmlText="<font color='#B7DDE6'>到门派地图-门派研究员学习升级该技能。</font>";
				conditionTxt.defaultTextFormat=conditionTxtFormat;
				icon.source=$skill.path;
				nameTxt.text=$skill.name+"   "+$skill.level+"级";
//				methodTxt.text=$skill.useMethod;
//				methodTxt.defaultTextFormat=methodTxtFormat;
				return;
			}
			if ($skill.level == $skill.max_level) {
				upgradeBtn.visible=false;
				conditionTxt.htmlText="<font color='#FF0000'>已达到最高级别</font>";
				conditionTxt.defaultTextFormat=conditionTxtFormat;
				icon.source=$skill.path;
				nameTxt.text=$skill.name+"   "+$skill.level+"级";
//				methodTxt.text=$skill.useMethod;
//				methodTxt.defaultTextFormat=methodTxtFormat;
				return;
			} else {
				upgradeBtn.visible=true;
				upgradeBtn.enabled=true;
				var cs:Array=skillVO.levels[skillVO.level].conditions;
				if (GlobalObjectManager.getInstance().user.attr.remain_skill_points != 0) {
					for (var i:int=0; i < cs.length; i++) {
						if (!ckeckCondition(cs[i] as ConditionVO)) {
							upgradeBtn.enabled=false;
						}
					}
				} else {
					upgradeBtn.enabled=false;
				}
				icon.source=$skill.path;
				nameTxt.text=$skill.name+"   "+$skill.level+"级";
				conditionTxt.htmlText=createConditionTxt($skill);
				conditionTxtFormat=new TextFormat();
				conditionTxtFormat.leading=3;
				conditionTxt.defaultTextFormat=conditionTxtFormat;
//				methodTxt.text=$skill.useMethod;
//				methodTxtFormat=new TextFormat();
//				methodTxtFormat.leading=3
//				methodTxt.defaultTextFormat=methodTxtFormat;
			}
		}
		
		private function updateDescrition():void{
			if(skillVO){
				var attackType:String = skillVO.attack_type == SkillConstant.ATTACK_TYPE_INITIATIVE ? "主动" : "被动";
				var level:int = Math.max(0,skillVO.level - 1);
				var skillItem:SkillLevelVO = skillVO.levels[level] as SkillLevelVO;
				var cooldown:Number = 0;
				var consume_mp:int = 0;
				if (skillItem){
					cooldown = skillItem.cooldown*0.001;
					consume_mp = skillItem.consume_mp;
					skillDesc.htmlText = skillItem.discription;
				}
				skillTypeText.text = attackType;
				skillDistanceText.text = skillVO.distance.toString();
				skillCDText.text = cooldown.toString();
				skillConsumeText.text = consume_mp.toString();
			}else{
				skillDesc.htmlText = "";
				skillTypeText.text = "";
				skillDistanceText.text = "";
				skillCDText.text = "";
				skillConsumeText.text = "";
			}
		}

		public function createConditionTxt(skillVO:SkillVO):String {
			var s:String=''
			var cs:Array=skillVO.levels[skillVO.level].conditions;
			for (var i:int=0; i < cs.length; i++) {
				var c:ConditionVO=cs[i];
				if (c.data == '')
					continue;
				switch (c.name) {
					case 'pre_role_level':
						if (int(c.data) > 0) {
							if (int(c.data) > GlobalObjectManager.getInstance().user.attr.level) {
								s=s.concat("<font color='#FF0000'>需要人物等级：" + c.data + "级</font>\n");
							} else {
								s=s.concat("<font color='#00FF00'>需要人物等级：" + c.data + "级</font>\n");
							}
						}
						break;
					case 'pre_skill':
						var temp:Array=c.data.split(',');
						for (var j:int=0; j < temp.length; j+=2) {
							if (checkPredecessorSkill(temp[j], temp[j + 1])) {
								s=s.concat("<font color='#00FF00'>" + SkillDataManager.getSkill(temp[j]).name + "达到等级:" +
									temp[j + 1] + "</font>\n");
							} else {
								s=s.concat("<font color='#FF0000'>" + SkillDataManager.getSkill(temp[j]).name + "达到等级:" +
									temp[j + 1] + "</font>\n");
							}
						}
						break;
					case 'need_item':
						if (int(c.data) > 0) {
							if (PackManager.getInstance().getGoodsByType(int(c.data)).length == 0) {
								if (skillVO.bookTip) {
									s=s.concat("<font color='#FF0000'>技能书：" + ItemLocator.getInstance().getGeneral(int(c.
										data)).name + "(怪物掉落)</font>\n");
								} else {
									s=s.concat("<font color='#FF0000'>技能书：" + ItemLocator.getInstance().getGeneral(int(c.
										data)).name+"</u></a></font>"+ "<font color='#00FF00'><a href='event:findNPC'><u>(快速购买)</u></a></font>\n");//"技能大师处购买"改为“快速购买” 
								}
							} else {
								s=s.concat("<font color='#00FF00'>技能书：" + ItemLocator.getInstance().getGeneral(int(c.data)).
									name + "</font>\n");
							}
						}
						break;
					case 'need_silver':
						if (int(c.data) > 0) {
							if (int(c.data) > (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.
								getInstance().user.attr.silver_bind)) {
								s=s.concat("<font color='#FF0000'>消耗银子：" + MoneyTransformUtil.silverToOtherString(Number(c.
									data)) + "</font>\n");
							} else {
								s=s.concat("<font color='#00FF00'>消耗银子：" + MoneyTransformUtil.silverToOtherString(Number(c.
									data)) + "</font>\n");
							}
						}
						break;
					case 'consume_exp':
						if (int(c.data) > 0) {
							if (Number(c.data) > GlobalObjectManager.getInstance().user.attr.exp) {
								s=s.concat("<font color='#FF0000'>消耗经验：" + c.data + "</font>\n");
							} else {
								s=s.concat("<font color='#00FF00'>消耗经验：" + c.data + "</font>\n");
							}
						}
						break;
				}
			}
			return s;
		}
	}
}