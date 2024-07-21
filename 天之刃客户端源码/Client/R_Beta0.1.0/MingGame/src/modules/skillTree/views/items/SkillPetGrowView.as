package modules.skillTree.views.items {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.pet.PetModule;
	import modules.skill.SkillConstant;
	
	import proto.common.p_grow_info;
	import proto.common.p_role_pet_grow;
	import proto.line.m_pet_grow_begin_tos;

	public class SkillPetGrowView extends UIComponent {
		public static const ITEM_CLICK:String="ITEM_CLICK";
		public static var state:int;
//		private var noticeTxt:TextField;
		private var timeLeftTxt:TextField;
		private var commitNowBtn:Button;
		private var BeginBtn:Button;
		private var timeLeft:int;
		private var timer:Timer;
		private var pvo:p_role_pet_grow;

		private var skin:Skin=new Skin();
		private var alertStr:String;
		private var growSkills:Array;
		private var isGrowing:Bitmap;
		private var selectImg:Image;
		private var selectLevelTxt:TextField;
		private var skillDescTxt:TextField;
		private var curLevelEffectTxt:TextField;
		private var NextLevelEffectTxt:TextField;
		private var LeftTimeImg:Bitmap;
		private var needRoleLevelTxt:TextField;
		private var needGrowLevelTxt:TextField;
		private var needSilverTxt:TextField;
		private var needGoldTxt:TextField;
		private var growLevelFlag:Array; //检查强化。
		private var selectItem:PetGrowItem;
		private var checkFilterArr:Array;

		public function SkillPetGrowView() {
			this.width=520;
			this.height=300;
			this.y = 2;
			this.x = 2;
			growLevelFlag=[];
			checkFilterArr=[0, 0, 0, 0, 0]; //训练中其它技能均为灰色。
			//growLevelFlag=[1,1,1,1,1];//初始化，每个强化为1.
			var btw:TextFormat=new TextFormat(null, null, 0xd0f6fc);
			var bt:TextFormat=new TextFormat(null, null, 0xebe7ba); //---强化颜色
			var bty:TextFormat=new TextFormat(null, null, 0xffff00);
			
			var bg:Bitmap=Style.getBitmap(GameConfig.SKILL_UI,"petSkillTree");
			bg.y =20;
			bg.x =2;
			addChild(bg);
			
			var part1:Sprite= new Sprite();
//			noticeTxt=ComponentUtil.createTextField("", 22, 10, bt, 300, 22, part1);
//			noticeTxt.htmlText="训练驯宠能力，可增加<font color='#00ff00'>所有宠物</font>在<font color='#00ff00'>出战</font>时的属性";

			isGrowing=Style.getBitmap(GameConfig.SKILL_UI,"xunlianzhong");
			isGrowing.x=100;
			isGrowing.y=320;
			isGrowing.visible=false;
			part1.addChild(isGrowing);
			growSkills=new Array();
			for (var i:int=1; i <= 5; i++) {
				var petGrow:PetGrowItem=new PetGrowItem(i);
				growSkills[i]=petGrow;
				part1.addChild(petGrow);
			}
			this.addChild(part1);


			var part2:Sprite=new Sprite();
			part2.x=330;
			part2.y=0;
			this.addChild(part2);

			var iconBg:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			iconBg.x = iconBg.y = 4;
			part2.addChild(iconBg);
			iconBg.x=5;
			iconBg.y=12;
			selectImg=new Image();
			selectImg.x=4;
			selectImg.y=4;
			iconBg.addChild(selectImg);

			selectLevelTxt=ComponentUtil.createTextField("力敌千钧：1级", 62, 19, bt, 100, 22, part2);
			selectLevelTxt.filters = FilterCommon.FONT_BLACK_FILTERS;

			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),0,52,part2)
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.SKILL_UI,"skillDesc"),5,55,part2);
			skillDescTxt = ComponentUtil.createTextField("", 0, 75, bt, 220, 60, part2);
			skillDescTxt.wordWrap = true;
			skillDescTxt.multiline = true;
			skillDescTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),0,130,part2)
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.SKILL_UI,"currentLevelEffect"),5,133,part2);
			curLevelEffectTxt=ComponentUtil.createTextField("宠物力量+3", 0, 153, bt, 220, 22, part2);
			curLevelEffectTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),0,191,part2)
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.SKILL_UI,"nextLevelEffect"),5,194,part2);
			NextLevelEffectTxt=ComponentUtil.createTextField("宠物力量+5", 0, 214, bt, 220, 22, part2);	
			NextLevelEffectTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
						
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),0,260,part2)
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.SKILL_UI,"skillCondition"),5,263,part2);
			
			LeftTimeImg=Style.getBitmap(GameConfig.SKILL_UI,"shengyushijian");
			LeftTimeImg.x=0;
			LeftTimeImg.y=322;
			part2.addChild(LeftTimeImg);

			needRoleLevelTxt=ComponentUtil.createTextField("角色等级： 15", 0, 283, bt, 160, 22, part2);
			needRoleLevelTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			needGrowLevelTxt=ComponentUtil.createTextField("以柔克刚： 1级", 0, 308, bt, 180, 22, part2);
			needGrowLevelTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			needSilverTxt=ComponentUtil.createTextField("银子： 50文", 0, 333, bt, 160, 22, part2);
			needSilverTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			needGoldTxt=ComponentUtil.createTextField("花费2个元宝", 80, 367, bty, 160, 22, part2);
			needGoldTxt.filters = FilterCommon.FONT_BLACK_FILTERS;

			timeLeftTxt=ComponentUtil.createTextField("00分05秒", 70, 320, bt, 186, 22, part2);
			timeLeftTxt.textColor=0xff0000;
			commitNowBtn=ComponentUtil.createButton("立刻完成", 125, 366, 70, 25, part2);
			commitNowBtn.addEventListener(MouseEvent.CLICK, toCommit);

			BeginBtn=ComponentUtil.createButton("开始训练", 125, 366, 70, 25, part2);
			BeginBtn.addEventListener(MouseEvent.CLICK, toBegin);

			addEventListener(SkillConstant.EVENT_PET_GROW_ITEM_CLICK, onSelectPetGrow);

			if (timer == null) {
				timer=new Timer(1000, 0);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
			}
			selectItem=growSkills[5] as PetGrowItem;
			selectItem.select=true;
			Dispatch.dispatch(ModuleCommand.GET_PET_GROW_INFO);
		}

		public function update(roleGrowInfo:p_role_pet_grow, growConfigs:Array):void {
			state=roleGrowInfo.state;
			pvo=roleGrowInfo;

			growConfigs.sortOn("type", Array.NUMERIC);

			if (pvo.state == 4) {
				doCheckFilter(pvo.grow_type); //未有选择的均添加灰色滤镜
				commitNowBtn.visible=true;
				BeginBtn.visible=false;
				LeftTimeImg.visible=true;
				timeLeftTxt.visible=true;
				needGoldTxt.visible=true;
				isGrowing.visible=true;
				needRoleLevelTxt.visible=false;
				needGrowLevelTxt.visible=false;
				needSilverTxt.visible=false;

				timeLeft=pvo.grow_over_tick;

				if (timeLeft > 0) {
					timer.start();
					timeLeftTxt.htmlText=" <font color='#FFFF00'>" + DateFormatUtil.formatTickToCNTimes(timeLeft) + "</font>";
					var needGold:int=Math.ceil(timeLeft / 300);
					needGoldTxt.text=needGold + "元宝";
					if (!isLeftGold()) {
						needGoldTxt.textColor=0xff0000;
					} else { //动态判断。
						needGoldTxt.textColor=0xffff00;
					}
					timeLeftTxt.visible=true; //元宝提示，绑定元宝，拥有元宝数。
				}

			} else {

				commitNowBtn.visible=false;
				BeginBtn.visible=true;
				LeftTimeImg.visible=false;
				timeLeftTxt.visible=false;
				needGoldTxt.visible=false;
				isGrowing.visible=false;
				needRoleLevelTxt.visible=true; //--等级角色判断，如果达不到红色提示。
				needGrowLevelTxt.visible=true; //--关联成长等级判断 ，如果达不到红色提示。
				needSilverTxt.visible=true; //--拥有银子与需要银子数，判断。红色提示。
				timer.stop();
				timeLeft=0;
				nextGrowFilter(pvo.grow_type); //为下次升级做初始化
				removeCheckFilter(); //恢复滤镜 把上次能学技能恢复回来。
			}

			for (var i:int=0; i < 5; i++) {
				var growInfo:p_grow_info=growConfigs[i] as p_grow_info;
				var item:PetGrowItem=growSkills[growInfo.type] as PetGrowItem; //索引。使用type排序
				item.growInfo=growInfo;
			}

			checkLearnCondiction();

			updatePart2();
		}


		private function onTimer(e:TimerEvent=null):void {
			timeLeft--;
			if (timeLeft >= 0) {
				var needGold:int=Math.ceil(timeLeft / 300);
				timeLeftTxt.htmlText="<font color='#FFFF00'>" + DateFormatUtil.formatTickToCNTimes(timeLeft) + "</font>";
				needGoldTxt.text=needGold + "元宝";
				if (!isLeftGold()) {
					needGoldTxt.textColor=0xff0000;
				} else { //动态判断。
					needGoldTxt.textColor=0xffff00;
				}
			} else {
				timeLeftTxt.visible=false;
				commitNowBtn.enabled=false;
				needGoldTxt.text="花费0元宝";
				timer.stop();

			}

		}

		private function toCommit(e:MouseEvent):void {
			var needGold:int=Math.ceil(timeLeft / 300);
			if (GlobalObjectManager.getInstance().user.attr.gold_bind + GlobalObjectManager.getInstance().user.attr.gold < needGold) {
				alertStr=Alert.show("您的元宝不足，无法立刻完成驯宠能力！<font color='#00FF00'><a href='event:openPay;'><u>快速充值</u></a></font>", "提示", null, null, "确定", "", null, false, false, null, openPay);
				return;
			}
			if (pvo != null) {
				toRealCommit();
			}
		}

		private function toRealCommit():void {
			PetModule.getInstance().mediator.toPetGrowCommit();
		}

		private function openPay(e:TextEvent):void {
			Alert.removeAlert(alertStr);
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);
		}

		public function GrowState():int {
			if (pvo != null) {
				return pvo.state;
			} else {
				return 1;
			}
		}

		public function toBegin(e:Event=null):void {
			if (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind < selectItem.pvo.need_silver) {
				Tips.getInstance().addTipsMsg("银子不足，可通过拉镖、商贸或按\"S\"在高级商店购买银票获得。");
				return;
			}
			var vo:m_pet_grow_begin_tos=new m_pet_grow_begin_tos();
			vo.grow_type=selectItem.growType;
			PetModule.getInstance().send(vo);

		}

		private function onSelectPetGrow(event:DataEvent=null):void {
			event.stopPropagation();
			selectItem.select=false;
			var item:PetGrowItem=growSkills[int(event.data)] as PetGrowItem;
			item.select=true;

			selectItem=item;
			updatePart2();
		}

		private function updatePart2():void {
			if (!selectItem.pvo)
				return;
			selectImg.source=selectItem.content.source;

			switch (selectItem.growType) {
				case SkillConstant.PET_GROW_SKILL_CON:
					selectLevelTxt.text="神功护体: " + selectItem.levelTxt.text + "级";
					skillDescTxt.text="可提升所有宠物出战时的生命上限";
					curLevelEffectTxt.text = "宠物生命+" + selectItem.pvo.cur_add_value;
					NextLevelEffectTxt.text="宠物生命+" + selectItem.pvo.add_value;
					needGrowLevelTxt.text="力敌千钧" + selectItem.levelTxt.text + "级 或 以柔克刚" + selectItem.levelTxt.text + "级";
					break;
				case SkillConstant.PET_GROW_SKILL_PHY_DEFENCE:
					selectLevelTxt.text="刀枪不入：" + selectItem.levelTxt.text + "级";
					skillDescTxt.text="可提升所有宠物出战时的外防";
					curLevelEffectTxt.text = "宠物外防+" + selectItem.pvo.cur_add_value;
					NextLevelEffectTxt.text="宠物外防+" + selectItem.pvo.add_value;
					needGrowLevelTxt.text="神功护体" + selectItem.pvo.level + "级";

					break;
				case SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE:
					selectLevelTxt.text="气运丹田: " + selectItem.levelTxt.text + "级";
					skillDescTxt.text="可提升所有宠物出战时的内防";
					curLevelEffectTxt.text = "宠物内防+" + selectItem.pvo.cur_add_value;
					NextLevelEffectTxt.text="宠物内防+" + selectItem.pvo.add_value;
					needGrowLevelTxt.text="神功护体" + selectItem.pvo.level + "级";

					break;
				case SkillConstant.PET_GROW_SKILL_PHY_ATTACK:
					selectLevelTxt.text="力敌千钧：" + selectItem.levelTxt.text + "级";
					skillDescTxt.text="可提升所有宠物出战时的外攻";
					curLevelEffectTxt.text = "宠物外攻+" + selectItem.pvo.cur_add_value;
					NextLevelEffectTxt.text="宠物外攻+" + selectItem.pvo.add_value;
					needGrowLevelTxt.text="刀枪不入" + selectItem.pvo.level + "级 或 气运丹田" + selectItem.pvo.level + "级";

					break;
				case SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK:
					selectLevelTxt.text="以柔克刚: " + selectItem.levelTxt.text + "级";
					skillDescTxt.text="可提升所有宠物出战时的内攻";
					curLevelEffectTxt.text = "宠物内攻+" + selectItem.pvo.cur_add_value;
					NextLevelEffectTxt.text="宠物内攻+" + selectItem.pvo.add_value;
					needGrowLevelTxt.text="刀枪不入" + selectItem.pvo.level + "级 或 气运丹田" + selectItem.pvo.level + "级";

					break;
			}


			if (!growLevelFlag[selectItem.growType]) {
				needGrowLevelTxt.textColor=0xff0000; //判断是否可以强化。红色警示。


			} else {
				needGrowLevelTxt.textColor=0xebe7ba;

			}



			if (pvo.state != 4) { //判断等级


				needRoleLevelTxt.text="角色等级：	" + selectItem.pvo.need_level + "级";
				if (!isNeedLevel()) {
					needRoleLevelTxt.textColor=0xff0000;
				} else {
					needRoleLevelTxt.textColor=0xebe7ba;
				}
				//判断银子

				needSilverTxt.text="银子： " + MoneyTransformUtil.silverToOtherString(selectItem.pvo.need_silver);
				if (!isLeftSilver()) {
					needSilverTxt.textColor=0xff0000;
				} else {
					needSilverTxt.textColor=0xebe7ba;
				}
			}
			/*if(selectItem.content.filters.length > 0){
			   BeginBtn.enabled = false;

			   }
			   else
			 BeginBtn.enabled = true;*/
			if (isLeftSilver() && isNeedLevel() && growLevelFlag[selectItem.growType]) {
				BeginBtn.enabled=true;
			} else {
				BeginBtn.enabled=false;
			}

		}

		private function nextGrowFilter(type:int):void {
			switch (type) {
				case 1:
				case 2:
					checkFilterArr[5]=1; //CON
					break;
				case 3:
				case 4:
					checkFilterArr[1]=1; //外攻
					checkFilterArr[2]=1; //内攻
					break;
				case 5:
					checkFilterArr[3]=1; //外防
					checkFilterArr[4]=1; //内防
					break;
			}
		}

		//新加方法，为处理当训练时候，其它图标灰色。
		private function doCheckFilter(type:int):void {
			for (var i:int=5; i >= 1; i--) {
				if (i != type) {
					var item:PetGrowItem=growSkills[i] as PetGrowItem;
					item.learnFlag=false;
				}
			}
		}

		private function removeCheckFilter():void {
			for (var i:int=5; i >= 1; i--) {
				var item:PetGrowItem=growSkills[i] as PetGrowItem;
				if (checkFilterArr[i] == 1) {
					item.learnFlag=true;
				}
			}
		}

		private function checkLearnCondiction():void {
			var tmpselectitem:PetGrowItem;
			for (var i:int=5; i >= 1; i--) {
				var item:PetGrowItem=growSkills[i] as PetGrowItem;
				var item2:PetGrowItem;
				var item3:PetGrowItem;
				switch (item.growType) {
					case SkillConstant.PET_GROW_SKILL_CON:
						item2=growSkills[SkillConstant.PET_GROW_SKILL_PHY_ATTACK] as PetGrowItem;
						item3=growSkills[SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK] as PetGrowItem;
						if (!(item2.pvo.level >= item.pvo.level || item3.pvo.level >= item.pvo.level)) {
							item.learnFlag=false;
							growLevelFlag[SkillConstant.PET_GROW_SKILL_CON]=false;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_CON]=0;
						} else {
							growLevelFlag[SkillConstant.PET_GROW_SKILL_CON]=true;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_CON]=1;
						}

						break;
					case SkillConstant.PET_GROW_SKILL_PHY_DEFENCE:
						item2=growSkills[SkillConstant.PET_GROW_SKILL_CON] as PetGrowItem;
						if (!(item2.pvo.level > item.pvo.level)) {
							item.learnFlag=false;
							growLevelFlag[SkillConstant.PET_GROW_SKILL_PHY_DEFENCE]=false;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_PHY_DEFENCE]=0;
						} else {
							growLevelFlag[SkillConstant.PET_GROW_SKILL_PHY_DEFENCE]=true;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_PHY_DEFENCE]=1;
						}
						break;
					case SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE:
						item2=growSkills[SkillConstant.PET_GROW_SKILL_CON] as PetGrowItem;
						if (!(item2.pvo.level > item.pvo.level)) {
							item.learnFlag=false;
							growLevelFlag[SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE]=false;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE]=0;
						} else {
							growLevelFlag[SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE]=true;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE]=1;
						}
						break;
					case SkillConstant.PET_GROW_SKILL_PHY_ATTACK:
						item2=growSkills[SkillConstant.PET_GROW_SKILL_PHY_DEFENCE] as PetGrowItem;
						item3=growSkills[SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE] as PetGrowItem;
						if (!(item2.pvo.level > item.pvo.level || item3.pvo.level > item.pvo.level)) {
							item.learnFlag=false;
							growLevelFlag[SkillConstant.PET_GROW_SKILL_PHY_ATTACK]=false;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_PHY_ATTACK]=0;
						} else {
							growLevelFlag[SkillConstant.PET_GROW_SKILL_PHY_ATTACK]=true;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_PHY_ATTACK]=1;
						}
						break;
					case SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK:
						item2=growSkills[SkillConstant.PET_GROW_SKILL_PHY_DEFENCE] as PetGrowItem;
						item3=growSkills[SkillConstant.PET_GROW_SKILL_MAGIC_DEFENCE] as PetGrowItem;
						if (!(item2.pvo.level > item.pvo.level || item3.pvo.level > item.pvo.level)) {
							item.learnFlag=false;
							growLevelFlag[SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK]=false;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK]=0;
						} else {
							growLevelFlag[SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK]=true;
							checkFilterArr[SkillConstant.PET_GROW_SKILL_MAGIC_ATTACK]=1;
						}
						break;
				}
				/*if (tmpselectitem == null && item.content.filters.length <= 0) {
				   tmpselectitem=item;
				 }*/
				if (tmpselectitem == null && item.learnFlag == true) {
					tmpselectitem=item;
				}
			}
			if (pvo.state != 4 && tmpselectitem != null) {
				selectItem.select=false;
				tmpselectitem.select=true;
				selectItem=tmpselectitem;
			}

		}

		// 优化添加方法
		private function isLeftSilver():Boolean {
			return GlobalObjectManager.getInstance().user.attr.silver_bind + GlobalObjectManager.getInstance().user.attr.silver >= selectItem.pvo.need_silver ? true : false;
		}

		private function isNeedLevel():Boolean {
			return GlobalObjectManager.getInstance().user.attr.level >= selectItem.pvo.need_level ? true : false;
		}

		private function isLeftGold():Boolean {
			var needGold:int=Math.ceil(timeLeft / 300);
			return GlobalObjectManager.getInstance().user.attr.gold_bind + GlobalObjectManager.getInstance().user.attr.gold >= needGold ? true : false;
		}
	}
}