package modules.Activity.view
{
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.utils.StringUtil;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	import com.utils.GraphicsUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.Activity.activityManager.ActivityFollowManager;
	import modules.Activity.vo.ActivityFollowVO;
	import modules.ModuleCommand;
	import modules.mission.MissionFollowTextField;

	/**
	 * 活动追踪界面
	 * @author huyongbo
	 * 
	 */	
	public class ActivityFollowView extends Sprite
	{
		public static const ACTIVITY_FOLLOW_VIEW:String = "ActivityFollowView";
		public static const CYCLE_TIME:int = 20;
		
		private var count:int;
		private var dragRect:Rectangle;
		private var noticeList:Array;
		private var displaylist:Array;
		
		private var title:TextField;
		private var container:Sprite;
		private var activityTextFields:Array;
		public function ActivityFollowView()
		{
			super();
			initView();
		}
		
		private function initView():void{
			dragRect = new Rectangle();
			displaylist = new Array();
			activityTextFields = new Array();
			
			var dragBar:Sprite = new Sprite();
			dragBar.x = 60;
			GraphicsUtil.drawRect(dragBar.graphics,0,0,90,20,0.7);
			dragBar.addEventListener(MouseEvent.MOUSE_DOWN,startDragHandler);
			addChild(dragBar);
			
			var hitSprite:Sprite = new Sprite();
			hitSprite.x = 60;
			hitSprite.useHandCursor = hitSprite.buttonMode = true;
			GraphicsUtil.drawRect(hitSprite.graphics,0,0,20,20,0);
			hitSprite.addEventListener(MouseEvent.CLICK,resizeHandler);
			addChild(hitSprite);
			
			title = ComponentUtil.createTextField("(-) 活动追踪",0,0,null,100,20,dragBar);
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			title.textColor = 0xCCCCCC;
			
			container = new Sprite();
			container.y = 20;
			addChild(container);
			for(var i:int=0;i<4;i++){
				var textField:MissionFollowTextField = new MissionFollowTextField();
				textField.textFormat = Constant.TEXTFORMAT_DEFAULT;
				textField.width = 250;
				textField.linkHandler = linkHandler;
				activityTextFields.push(textField);
				container.addChild(textField);
			}
			
			LoopManager.addToSecond(ACTIVITY_FOLLOW_VIEW,tickHandler);
			Dispatch.register(ModuleCommand.ACT_FOLLOW_LIST_CHANGED,followListChanged);
		}
		
		private function resizeHandler(event:MouseEvent):void{
			container.visible = !container.visible;
			if(container.visible == false){
				title.text = "(+) 活动追踪";
				LoopManager.removeFromSceond(ACTIVITY_FOLLOW_VIEW);
			}else{
				title.text = "(-) 活动追踪";
				LoopManager.addToSecond(ACTIVITY_FOLLOW_VIEW,tickHandler);
			}
		}
		
		private function linkHandler(text:String):void{
			var results:Array = text.split("|");
			var commandType:String = StringUtil.trim(results[0]);
			var command:String = StringUtil.trim(results[1]);
			if(commandType == "goto"){
				command = command.replace("#",GlobalObjectManager.getInstance().user.base.faction_id);
				PathUtil.findNPC(command);
			}else if(commandType == "open"){
				Dispatch.dispatch(command);
			}
		}
		
		private function startDragHandler(event:MouseEvent):void{
			stage.addEventListener(MouseEvent.MOUSE_UP,stopDragHandler);
			dragRect.width = GlobalObjectManager.GAME_WIDTH - width;
			dragRect.height = GlobalObjectManager.GAME_HEIGHT - height;
			startDrag(false,dragRect);
		}
		
		private function stopDragHandler(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP,stopDragHandler);
			stopDrag();
		}
		
		private function followListChanged():void{
			noticeList = ActivityFollowManager.getInstance().getDisplayList();
			displaylist.length = 0;
			updateList();
		}
		
		private function updateList():void{
			if(noticeList){
				while(displaylist.length > 0){
					noticeList.push(displaylist.shift());
				}
				for each(var textField:MissionFollowTextField in activityTextFields){
					var vo:ActivityFollowVO = noticeList.shift();
					if(vo){
						displaylist.push(vo);
						textField.htmlText = vo.htmlText;
					}else{
						textField.htmlText = "";
					}
					
				}
				LayoutUtil.layoutVectical(container);
			}
		}
		
		private function tickHandler():void{
			count++;
			if(count == CYCLE_TIME){
				updateList();
				count = 0;
			}
		}
	}
}