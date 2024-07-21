package modules.roleStateG.views.states
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.ToolTip;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.scene.SceneModule;
	import modules.system.SystemConfig;
	
	import proto.common.p_role;
	import proto.line.m_role2_pkmodemodify_toc;
	
	public class RoleMyStateView extends Sprite
	{
		public static const EVENT_ROLE_HEAD_CLICK:String="EVENT_ROLE_HEAD_CLICK";
		public static const EVENT_ROLE_BLOOD_CLICK:String="EVENT_ROLE_BLOOD_CLICK";
		private var _headImage:Image;
		private var _nameTxt:TextField;
		private var _levelTxt:TextField;
		private var _hpBar:Sprite;
		private var _mpBar:Sprite;
		private var hpAmptxt:TextField;
		private var mptxt:TextField;
		public var _buffBox:RoleBuffView;
		private var _attackBox:AttackModeView; //攻击模式；
		private var _bloodTipHot:Sprite;
		
		private var website:Button;
		private var recharge:Button;
		private var hpCtrl:Sprite;
		private var mpCtrl:Sprite;
		private var hpCtrlIn:Boolean = false;
		private var mpCtrlIn:Boolean = false;
		private var hpDraging:Boolean = false;
		private var toolTip:ToolTip;
		public function RoleMyStateView()
		{
			createChildren();
			LoopManager.addToSecond(this, autoEatDrug);
		}
		
		private function createChildren():void
		{
			var format:TextFormat=new TextFormat(null, 12, 0xffff00,true,null, null, null, null, "center");
			var bgView:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"myRoleStateBg");
			_headImage=new Image;
			_headImage.buttonMode=true;
			_headImage.useHandCursor=true;
			_headImage.addEventListener(MouseEvent.MOUSE_DOWN, onClickHead);
			_headImage.x=15;
			_nameTxt=new TextField;
			_nameTxt=new TextField();
			_nameTxt.mouseEnabled=false;
			_nameTxt.selectable=false;
			_nameTxt.filters=Style.textBlackFilter;
			_nameTxt.defaultTextFormat=new TextFormat(null, null, 0xffffff, null, null, null, null, null);
			_nameTxt.x=135; 
			_nameTxt.y=-2;
			_nameTxt.width=100;
			_nameTxt.height=20;
			
			var levelBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"levelBg");
			levelBg.x = 67;
			levelBg.y = 15;
			_levelTxt=new TextField();
			_levelTxt.addEventListener(MouseEvent.MOUSE_OVER, showLevelTip);
			_levelTxt.addEventListener(MouseEvent.MOUSE_OUT, hideTip);
			_levelTxt.autoSize=TextFieldAutoSize.CENTER;
			_levelTxt.filters=Style.textBlackFilter;
			_levelTxt.defaultTextFormat=format;
			_levelTxt.width=20;
			_levelTxt.height=15;
			_levelTxt.selectable=false;
			_levelTxt.x=80;
			_levelTxt.y=21;
			_hpBar=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"roleHP");
			_hpBar.x=89;
			_hpBar.y=18;
			_mpBar=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"roleMP");
			_mpBar.scaleX=0
			_mpBar.x= 89;
			_mpBar.y= 31;
			
			var tf:TextFormat = new TextFormat(null,11, 0xffffff, null, null, null, null, null, "center");
			tf.leading = 0;
			hpAmptxt = ComponentUtil.createTextField("",110,14,tf,90,15,this);
			hpAmptxt.filters = [new GlowFilter(0x000000, 1, 2, 2, 3, 1, false, false)];
			
			mptxt = ComponentUtil.createTextField("",110,26,tf,90,15,this);
			mptxt.filters = [new GlowFilter(0x000000, 1, 2, 2, 3, 1, false, false)];
			
			_attackBox=new AttackModeView;
			_attackBox.x=61;
			_attackBox.y=52;
			_buffBox=new RoleBuffView(91, 48);
			
			website = new Button();
			website.bgSkin = Style.getButtonSkin("circle_1skin","circle_2skin","circle_3skin","",GameConfig.T1_UI);
			website.width = website.height = 25;
			website.x = 31;
			website.y = 63;
			website.label = "官";
			website.textBold = true;
			website.textColor = 0xFFD69B;
			website.topPadding = -1;
			website.leftPadding = 1;
			addChild(website);
			
			recharge = new Button();
			recharge.width = recharge.height = 25;
			recharge.bgSkin = Style.getButtonSkin("circle_1skin","circle_2skin","circle_3skin","",GameConfig.T1_UI);
			recharge.x = 5;
			recharge.y = 53;
			recharge.label = "充";
			recharge.textBold = true;
			recharge.textColor = 0xFFFF00;
			recharge.topPadding = -1;
			recharge.leftPadding = 1;
			addChild(recharge);
			
			_bloodTipHot=new Sprite;
			_bloodTipHot.graphics.beginFill(0, 0);
			_bloodTipHot.graphics.drawRect(0, 0, 126, 32);
			_bloodTipHot.graphics.endFill();
			_bloodTipHot.x=88;
			_bloodTipHot.y=15;
			_bloodTipHot.addEventListener(MouseEvent.ROLL_OVER, showRoleHpAMp);
			_bloodTipHot.addEventListener(MouseEvent.ROLL_OUT, hideRoleTip);
			_bloodTipHot.addEventListener(MouseEvent.CLICK, onClickBody);
			
			hpCtrl=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"bloodCtrl");
			mpCtrl=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"bloodCtrl");
			hpCtrl.buttonMode=true;
			mpCtrl.buttonMode=true;
			hpCtrl.x=96;
			hpCtrl.y=16;
			mpCtrl.x=96;
			mpCtrl.y=29;
			hpCtrl.addEventListener(MouseEvent.MOUSE_DOWN, onHPCtrlDown);
			mpCtrl.addEventListener(MouseEvent.MOUSE_DOWN, onMPCtrlDown);
			hpCtrl.addEventListener(MouseEvent.ROLL_OVER, showHpCtrlTip);
			mpCtrl.addEventListener(MouseEvent.ROLL_OVER, showMpCtrlTip);
			hpCtrl.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			mpCtrl.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			
			toolTip = new ToolTip();
			toolTip.bgSkin = Style.getInstance().tipSkin;
			toolTip.x = 120;
			toolTip.y = 57;
			
			addChild(_attackBox);			
			addChild(bgView);
			addChild(_headImage);
			addChild(_nameTxt);
			addChild(_hpBar);
			addChild(_mpBar);
			addChild(_bloodTipHot);	
			addChild(hpCtrl);
			addChild(mpCtrl);
			addChild(levelBg);
			addChild(_levelTxt);
			//			addChild(hpAmptxt);
			//			addChild(mptxt);
			addChild(_buffBox);
			update();
		}
		
		public function configChanged():void {
			hpCtrl.x=96 + SystemConfig.hp * 114;
			mpCtrl.x=96 + SystemConfig.mp * 114;
		}
		
		private function makePercent(ctrl:Sprite):int {
			return int((ctrl.x - 96) * 100 / 114);
		}
		
		private function onHPCtrlDown(e:MouseEvent):void {
			hpCtrl.startDrag(false, new Rectangle(96, 16, 114, 0));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onHPCtrlUp);
			addEventListener(Event.ENTER_FRAME,continueTip);
			hpDraging = true;
		}
		
		private function onHPCtrlUp(e:MouseEvent):void {
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onHPCtrlUp);
			hpCtrl.stopDrag();
			var hpPercent:int=makePercent(hpCtrl);
			Dispatch.dispatch(ModuleCommand.HP_AUTOUSE_CHANGE, hpPercent);
			removeEventListener(Event.ENTER_FRAME,continueTip);
			if(hpCtrlIn){
				showHpCtrlTip(null);
			}else if(toolTip.parent){
				toolTip.parent.removeChild(toolTip);
			}
			hpDraging = false;
		}
		
		private function onMPCtrlDown(e:MouseEvent):void {
			mpCtrl.startDrag(false, new Rectangle(96, 29, 114, 0));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onMPCtrlUp);
			addEventListener(Event.ENTER_FRAME,continueTip);
		}
		
		private function onMPCtrlUp(e:MouseEvent):void {
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onMPCtrlUp);
			mpCtrl.stopDrag();
			var mpPercent:int=makePercent(mpCtrl);
			Dispatch.dispatch(ModuleCommand.MP_AUTOUSE_CHANGE, mpPercent);
			removeEventListener(Event.ENTER_FRAME,continueTip);
			if(mpCtrlIn){
				showMpCtrlTip(null);
			}else if(toolTip.parent){
				toolTip.parent.removeChild(toolTip);
			}
		}
		
		private function continueTip(event:Event):void{
			var str:String = "";
			if(hpDraging){
				var hpPercent:int=makePercent(hpCtrl);
				str = HtmlUtil.font("您当前的设置为：\n生命值低于 " +  HtmlUtil.font(hpPercent+"%","#00ff00") + " 时自动使用生命药\n", "#FF9000") + HtmlUtil.font("可以拖动滑块来改变自动恢复设置", "#14F133");
			}else{
				var mpPercent:int=makePercent(mpCtrl);
				str =HtmlUtil.font("您当前的设置为：\n内力值低于 " +  HtmlUtil.font(mpPercent+"%","#00ff00") + " 时自动使用内力药\n", "#FF9000") + HtmlUtil.font("可以拖动滑块来改变自动恢复设置", "#14F133");
			}
			toolTip.data = str;
			LayerManager.uiLayer.addChild(toolTip);
		}
		
		private function showHpCtrlTip(e:MouseEvent):void {
			var hpPercent:int=SystemConfig.hp * 100;
			toolTip.data=HtmlUtil.font("您当前的设置为：\n生命值低于 " + HtmlUtil.font(hpPercent+"%","#00ff00") + " 时自动使用生命药\n", "#FF9000") + HtmlUtil.font("可以拖动滑块来改变自动恢复设置", "#14F133");
			LayerManager.uiLayer.addChild(toolTip);
			hpCtrlIn = true;
		}
		
		private function showMpCtrlTip(e:MouseEvent):void {
			var mpPercent:int=SystemConfig.mp * 100;
			toolTip.data=HtmlUtil.font("您当前的设置为：\n内力值低于 " + HtmlUtil.font(mpPercent+"%","#00ff00") + " 时自动使用内力药\n", "#FF9000") + HtmlUtil.font("可以拖动滑块来改变自动恢复设置", "#14F133");
			LayerManager.uiLayer.addChild(toolTip);
			mpCtrlIn = true;
		}
		
		private function onClickHp(e:MouseEvent):void {
			var pos:int=int(_hpBar.x + _hpBar.mouseX);
			if (pos > 155) {
				pos=155;
			}
			hpCtrl.x=pos;
			var hpPercent:int=makePercent(hpCtrl);
			Dispatch.dispatch(ModuleCommand.HP_AUTOUSE_CHANGE, hpPercent);
		}
		
		private function onClickMp(e:MouseEvent):void {
			var pos:int=int(_mpBar.x + _mpBar.mouseX);
			if (pos > 155) {
				pos=155;
			}
			mpCtrl.x=pos;
			var mpPercent:int=makePercent(mpCtrl);
			Dispatch.dispatch(ModuleCommand.MP_AUTOUSE_CHANGE, mpPercent);
		}
		
		public function update():void
		{
			var str:String = "";
			var  mpstr:String;
			var user:p_role=GlobalObjectManager.getInstance().user;
			_headImage.source=GameConstant.getHeadImage(user.base.head);
			_nameTxt.text=user.base.role_name;
			_levelTxt.text=user.attr.level + "";
			_hpBar.scaleX=user.fight.hp / user.base.max_hp;
			_mpBar.scaleX=user.fight.mp / user.base.max_mp;
			if (_hpBar.scaleX < 0)
			{
				_hpBar.scaleX=0;
			}
			if (_hpBar.scaleX > 1)
			{
				_hpBar.scaleX=1;
			}
			if (_mpBar.scaleX < 0)
			{
				_mpBar.scaleX=0;
			}
			if (_mpBar.scaleX > 1)
			{
				_mpBar.scaleX=1;
			}
			
			str = user.fight.hp + " / " + user.base.max_hp +"\n";
			if(user.fight.hp<=0)
			{
				str = "0 / "+ user.base.max_hp +"\n";
			}
			mpstr = user.fight.mp + " / " + user.base.max_mp ;
			if(user.fight.mp<=0)
			{
				mpstr="0 / " + user.base.max_mp ;
			}
			
			hpAmptxt.text = str ;
			mptxt.text = mpstr
			
			_buffBox.setDataSource(GlobalObjectManager.getInstance().user.base.buffs);
			_attackBox.reset();
		}
		
		public function updateBuff():void
		{
			
		}
		
		public function updateAttackMode(vo:m_role2_pkmodemodify_toc):void
		{
			_attackBox.update(vo);
		}
		
		public function updateMyTitles():void
		{
			
		}
		public function toChangeAttackMode(mode:int):void{
			_attackBox.toChangeMode(mode);
		}
		private function onClickHead(e:MouseEvent):void
		{
			this.dispatchEvent(new Event(EVENT_ROLE_HEAD_CLICK));
		}
		
		private function onClickBody(e:MouseEvent):void
		{
			this.dispatchEvent(new Event(EVENT_ROLE_BLOOD_CLICK));
		}
		
		private function showLevelTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show("角色等级：" + _levelTxt.text + "级");
		}
		
		private function hideTip(e:MouseEvent):void
		{
			if(e.currentTarget == mpCtrl){
				mpCtrlIn = false;
			}else if(e.currentTarget == hpCtrl){
				hpCtrlIn = false;
			}
			if(!hasEventListener(Event.ENTER_FRAME)){
				if(toolTip.parent){
					toolTip.parent.removeChild(toolTip);
				}
			}
		}
		
		private function hideRoleTip(evt:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private function showRoleHpAMp(evt:MouseEvent=null):void
		{
			var user:p_role=GlobalObjectManager.getInstance().user;
			var hp:String="<font color='#af0d10' size='12'>生命值：</font><font color='#ffffff' size='11'>" + user.fight.hp + " / " + user.base.max_hp + "</font>\n";
			var mp:String="<font color='#026da4' size='12'>内力值：</font><font color='#ffffff' size='11'>" + user.fight.mp + " / " + user.base.max_mp + "</font>";
			ToolTipManager.getInstance().show(hp + mp);
		}
		
		private function autoEatDrug():void {
			if (SceneModule.isAutoHit == false && SystemConfig.open == false) { //避免跟自动打怪时的吃药重复
				if (SystemConfig.autoUseHP == true || SystemConfig.autoUseMP == true) {
					if (GlobalObjectManager.getInstance().isDead == false) {
						Dispatch.dispatch(ModuleCommand.MP_HP_CHANGED); //用于背包的自动喝血和蓝功能
					}
				}
			}
		}
	}
}