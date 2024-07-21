package modules.mypackage.views
{
	import com.common.FilterCommon;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	import modules.shop.ShopModule;
	
	public class GoodsMenuBar extends UIComponent
	{
		private var command:Dictionary;
		private var goodsVO:BaseItemVO;
		private var functionText:TextField;
		private var packageItem:PackageItem;
		public function GoodsMenuBar()
		{
			super();
			initView();
		}
		
		private static var instance:GoodsMenuBar;
		public static function getInstance():GoodsMenuBar{
			if(instance == null){
				instance = new GoodsMenuBar();
			}
			return instance;
		}
		
		private function initView():void{
			Style.setBorder1Skin(this);
			width = 50;
			
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #00FF00} a:hover {text-decoration: underline; color: #FFFF00;}");
			
			var tf:TextFormat = Style.themeTextFormat;
			tf.align = "center";
			tf.leading = 4;
			functionText = ComponentUtil.createTextField("",0,5,tf,50,20,this);
			functionText.mouseEnabled = true;
			functionText.multiline = true;
			functionText.filters = FilterCommon.FONT_BLACK_FILTERS;
			functionText.styleSheet = css;
			functionText.addEventListener(TextEvent.LINK,linkHandler);
			
			command = new Dictionary();
			command["拆 分"] = "split";
			command["丢 弃"] = "threw";
			command["出 售"] = "sell";
			command["展 示"] = "show";
			command["使 用"] = "use";
			
		}
		
		public function show(item:PackageItem):void{
			if(item.data){
				this.packageItem = item;
				this.goodsVO =packageItem.data as BaseItemVO;
				var point:Point = packageItem.parent.localToGlobal(new Point(packageItem.x+packageItem.width,packageItem.y+packageItem.height));
				x = point.x;
				y = point.y;
				createFunctionText();
				LayerManager.stage.addChild(this);
				LayerManager.stage.addEventListener(MouseEvent.MOUSE_UP,closeMenuBarHandler);
			}
		}
		
		private function closeMenuBarHandler(event:MouseEvent):void{
			if(parent){
				parent.removeChild(this);
			}	
			packageItem = null;
			goodsVO = null;
		}
		
		private function linkHandler(event:TextEvent):void{
			switch(event.text){
				case "split":PackageModule.getInstance().splitItemPanel(packageItem);break;
				case "threw":PackageModule.getInstance().threwGoods(goodsVO);break;
				case "sell":ShopModule.getInstance().toSaleGoods(goodsVO.oid,goodsVO.typeId, goodsVO.position,goodsVO.num, goodsVO.name);;break;
				case "show":ChatModule.getInstance().showGoods(goodsVO.oid);;break;
				case "stove":Dispatch.dispatch(ModuleCommand.OPEN_STOVE_WINDOW,[-1,true]);break;
				case "compose":Dispatch.dispatch(ModuleCommand.OPEN_EQUIP_COMPOSE);break;
				case "use":PackageModule.getInstance().useGoods(goodsVO);;break;
				default:;
			}
		}
		
		public function createFunctionText():void{
			var html:String = "";
			if(goodsVO is StoneVO || goodsVO.kind == ItemConstant.KIND_TASK){
				html += createLinkItem("使 用",false);
			}else{
				html += createLinkItem("使 用");
			}
			html += createLinkItem("展 示");
			if(goodsVO is EquipVO){
				html += createLinkItem("拆 分",false);
			}else{
				html += createLinkItem("拆 分");
			}
			html += createLinkItem("丢 弃");
			if(goodsVO.kind == ItemConstant.KIND_TASK){
				html += createLinkItem("出 售",false);
			}else{
				html += createLinkItem("出 售");
			}
			
			functionText.htmlText = html;
			functionText.height = functionText.textHeight+4;
			height = functionText.height+10;
			validateNow();
		}
		
		private function createLinkItems(...names):String{
			var html:String = "";
			for each(var linkName:String in names){
				html += createLinkItem(linkName);
			}
			return html;
		}
		
		private function createLinkItem(name:String,enabled:Boolean = true):String{
			if(enabled == false){
				return HtmlUtil.font(name,"#cccccc")+"\n";
			}
			return HtmlUtil.link(name,command[name])+"\n";
		}
	}
}