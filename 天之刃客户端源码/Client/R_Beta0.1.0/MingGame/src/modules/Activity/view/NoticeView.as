package modules.Activity.view
{
	import com.components.LoadingSprite;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class NoticeView extends LoadingSprite
	{
		public static const NOTICE_XML_URL:String = "com/data/notice.xml";
		
		private var urlLoader:URLLoader;
		private var inited:Boolean = false;
		private var notices:Array;
		private var list:List;
		public function NoticeView()
		{
			initView();
			setLoadingSize(621,332);
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}
		
		private function addToStageHandler(event:Event):void{
			if(!inited){
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE,onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
				urlLoader.load(new URLRequest(GameConfig.ROOT_URL+NOTICE_XML_URL));
				addDataLoading();
			}
		}
		
		private function onIOError(event:IOErrorEvent):void{
			removeDataLoading();
		}
		
		private function onComplete(event:Event):void{
			inited = true;
			var noticeXML:XML = new XML(urlLoader.data);
			urlLoader.removeEventListener(Event.COMPLETE,onComplete);
			urlLoader = null;
			analyseXML(noticeXML);
			removeDataLoading();
		}
		
		private function analyseXML(xml:XML):void{
			var noticeList:XMLList = xml..notice;
			notices = [];
			for each(var item:XML in noticeList){
				var content:String = String(item.content);
				var path:String = GameConfig.ROOT_URL+String(item.path);
				notices.push({content:content,path:path});
			}
			list.dataProvider = notices;
			list.validateNow();
		}
		
		private function initView():void{
			list = new List();
			list.bgSkin = null;
			list.selected = false;
			list.itemHeight = 111;
			list.itemRenderer = NoticeItem;
			list.width = 622;
			list.height = 340;
			list.x = 10;
			list.y = 10;
			addChild(list);
		}
	}
}
import com.ming.ui.controls.Image;
import com.ming.ui.controls.core.UIComponent;
import com.utils.ComponentUtil;

import flash.text.TextField;

class NoticeItem extends UIComponent{
	
	private var border:UIComponent;
	private var image:Image;
	private var text:TextField;
	
	public function NoticeItem(){
		width = 600;
		height =109;
		Style.setBorderSkin(this);
		
		border = ComponentUtil.createUIComponent(11,7,180,94);
		Style.setBoldBorder(border);
		addChild(border);
		
		image = new Image();
		image.x = 3;
		image.y = 3;
		border.addChild(image);
		
		text = ComponentUtil.createTextField("",210,8,Style.themeTextFormat,380,87,this);
		text.wordWrap = true;
		text.multiline = true;
	}
	
	override public function set data(value:Object):void{
		super.data = value;
		if(data){
			image.source = value.path;
			text.htmlText = value.content;
		}
	}
	
}