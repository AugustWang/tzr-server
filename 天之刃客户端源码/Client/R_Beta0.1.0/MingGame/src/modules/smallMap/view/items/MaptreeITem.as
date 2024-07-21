package modules.smallMap.view.items {

	import com.common.FilterCommon;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneData.NPCVo;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.mission.MissionConstant;
	import modules.mission.MissionFollowTextField;
	import modules.mission.MissionModule;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;

	public class MaptreeITem extends UIComponent implements ICellRenderer {

		protected var nameText:TextField;
		private var icon:Bitmap;
		private var fly:Image;
		static private var clickTime:int = 0;
		public function MaptreeITem() {
			icon = Style.getBitmap(GameConfig.T1_VIEWUI,"icon_open");
			icon.x = 5;
			icon.y = 2;
			addChild(icon);
			
			nameText=ComponentUtil.createTextField("", 50, 0, null, 110, 22, this);
			nameText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			fly = new Image();
			fly.source = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"fly");
			fly.addEventListener(MouseEvent.CLICK, onImageClick);
			fly.useHandCursor = fly.buttonMode = true;
			fly.width = 17;
			fly.height = 18;
			fly.x = 5;
			fly.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			fly.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			fly.visible = false;
			addChild(fly);
		}

		override public function set data(value:Object):void {
			super.data=value;
			var treeNode:TreeNode=value as TreeNode;
			var data:Object=treeNode.data
			if (treeNode.nodeType == TreeNode.BRANCH_NODE) {
				if (treeNode.isOpen()) {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_close");
				} else {
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"icon_open");
				}
				nameText.x = 25;
			} else {
				icon.bitmapData = null;
				nameText.x=15;
			}

			if (treeNode.nodeType == TreeNode.BRANCH_NODE) {
				nameText.htmlText=HtmlUtil.font(treeNode.data,"#ffd69b");
				fly.visible = false;
			} else {
				if (treeNode.data is NPCVo) {
					if (treeNode.data.job != null && treeNode.data.job.length != 0 && treeNode.data.type == 1) {
						nameText.htmlText=HtmlUtil.font(treeNode.data.job,"#7cc523");
					} else {
						nameText.htmlText=HtmlUtil.font(treeNode.data.name,"#7cc523");
					}
				} else {
					nameText.htmlText=HtmlUtil.font(treeNode.data.name,"#7cc523");
				}
				fly.visible = true;
				fly.x = nameText.x + nameText.textWidth+6;
			}

		}

		protected function onRollOut( event:MouseEvent ):void {
			ToolTipManager.getInstance().hide();
		}
		
		protected function onRollOver( event:MouseEvent ):void {
			ToolTipManager.getInstance().show( "消耗一个【传送卷】立即传送，VIP可免费传送",50 );
		}
		
		private function onImageClick(event:MouseEvent):void {
			var image:Image = event.currentTarget as Image;
			if (SystemConfig.serverTime - clickTime <= 5) {
				BroadcastSelf.getInstance().appendMsg('请不要频繁操作');
				return;
			}
			clickTime = SystemConfig.serverTime;
			var npcVO:NPCVo = data.data as NPCVo;
			var linkArgs:String = "";
			if(npcVO){
				linkArgs = MissionConstant.FOLLOW_LINK_TYPE_NPC+",-1,"+npcVO.id;
			}else{
				linkArgs = MissionConstant.FOLLOW_LINK_TYPE_GOTO+",-1,"+SceneDataManager.mapID+","+data.data.tx+","+data.data.ty;
			}
			MissionModule.getInstance().transGoto(linkArgs);
			
		}
		
		private var _selected:Boolean;
		public function set selected(value:Boolean):void {
			_selected=value;
		}

		public function get selected():Boolean {
			return false;
		}
	}
}