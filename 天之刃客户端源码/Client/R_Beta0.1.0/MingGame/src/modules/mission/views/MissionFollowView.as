package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.common.effect.Tween;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.mission.MissionConstant;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionFollowTextField;
	import modules.mission.MissionModule;
	import modules.mission.vo.MissionVO;
	
	import mx.modules.ModuleManager;

	/**
	 * 任务追踪面板
	 * @author Administrator
	 *
	 */
	public class MissionFollowView extends Sprite {
		public var missionPursueBar:MissionPursueBar;
		private var container:Sprite;

		private var currentMissionText:MissionFollowTextField;
		private var currentMissionCanvas:Canvas;
		private var canAcceptMissionText:MissionFollowTextField;
		private var canAcceptMissionCanvas:Canvas;
		//活动任务面板
		private var canLinkMissionCanvas:CanLinkMissionCanvas;

		private var tabNav:TabNavigation;
		private var dragRect:Rectangle;

		public function MissionFollowView() {
			super();
			mouseEnabled=false;

			var topBar:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"taskBarBg");
			addChild(topBar)
			
			var dragBar:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"taskIcon");
			topBar.addChild(dragBar)

			var smallSkin:ButtonSkin=Style.getButtonSkin("hideTask_1skin", "hideTask_2skin", "hideTask_3skin", null, GameConfig.T1_UI);
			
//			var blackBg:Shape=new Shape();
//			blackBg.graphics.beginFill(0, .4);
//			blackBg.graphics.drawRect(0, 19, 250, 130);
//			addChild(blackBg);
			
			canLinkMissionCanvas = new CanLinkMissionCanvas();
			
			currentMissionCanvas=new Canvas();
			currentMissionCanvas.scrollBarSkin = Style.alphaScrollBarSkin; 
			canAcceptMissionCanvas=new Canvas();
			canAcceptMissionCanvas.scrollBarSkin = Style.alphaScrollBarSkin; 
			currentMissionCanvas.mouseEnabled = canAcceptMissionCanvas.mouseEnabled = false;
			currentMissionCanvas.width=canAcceptMissionCanvas.width=canLinkMissionCanvas.width=200;
			currentMissionCanvas.height=canAcceptMissionCanvas.height=canLinkMissionCanvas.height=130;
			currentMissionCanvas.verticalScrollPolicy=ScrollPolicy.ON;
			canAcceptMissionCanvas.verticalScrollPolicy=ScrollPolicy.ON;
			canLinkMissionCanvas.verticalScrollPolicy = ScrollPolicy.ON;

			var css:StyleSheet=new StyleSheet();
			css.parseCSS("a:hover {text-decoration: underline; color: #FFB43C;}");

			var tf:TextFormat=new TextFormat();
			tf.leading=2;
			currentMissionText=new MissionFollowTextField();
			currentMissionText.y=2;
			currentMissionText.textFormat=tf;
			currentMissionText.resizeHandler = resizeCurrentMissionCanvas;
			currentMissionText.linkHandler = MissionModule.getInstance().onMissionLink;
			
			canAcceptMissionText=new MissionFollowTextField();
			canAcceptMissionText.y=2;
			canAcceptMissionText.textFormat=tf;
			canAcceptMissionText.resizeHandler = resizeCanAcceptMissionCanvas;
			canAcceptMissionText.linkHandler = MissionModule.getInstance().onMissionLink;

			currentMissionText.styleSheet=canAcceptMissionText.styleSheet=css;
			currentMissionText.width=canAcceptMissionText.width=180;
			currentMissionCanvas.addChild(currentMissionText);
			canAcceptMissionCanvas.addChild(canAcceptMissionText);
			
			tabNav=new TabNavigation();
			tabNav.mouseEnabled = false;
			tabNav.tabContainer.isTween = false;
			tabNav.y=0;
			tabNav.x=10;
			tabNav.height=158;
			tabNav.width=200;
			tabNav.tabBarPaddingLeft=10;
			tabNav.tabContainerSkin=null;
			tabNav.tabBarSkin = Style.getTaskFollowTabBarSkin();
			tabNav.addItem("当前任务", currentMissionCanvas, 60, 21);
			tabNav.addItem("可接任务", canAcceptMissionCanvas, 60, 21);
			tabNav.addItem("委托", canLinkMissionCanvas, 40, 21);
			addChild(tabNav);
			tabNav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, selectTabChangeHandler);			
			var hideFollowViewBTN:UIComponent=new UIComponent();
			hideFollowViewBTN.useHandCursor=hideFollowViewBTN.buttonMode=true;
			hideFollowViewBTN.x=190;
			hideFollowViewBTN.y = 6;
			hideFollowViewBTN.bgSkin=smallSkin;
			hideFollowViewBTN.setToolTip('最小化');
			hideFollowViewBTN.addEventListener(MouseEvent.CLICK, onHideFollowView);
			addChild(hideFollowViewBTN);
			
			Dispatch.register(ModuleCommand.MISSION_LIST_UPDATE, this.missionListUpdate);

		}
		
		private function resizeCurrentMissionCanvas():void{
			this.currentMissionCanvas.updateSize();
			currentMissionCanvas.validateNow();
			
		}
		
		private function resizeCanAcceptMissionCanvas():void{
			this.canAcceptMissionCanvas.updateSize();
			canAcceptMissionCanvas.validateNow();
		}
		
		private var _selectIndex:int = 0;
		private function selectTabChangeHandler(event:TabNavigationEvent):void{
			if(event.index == 2){
				setTabNavIndex(_selectIndex);
				Dispatch.dispatch(ModuleCommand.OPEN_MISSION_PANNEL,2);
				tabNav.validateNow();
				return;
			}
			_selectIndex = event.index;
		}
		
		private function missionListUpdate():void {

			var currentMissionList:Object=MissionDataManager.getInstance().currentMissionList;
			var currentMissionSortedIDList:Array = MissionDataManager.getInstance().currentMissionSortedIDList;
			
			var canAcceptMissionList:Object=MissionDataManager.getInstance().canAcceptMissionList;
			var canAcceptMissionSortedIDList:Array = MissionDataManager.getInstance().canAcceptMissionSortedIDList;
				
			var currentMissionStr:Array=[];
			
			var startTime:int = getTimer();
			
			var currentMissionExists:Boolean = false;
			var lastMissionVO:MissionVO = null;
			for each (var currentMissionID:int in currentMissionSortedIDList) {
				var missionCurrent:MissionVO = currentMissionList[currentMissionID];
				currentMissionExists = true;
				currentMissionStr.push(missionCurrent.followTitle + missionCurrent.target);
				lastMissionVO = missionCurrent;
			}
			
			var followStr:String = '';
			
			followStr = currentMissionStr.join('\n').replace(MissionConstant.TARGET_S_REG_EXP, '       ');
			currentMissionText.htmlText='<font color="#ffffff">' + followStr + '</font>';
			
			var canAcceptMissionStr:Array=[];
			var canAcceptMissionExists:Boolean = false;
			for each (var canAcceptMissionID:int  in canAcceptMissionSortedIDList) {
				var missionCan:MissionVO = canAcceptMissionList[canAcceptMissionID];
				canAcceptMissionExists = true;
				canAcceptMissionStr.push(missionCan.followTitle + missionCan.target);
			}
			
			followStr = canAcceptMissionStr.join('\n').replace(MissionConstant.TARGET_S_REG_EXP, '       ');
			canAcceptMissionText.htmlText='<font color="#ffffff">' + followStr + '</font>';
			
			if(currentMissionExists == true){
				if( currentMissionSortedIDList.length==1
					&& lastMissionVO!=null && canAcceptMissionExists){
					//判断是否为赠送紫色项链任务
					if( lastMissionVO.id == 2016 || 
						lastMissionVO.id == 3001 ||
						lastMissionVO.id == 3002  ){
						setTabNavIndex(1);
					}else{
						setTabNavIndex(0);	
					}
				}else{
					setTabNavIndex(0);	
				}
			}else if(canAcceptMissionExists == true){
				setTabNavIndex(1);
			}else{
				canAcceptMissionText.htmlText = '<font color="#ffffff">&lt;暂无任务&gt;</font>';
				currentMissionText.htmlText = '<font color="#ffffff">&lt;暂无任务&gt;</font>';
			}
		}

		private function setTabNavIndex( idx:int ):void {
			if ( tabNav.selectedIndex != idx ) {
				tabNav.selectedIndex=idx;
			}
		}
		
		private function onDragBarOver(event:MouseEvent):void {
			ToolTipManager.getInstance().show("拖动面板", 500);
		}

		private function onDragBarOut(e:MouseEvent):void {
			ToolTipManager.getInstance().hide()
		}

		private function onDragStart(event:MouseEvent):void {
			if (dragRect == null) {
				dragRect=new Rectangle(0, 0, LayerManager.stage.stageWidth - 30, LayerManager.stage.stageHeight - 30)
			}
			this.startDrag(false, dragRect);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function onMouseUp(event:MouseEvent):void {

			this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		public function set selectedIndex(index:int):void {
			tabNav.selectedIndex=index;
		}

		public function onHideFollowView(event:MouseEvent):void {
			this.hideFollowView();
		}

		/**
		 * 隐藏任务追踪面板
		 */
		public function hideFollowView():void{
			if (missionPursueBar == null) {
				missionPursueBar=new MissionPursueBar();
				missionPursueBar.x=GlobalObjectManager.GAME_WIDTH - 18; // 984;
				missionPursueBar.y=y;
				missionPursueBar.missionFollowPannel=this;
				missionPursueBar.visible=false;
			}
			Tween.to(this, 8, {x: GlobalObjectManager.GAME_WIDTH, y: 190, onComplete: onHideFollowViewComplete});
			LayerManager.uiLayer.addChild(missionPursueBar);
		}
		
		/**
		 * 显示追踪面板
		 */
		public function showFollowView():void{
			if (missionPursueBar != null) {
				missionPursueBar.showFollowView();
			}
		}
		
		/**
		 * 隐藏追踪面板
		 */
		private function onHideFollowViewComplete():void {
			missionPursueBar.x=GlobalObjectManager.GAME_WIDTH - 18;
			missionPursueBar.visible=true;
		}
		
		

	}
}