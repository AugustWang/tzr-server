package modules.mypackage.views
{
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	
	public class GoodsSellPanel extends BasePanel
	{
		private var tile:SellTile;
		
		//获得的不绑定银子的显示文本
		private var silverGetText:TextField;
		//获得的绑定银子的显示文本
		private var silverBindGetText:TextField;
		
		public function GoodsSellPanel()
		{
			super("");
			initView();
		}
		
		private function initView():void
		{
			this.title = "出售物品";
			width = 282;
			height = 380;
			
			addContentBG(28);
			
			tile = new SellTile();
			tile.x = 6;
			tile.y = 2;
			tile.owner = this;
			addChild(tile);	
			
			var tf:TextFormat = Style.themeTextFormat;
			
			var descText:TextField = ComponentUtil.createTextField("出售物品收入：", 12,239,tf,200,21,this);
			this.addChild(descText);
			var silverText:TextField = ComponentUtil.createTextField("银子：", 12,264,tf,62,21,this);
			var silverBindText:TextField = ComponentUtil.createTextField("绑定银子：", 12,289,tf,62,21,this);
			this.addChild(silverText);
			this.addChild(silverBindText);
			
			silverGetText = ComponentUtil.createTextField("", 48,264,null,62,21,this);
			silverBindGetText = ComponentUtil.createTextField("", 68,289,null,62,21,this);
			
			var sellBtn:Button = ComponentUtil.createButton("确认出售", 130, 310, 60, 25);
			var cancelBtn:Button = ComponentUtil.createButton("取消", 205, 310, 60, 25);	
			sellBtn.addEventListener(MouseEvent.CLICK, onSell);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
			this.addChild(sellBtn);
			this.addChild(cancelBtn);
			
			this.addEventListener(WindowEvent.CLOSEED, onClose);
		}
		
		public function push(baseVo:BaseItemVO):void
		{
			var sellItem:SellItem = this.tile.getEmplyItem();
			if (sellItem != null) {
				sellItem.insert(baseVo);
			}
		}
		
		private function onSell(e:MouseEvent):void
		{
			PackageModule.getInstance().sellAllInSell();
		}
		
		public function onClose(e:Event=null):void
		{
			PackageModule.getInstance().cancelSell();
			tile.removeAll();
		}
		public function clear():void
		{
			PackageModule.getInstance().cancelSell();
			tile.removeAll();
		}
		
		public function onCancel(e:Event):void
		{
			PackageModule.getInstance().cancelSell();
			tile.removeAll();
			this.closeWindow(false);
		}
		
		public function update(silverStr:String, silverBindStr:String):void
		{
			silverGetText.htmlText = silverStr;
			silverBindGetText.htmlText = silverBindStr;
		}
	}
}