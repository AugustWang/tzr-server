package modules.family.views
{
	import com.common.FilterCommon;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	import modules.broadcast.KeyWord;
	import modules.family.FamilyConstants;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	
	public class Placard extends UIComponent
	{
		private var titleTF:TextField;
		private var contentText:VScrollText;
		private var updateButton:Button;
		private var titleBg:Bitmap;
		public var isprivate:Boolean;
		private var title:String;
		private var content:String;
		private var defaultContent:String = "最多可编辑200字，点击“保存”链接可保存。";
		private var leftText:TextField;
		private var factionId:int;
		public function Placard(title:String)
		{
			super();
			this.title = title;
			titleBg = Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			titleBg.width = 459;
			titleBg.x = 1;
			addChild(titleBg);
			titleTF = ComponentUtil.createTextField("",0,0,null,100,25,this);
			titleTF.filters = FilterCommon.FONT_BLACK_FILTERS;
			titleTF.selectable = false;
			titleTF.mouseEnabled = true;
			titleTF.addEventListener(TextEvent.LINK,onTextLink);
			
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {text-decoration: underline;color: #ffff00;} a:hover {color: #00ff00;}");
			titleTF.styleSheet = css;
			
			contentText = new VScrollText();
			contentText.selecteable = true;
			contentText.textField.textColor = 0xF6F5CD;
			contentText.direction = ScrollDirection.RIGHT;
			contentText.verticalScrollPolicy = ScrollPolicy.AUTO;
			addChild(contentText);
			updateFaction();
		}
		
		public function setPlacard(content:String):void{
			this.content = content;
			if(content && content != ""){
				contentText.text = content;
			}else if(factionId != FamilyConstants.ZY){
				contentText.text = defaultContent;
			}
		}
		
		public function updateFaction():void{
			factionId = FamilyLocator.getInstance().getRoleID();
			if(factionId != FamilyConstants.ZY){
				setUpdateText();
			}else{
				titleTF.htmlText =HtmlUtil.font(title,"#ffff00");
			}
		}
		
		private function setUpdateText():void{
			titleTF.htmlText =HtmlUtil.font(title,"#ffff00") + "      <a href='event:update'>"+HtmlUtil.font("修改","#00ff00")+"</a>";
		}
		
		private function setSaveText():void{
			titleTF.htmlText =HtmlUtil.font(title,"#ffff00") + "      <a href='event:save'>"+HtmlUtil.font("保存","#00ff00")+"</a>";
		}
		
		private var textArea:TextArea;
		private function onTextLink(event:TextEvent):void{
			if(event.text == "update"){
				var factionId:int = FamilyLocator.getInstance().getRoleID();
				if(factionId != FamilyConstants.ZY){
					var t:TextField = event.target as TextField;
					var ts:VScrollText = event.target as VScrollText;
					if((t && contains(t)) || (ts && contains(ts))){
						if(textArea == null){
							textArea = new TextArea();
							textArea.textField.maxChars = 200;
							textArea.width = width-6;
							textArea.height = height-titleBg.height-5;
							textArea.addEventListener(Event.CHANGE,onTextChanged);
						}
						textArea.x = 3;
						textArea.y = titleBg.height;
						contentText.visible = false;
						addChild(textArea);
						textArea.setFocus();
						if(content && content != ""){
							textArea.text = contentText.text;
						}
						setSaveText();
						createLeftText();
					}
				}
			}else if(event.text == "save"){
				var text:String = StringUtil.trim(textArea.text);
				var value:String = contentText.text;
				if(text != value){
					if(KeyWord.instance().hasUnRegisterString(text)){
						var str:String = KeyWord.instance().takeUnRegisterString(text);	
						Alert.show(str,"警告",yesHandler,null,"确定","",null,false);
						return;
					}
					factionId = FamilyLocator.getInstance().getRoleID();
					if(factionId != FamilyConstants.ZY){
						FamilyModule.getInstance().savePlacard(text,isprivate);
					}
				}
				setUpdateText();
				removeText();
				function yesHandler():void{
					textArea.setFocus();
				}
			}
		}
		
		private function createLeftText():void{
			if(leftText == null){
				leftText = ComponentUtil.createTextField("",350,titleBg.y+1,null,100,25,this);
			}else{
				addChild(leftText);
			}
			leftText.text = "还剩200字";
		}
		
		private function onTextChanged(event:Event):void{
			leftText.text = "还剩"+(200-textArea.text.length)+"字";
		}
		
		private function removeText():void{
			if(textArea && textArea.parent){
				textArea.parent.removeChild(textArea);
				textArea.text = "";
				if(leftText.parent){
					leftText.parent.removeChild(leftText);
				}
				contentText.visible = true;
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			titleBg.width = width - 2;
			titleTF.width = titleTF.textWidth + 10;
			titleTF.x = (width - titleTF.width)/2;
			titleTF.y = 1;
			contentText.width = width - 6;
			contentText.height = height - titleBg.height;
			contentText.y = titleBg.height;
			contentText.x = 3;
		}
	}
}