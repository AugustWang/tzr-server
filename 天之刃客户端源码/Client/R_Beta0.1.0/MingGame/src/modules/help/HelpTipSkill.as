package modules.help {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.gs.TweenMax;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.navigation.NavigationModule;
	import modules.playerGuide.PlayerGuideModule;
	import modules.playerGuide.TipsView;
	import modules.skill.SkillDataManager;
	import modules.skillTree.SkillTreeModule;
	import modules.skillTree.views.items.SkillItem;

	/**
	 * 专门用于自动学习技能的
	 * @author Qingliangcn
	 *
	 */
	public class HelpTipSkill extends Sprite {
		private var titleText:TextField;
		private var contentText:TextField;
		private var closeButton:UIComponent;
		private var rewardBox:UIComponent;
		private var goodsImage:GoodsImage;
		private var awardBtn:Button;
		private var tips:TipsView;

		private var skillIDArray:Dictionary=new Dictionary;

		// 接下来应该自动学习的技能
		private var skillID:int;

		public function HelpTipSkill() {
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"itemgiftbg"));

			tips=new TipsView();

			// 各个技能书所对应的技能ID
			skillIDArray[10301001]={skill_id: 11101001, desc: "威力巨大的战士劈斩"};
			skillIDArray[10302001]={skill_id: 21101001, desc: "千里杀敌的射手箭法"};
			skillIDArray[10303001]={skill_id: 31101001, desc: "神鬼莫测的侠客掌法"};
			skillIDArray[10304001]={skill_id: 41101001, desc: "以毒制敌的医仙掌法"};

			skillIDArray[10301006]={skill_id: 11103001, desc: "提升外攻攻击"};
			skillIDArray[10302006]={skill_id: 21103001, desc: "提高外攻伤害"};
			skillIDArray[10303006]={skill_id: 31103001, desc: "提升内力伤害"};
			skillIDArray[10304006]={skill_id: 41103001, desc: "提升内力和外力攻击"};

			skillIDArray[10301004]={skill_id: 11201001, desc: "强大的战士群攻技能"};
			skillIDArray[10302004]={skill_id: 21201001, desc: "强大的射手群攻技能"};
			skillIDArray[10303004]={skill_id: 31201001, desc: "强大的侠客群攻技能"};
			skillIDArray[10304004]={skill_id: 41201001, desc: "强大的医仙群攻技能"};

			var tf:TextFormat=Style.textFormat;
			tf.leading=4;
			tf.align=TextFormatAlign.CENTER;
			titleText=ComponentUtil.createTextField("", 30, 10, tf, this.width - 60, 25, this);
			titleText.wordWrap=false;
			titleText.multiline=false;
			titleText.htmlText="";
			titleText.filters=[Style.BLACK_FILTER];


			rewardBox=new UIComponent();
			this.addChild(rewardBox);
			rewardBox.width=rewardBox.height=36;
			rewardBox.x=int(this.width >> 1) - 18;
			rewardBox.y=int(this.height >> 1) - 36;
			rewardBox.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
			rewardBox.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
			var box:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			rewardBox.addChild(box);
			box.mouseEnabled=true;
			goodsImage=new GoodsImage();
			box.addChild(goodsImage);
			goodsImage.x=2;
			goodsImage.y=2;


			contentText=ComponentUtil.createTextField("", 5, rewardBox.y + rewardBox.height + 5, tf, this.width - 10, NaN, this);
			contentText.wordWrap=true;
			contentText.multiline=true;
			contentText.htmlText="";
			contentText.filters=[Style.BLACK_FILTER];

			awardBtn=ComponentUtil.createButton("学习", 88, 105, 76, 25, this);
			awardBtn.addEventListener(MouseEvent.CLICK, autoLearn);
		}

		private static var instance:HelpTipSkill;

		public static function getInstance():HelpTipSkill {
			if (instance == null) {
				instance=new HelpTipSkill();
			}
			return instance;
		}

		/**
		 * 设置技能书数组，根据这个来确定应该自动学习什么技能
		 * @param arr
		 *
		 */
		public function show(arr:Array, isShowTip:Boolean=false):void {
			var cid:int=GlobalObjectManager.getInstance().user.attr.category;
			var skillItemID:int=arr[cid - 1];
			var skillObj:Object=skillIDArray[skillItemID];
			if (skillObj) {
				skillID=skillObj.skill_id;
			}

			var itemObj:BaseItemVO=ItemLocator.getInstance().getObject(skillItemID);
			PlayerGuideModule.getInstance().onHelpTipStart();
			showItem(itemObj, skillObj.desc, isShowTip);
		}

		/**
		 * 自动学习技能
		 */
		private function autoLearn(e:Event):void {
			var skillItem:SkillItem=new SkillItem()
			skillItem.skillVO=SkillDataManager.getSkill(skillID);

			var form:Point=goodsImage.localToGlobal(new Point(0, 0));
			var target:Point=NavigationModule.getInstance().navBar.downgoodsBox.getItem(0).localToGlobal(new Point(0, 0));
			skillItem.x=form.x;
			skillItem.y=form.y;
			WindowManager.getInstance().openDialog(skillItem,false);
			TweenMax.to(skillItem, 1, {x: target.x, y: target.y, onComplete: onComplete});
			WindowManager.getInstance().closeDialog(this);
			function onComplete():void {
				WindowManager.getInstance().closeDialog(skillItem);
				SkillTreeModule.getInstance().skillLearn(skillID);
			}
			PlayerGuideModule.getInstance().onHelpTipEnd();
		}

		private function onRollOverHandler(evt:MouseEvent):void {
			var cur_ui:UIComponent=evt.currentTarget as UIComponent;
			var baseItemVo:BaseItemVO=cur_ui.data as BaseItemVO;
			if (baseItemVo) {
				ItemToolTip.show(baseItemVo, this.x + rewardBox.x, this.y + rewardBox.y + rewardBox.height, true);
			}
		}

		private function onRollOutHandler(evt:MouseEvent):void {
			ItemToolTip.hide();
		}

		private function showItem(baseItemVo:BaseItemVO, txtTip:String, isShowTip:Boolean=false):void {
			rewardBox.data=baseItemVo;
			goodsImage.setImageContent(baseItemVo, baseItemVo.path);

			contentText.htmlText=txtTip;
			this.awardBtn.enabled=true;

			var color:String=ItemConstant.COLOR_VALUES[baseItemVo.color];
			titleText.htmlText=HtmlUtil.fontBr(HtmlUtil.bold(baseItemVo.name), color, 14);

			x=(GlobalObjectManager.GAME_WIDTH - this.width) / 2;
			y=(GlobalObjectManager.GAME_HEIGHT - this.height) / 2;

			if (isShowTip) {
				initTips();
				tips.show("点击学习", TipsView.LEFT);
				tips.x=awardBtn.x + awardBtn.width * 2;
				tips.y=awardBtn.y;
				addChild(tips);
			} else {
				if (tips && this.contains(tips)) {
					this.removeChild(tips);
					tips=null;
				}
			}

			WindowManager.getInstance().openDialog(this);
		}

		private function initTips():void {
			if (!tips) {
				tips=new TipsView();
			}
		}

		private function onCloseHandler(event:MouseEvent):void {
			if (parent) {
				parent.removeChild(this);
			}
		}

	}
}