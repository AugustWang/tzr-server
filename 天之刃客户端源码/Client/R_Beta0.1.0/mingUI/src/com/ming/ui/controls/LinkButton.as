package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class LinkButton extends UIComponent
	{
		private var linkText:TextField;
		private var _label:String;
		private var _tf:TextFormat;
		public var url:String;
		private var updatePos:Boolean = false;
		private var brower:String;
		public function LinkButton()
		{
			super();
			mouseChildren = false;
			brower = ExternalInterface.call("function getBrower(){return navigator.userAgent}") as String;
		}
		
		public function textFormat(tf:TextFormat):void{
			this._tf = tf;
			updatePos = true;
			invalidateDisplayList();
		}
		
		public function set label(value:String):void{
			_label = value;
			if(!linkText){
				createLinkText();
			}
			linkText.htmlText = "<a href='event:"+url+"'>"+_label+"</a>";
			updatePos = true;
			invalidateDisplayList();
		}
		
		public function get label():String{
			return this._label;
		}
		
		private function createLinkText():void{
			linkText = new TextField();
			linkText.autoSize = TextFieldAutoSize.LEFT;
			linkText.selectable = false;
			linkText.defaultTextFormat = new TextFormat("Tahoma");
			addEventListener(MouseEvent.CLICK,mouseClickHandler);
			addChild(linkText);			
		}
		
		private var rep:RegExp = /\|/g;
		private function mouseClickHandler(event:MouseEvent):void{
			if(url && url.length > 0){
				url = url.replace(rep,"&");
				var str:String = Capabilities.os;
				if(str.substr(0,3).toLowerCase() == "win"){
					if(str.indexOf("7")!=-1 && brower.indexOf("MSIE 8.0")!=-1){//如果是win7同时浏览器是IE8
						ExternalInterface.call('window.open("'+url+'","'+"_blank"+'")');
					}else{
						navigateToURL(new URLRequest(url),'_blank')
					}
				}else{
					navigateToURL(new URLRequest(url),'_blank')
				}
			}
		}
		
		private var _enabled:Boolean = true;
		private var enabledChanged:Boolean = false;
		public function set enabled(value:Boolean):void{
			if(value != _enabled){
				_enabled = value;
				enabledChanged = true;
				invalidateDisplayList();
			}	
		}
		public function get enabled():Boolean{
			return _enabled;
		}
		
		private function enabledChange() : void{
			if (_enabled){
				filters = [];
				linkText.setTextFormat(_tf);
			}else{
				linkText.setTextFormat(new TextFormat("Tahoma",12,0xdddddd));
				filters = [new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
			}
			mouseEnabled = mouseChildren = _enabled;
			if (bgSkin != null){
				bgSkin.enableMouse = enabled;
			}
		}
		
		override protected function updateDisplayList(newWidth:Number, newHeight:Number) : void{
			if(updatePos){
				updatePos = false;
				_tf = _tf ? _tf : new TextFormat("Tahoma",12,0xffffff);
				linkText.setTextFormat(_tf);
				if(width == 0){
					width = linkText.width + 10;
				}
				if(height == 0){
					height = linkText.height + 6;
				}
				linkText.x = (width - linkText.width)/2;
				linkText.y = (height - linkText.height)/2;
			}
			if(enabledChanged){
				enabledChanged = false;
				enabledChange();
			}
			super.updateDisplayList(width,height);
		}
	}
}