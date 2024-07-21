package modules.mission.views
{
	import com.common.GlobalObjectManager;
	import com.common.effect.Tween;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class MissionPursueBar extends Sprite
	{
		private var bigButton:UIComponent;
		private var text:TextField;
		public var missionFollowPannel:MissionFollowView;
		public function MissionPursueBar()
		{
			super();
			with(graphics){
				clear();
				beginFill(0x1860aa,0.8);
				drawRoundRect(0,0,18,80,6,6);
				endFill();
			}
			bigButton = new UIComponent();
			bigButton.y = bigButton.x = 2;
			bigButton.bgSkin = Style.getButtonSkin("leftHide_1skin","leftHide_2skin","leftHide_3skin","",GameConfig.T1_UI);
			addChild(bigButton);
			
			text = ComponentUtil.createTextField("任\n务\n追\n踪",2,16,null,16,65,this);
			text.wordWrap = true;
			text.multiline = true;
			addEventListener(MouseEvent.CLICK,onMouseClick);
			useHandCursor = buttonMode = true;
		}
		
		private function onMouseClick(event:MouseEvent):void{
			this.showFollowView();
		}
		
		/**
		 * 显示任务追踪面板
		 */
		public function showFollowView():void{
			Tween.to(missionFollowPannel,8,{x:(GlobalObjectManager.GAME_WIDTH - 210)});
			visible = false;
		}
	}
}