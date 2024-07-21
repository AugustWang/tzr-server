package modules.duplicate.views
{
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import modules.duplicate.DuplicateConstant;
	
	/**
	 * 师徒副本队员提示界面 
	 * @author Administrator
	 * 
	 */	
	public class DuplicateMemberView extends BasePanel{
		
		private var contentText:TextField;
		private var gotoButton:Button
		
		public function DuplicateMemberView(){
			super();
			initView();
		}
		private function initView():void{
			title = "队长提示";
			width = 314;
			height = 200;
			
//			panelSkin = Style.getInstance().panelSkinNoBg;
//			var npcBg:Sprite = Style.getViewBg("npc_bg");
//			npcBg.x = 1;
//			npcBg.width= this.width - 2;
//			npcBg.height=164;
//			addChild(npcBg);
			
			contentText = ComponentUtil.createTextField("",18,8,null,this.width - 2 -2,100,this);
			contentText.multiline =true;
			contentText.wordWrap = true;
			contentText.mouseEnabled = true;
			contentText.addEventListener(TextEvent.LINK,onLinkEvent);
			
			gotoButton = ComponentUtil.createButton("点击寻路",width - 60 >> 1 , 10 + contentText.y + contentText.height,60,25,this);
			gotoButton.addEventListener(MouseEvent.CLICK,onGotoHandler);
			showCloseButton = false;
		}
		
		private function onLinkEvent(event:TextEvent):void{
			if(event.text == "goto"){
				dispatchEvent(new ParamEvent(DuplicateConstant.MEMBER_EVENT,{type:DuplicateConstant.GO_TO,tx:_tx,ty:_ty},true));
				this.closeWindow();
			}
		}
		
		private function onGotoHandler(event:MouseEvent):void{
			dispatchEvent(new ParamEvent(DuplicateConstant.MEMBER_EVENT,{type:DuplicateConstant.GO_TO,tx:_tx,ty:_ty},true));
			this.closeWindow();
		}
		
		private var _tx:int;
		private var _ty:int;
		public function updateData(tx:int,ty:int):void{
			_tx = tx;
			_ty = ty;
			contentText.htmlText = "队长：\n\t\t敌人马上出现，请大家注意！跟随队长到坐标\n" +
				"<a href=\"event:goto\"><font color=\"#3BE450\"><u>[" + _tx.toString() + "," + _ty.toString() + "]</u></font></a>，召唤怪物并将之击败，取得最终胜利！\n\n" +
				"\t\t点击“确定”可以自动寻路前往。";
			
		}
	}
}