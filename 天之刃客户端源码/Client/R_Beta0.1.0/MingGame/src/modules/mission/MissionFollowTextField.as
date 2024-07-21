package modules.mission {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.utils.PathUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextExtent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextSnapshot;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.system.SystemConfig;
	import modules.trading.TradingModule;

	public class MissionFollowTextField extends Sprite {
		private var _inited:Boolean = false;
		public var textField:TextField;
		private var _images:Array;
		private var _linkArray:Array;
		public var linkHandler:Function;
		public var resizeHandler:Function;
		private const _openImageText:Boolean = true;

		static private var _clickTime:int = 0;

		public function MissionFollowTextField() {
			super();
			mouseEnabled = false;
			_images = [];
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}

		private function addedToStageHandler(event:Event):void{
			if(htmlUpdate){
				htmlText = _htmlText;
			}
		}
		
		private var htmlUpdate:Boolean = false;
		private var _htmlText:String;
		public function set htmlText(value:String):void {
			_htmlText = value;
			if(stage){
				htmlUpdate = false;
				dispose();
				createTextField();
				textField.htmlText = _htmlText;
				height = textField.height = textField.textHeight+4;
				parseHtmlText();
				if (_update) {
					textField.styleSheet = _styleSheet;
				}
				if(resizeHandler != null){
					resizeHandler();
				}
			}else{
				htmlUpdate = true;
			}
		}

		private var _width:Number = 190;

		override public function set width(value:Number):void {
			_width = value;
		}

		override public function get width():Number {
			return this._width;
		}

		private var _height:Number;

		override public function set height(value:Number):void {
			_height = value;
		}

		override public function get height():Number {
			return _height;
		}

		private var _update:Boolean = false;
		private var _styleSheet:StyleSheet;

		public function set styleSheet(value:StyleSheet):void {
			_styleSheet = value;
			_update = true;
		}

		public function get styleSheet():StyleSheet {
			return _styleSheet;
		}

		private var _textFormat:TextFormat = Style.themeTextFormat;

		public function set textFormat(value:TextFormat):void {
			_textFormat = value;
		}

		public function get textFormat():TextFormat {
			return _textFormat;
		}

		private function createTextField():void {
			if (_update || !_inited) {
				if (textField) {
					if (linkHandler != null) {
						textField.removeEventListener(TextEvent.LINK, linkHandler);
					}
					textField.parent.removeChild(textField);
				}
				textField = new TextField();
				textField.filters = [new GlowFilter(0, 1, 2, 2, 3)];
				textField.defaultTextFormat = _textFormat;
				textField.mouseWheelEnabled = false;
				textField.selectable = false;
				textField.width = _width;
				textField.multiline = true;
				textField.wordWrap = true;
				textField.autoSize = TextFieldAutoSize.NONE;
				textField.condenseWhite = false;
				textField.addEventListener(TextEvent.LINK, onTextClick);
				addChild(textField);
				_inited = true;
				_update =  false;
			}
		}

		private function parseHtmlText():void {
			if (GlobalObjectManager.getInstance().user.attr.level < 16 || this._openImageText == false) {
				var oldHtmlStr:String = textField.htmlText;
				textField.htmlText = oldHtmlStr.replace(MissionConstant.TRANS_GO_REG_EXP, '');
				return;
			}
			var splitResults:Array = textField.text.split(MissionConstant.TRANS_GO_REG_EXP);
			if (!splitResults || splitResults.length == 0) {
				return;
			}

			var xml:XML = new XML("<root>" + _htmlText + "</root>");

			var _linkXMLList:XMLList = xml..a;

			this._linkArray = new Array();
			for (var _linkIndex:int = 0; _linkIndex < _linkXMLList.length(); _linkIndex += 2) {

				var _currentLink:String = _linkXMLList[_linkIndex].@href.toString();
				this._linkArray.push(_linkXMLList[_linkIndex].@href.toString());
				if (_linkXMLList[_linkIndex + 1] && _linkXMLList[_linkIndex + 1].@href != _currentLink) {
					_linkIndex -= 1;
				}
			}

			var lastIndex:int = 0;
			var index:int = 0;
			var transGoToStrLen:int = MissionConstant.TRANS_GO_STR.length;
			
			for (var i:int = 0; i < splitResults.length; i++) {
				if (MissionConstant.TRANS_GO_REG_EXP.test(splitResults[i])) {
					textField.replaceText(lastIndex, lastIndex + transGoToStrLen, String.fromCharCode(12288)+String.fromCharCode(12288));
					//textField.setTextFormat(LETTERSPACE_TF,lastIndex,lastIndex+1);
					addImg(textField.getCharBoundaries(lastIndex), index);
					lastIndex += 2;
					index++;
				} else {
					lastIndex += String(splitResults[i]).length;
				}
			}
		}

		private function getGotoFaction( args:Array ):int {
			var mapID:int = 0;
			if ( args.length > 1 ) {
				var type:int = parseInt( args.shift());
				var missionID:int = parseInt( args.shift());
				
				switch ( type ) {
					case MissionConstant.FOLLOW_LINK_TYPE_NPC:
						var npcID:int = parseInt( args[ 0 ]);
						return ( npcID / 1000000 ) % 10;
					case MissionConstant.FOLLOW_LINK_TYPE_MONSTER:
						mapID = parseInt( args[ 0 ]);
						return ( mapID / 1000 ) % 10;
					case MissionConstant.FOLLOW_LINK_TYPE_COLLECT:
						mapID = parseInt( args[ 1 ]);
						return ( mapID / 1000 ) % 10;
					default:
						return -1;	
				}
			}
			return -1;
		}

		private function addImg(rect:Rectangle, index:int):void {
			var _linkData:Array = _linkArray[index].replace('event:', '').split(',');
			var _gotoFaction:int = getGotoFaction(_linkData);
			var _roleFaction:int = GlobalObjectManager.getInstance().user.base.faction_id;
			if ( _gotoFaction!=0 && _roleFaction != _gotoFaction) {
				return ;
			}
			var image:Image = new Image();
			image.source = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"fly");
			image.addEventListener(MouseEvent.CLICK, onImageClick);
			image.data = index;
			image.useHandCursor = image.buttonMode = true;
			image.width = 17;
			image.height = 18;
			image.x = rect.x + 2;
			image.y = rect.y - 2;
			image.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			image.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			_images.push(image);

			addChild(image);
		}

		protected function onRollOut( event:MouseEvent ):void {
			ToolTipManager.getInstance().hide();
		}

		protected function onRollOver( event:MouseEvent ):void {
			ToolTipManager.getInstance().show( "消耗一个【传送卷】立即传送，VIP可免费传送",50 );
		}
	
		
		private function dispose():void {
			for each (var image:Image in _images) {
				removeChild(image);
			}
			_images.length = 0;
		}

		private function onTextClick(event:TextEvent):void {
			if (linkHandler != null) {
				linkHandler(event.text);
			}
		}

		private function onImageClick(event:MouseEvent):void {
			var image:Image = event.currentTarget as Image;
			if (SystemConfig.serverTime - MissionFollowTextField._clickTime <= 5) {
				BroadcastSelf.getInstance().appendMsg('请不要频繁操作');
				return;
			}

			MissionFollowTextField._clickTime = SystemConfig.serverTime;
			var linkArgs:String = _linkArray[int(image.data)].replace('event:', '');
			MissionModule.getInstance().transGoto(linkArgs);
			
		}
	}
}