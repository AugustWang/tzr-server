package modules.sceneWarFb {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.tile.Pt;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCDataManager;
	import modules.scene.SceneDataManager;
	/**
	 * 领取道具奖励提示界面
	 * @author caochuncheng
	 * 
	 */    
	public class CallMonsterTip extends Sprite {
		
		private var titleText:TextField;
		private var contentText:TextField;
		private var closeButton:UIComponent;
		private var rewardBox:UIComponent;
		private var goodsImage:GoodsImage;
		private var awardBtn:Button;
		
		public function CallMonsterTip() {
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"itemgiftbg"));
			
			var tf:TextFormat = Style.textFormat;
			tf.leading=4;
			tf.align = TextFormatAlign.CENTER;
			titleText = ComponentUtil.createTextField("",30,20,tf,this.width - 60,25,this);
			titleText.wordWrap = false;
			titleText.multiline = false;
			titleText.htmlText = "寻路到npc召唤怪物";
			titleText.filters=[Style.BLACK_FILTER];
			
			closeButton = new UIComponent();
			closeButton.buttonMode=true;
			closeButton.addEventListener(MouseEvent.CLICK,onCloseHandler);
			closeButton.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
			closeButton.x = this.width - closeButton.width - 30;
			closeButton.y = 12;
			addChild(closeButton);
			
			awardBtn = ComponentUtil.createButton("确定", 88, 105, 76, 25,this);
			awardBtn.addEventListener(MouseEvent.CLICK, onClickGotoCallMonsterNpc);
		}

		private var _npcId:String;
		public function set npcId(value:String):void{
			this._npcId=value;
		}
		
		private function onCloseHandler(event:MouseEvent):void{			
			LayerManager.uiLayer.removeChild(this);
		}
		private function onClickGotoCallMonsterNpc(event:MouseEvent):void{
			PathUtil.findNpcAndOpenIgnoreScene(_npcId);
			LayerManager.uiLayer.removeChild(this);
		}
	}
}