package com.components.alert {
	import com.common.FilterCommon;
	import com.common.InputKey;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.Button;
	import com.ming.utils.TextUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class BaseDialog extends Panel {
		private static const tf:TextFormat=new TextFormat("Tahoma", 12, 0x105e8d, null, null, null, null, null, "left");
		public var id:String;
		private var okButton:Button;
		private var cancelButton:Button;
		private var content:TextField;
		private var yesHandler:Function;
		private var noHandler:Function;
		private var params:Array;
		public var autoFocus:Boolean=true;
		private var bg:Sprite;
		public var linkHandler:Function;

		public function BaseDialog() {
			super();
			initView();
		}

		private function initView():void {
			
//			this.showCloseButton=false;
			
			width=415;
			titleAlign=2;
			titleFormat=BasePanel.titleTF;
			//titleFitlers=BasePanel.tfilters;
			panelSkin=Style.getInstance().alertSkin;
			bg=new Sprite();
			bg.x=10;
			addChild(bg);
			tabEnabled=false;
			content=new TextField();
			content.filters = FilterCommon.FONT_BLACK_FILTERS;
			content.y=15;
			content.wordWrap=true;
			content.multiline=true;
			content.mouseWheelEnabled = false;
			content.addEventListener(TextEvent.LINK, onLinkText);
			addChild(content);
		}

		public function show(msg:String, title:String="", yesHandler:Function=null, noHandler:Function=null, leftLabel:String="确定", rightLabel:String="取消", params:Array=null, showRightBtn:Boolean=true, showCloseBtn:Boolean=false, position:Point=null,showHelpBtn:Boolean=false):void {
			this.yesHandler=yesHandler;
			this.noHandler=noHandler;
			this.params=params;
			this.showCloseButton=showCloseBtn;
			this.showHelpButton=showHelpBtn;
			this.title=title;

			tf.kerning=false;
			tf.leading=8;
			tf.color=0xF6F5CD;
			content.defaultTextFormat=tf;
			content.htmlText=msg;
			content.width=365;
			content.x=25;

			var tempWidth:Number=content.textWidth + 5;
			this.width=tempWidth + 70;
			if (this.width < 280) {
				this.width=280;
			} else if (this.width > 415) {
				this.width=415;
			}
			if (tempWidth < 365) {
				content.width=tempWidth;
				content.x=(width - tempWidth) / 2;
			}
			if (content.textWidth > this.width) {
				msg="        " + msg;
			}
			content.htmlText=msg;

			content.height=content.textHeight + 10;
			height=content.y + content.height + 80;

			if (okButton == null) {
				okButton=ComponentUtil.createButton(leftLabel, 0, 0, 65, 26, this, Style.setDeepRedBtnStyle);
				okButton.name="ok";
				okButton.addEventListener(MouseEvent.CLICK, onOkHandler);
			}
			if (leftLabel && leftLabel.length > 3) {
				okButton.width=Math.max(65, TextUtil.getTextWidth(leftLabel) + 20);
			} else {
				okButton.width=65;
			}
			okButton.label=leftLabel;
			if (showRightBtn) {
				if (cancelButton == null) {
					cancelButton=ComponentUtil.createButton(rightLabel, 0, 0, 65, 26, this, Style.setDeepRedBtnStyle);
					cancelButton.name="cancel";
					cancelButton.addEventListener(MouseEvent.CLICK, onCancelHandler);
				} else {
					cancelButton.label=rightLabel;
					addChild(cancelButton);
				}
				if (rightLabel && rightLabel.length > 3) {
					cancelButton.width=Math.max(65, TextUtil.getTextWidth(rightLabel) + 20);
				} else {
					cancelButton.width=65;
				}
			} else if (cancelButton && cancelButton.parent) {
				cancelButton.parent.removeChild(cancelButton);
			}
			if (cancelButton && cancelButton.parent) {
				okButton.x=55;
				cancelButton.x=width - (55 + cancelButton.width);
				okButton.y=cancelButton.y=content.y + content.height + 5;
			} else {
				okButton.x=(width - okButton.width) / 2;
				okButton.y=content.y + content.height + 5;
			}
			if (position == null) {
				WindowManager.getInstance().centerWindow(this);
			} else {
				x=position.x
				y=position.y;
			}
			if (autoFocus) {
				okButton.addEventListener(FocusEvent.FOCUS_IN, onFocusOn);
				okButton.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				if (cancelButton && cancelButton.parent) {
					cancelButton.addEventListener(FocusEvent.FOCUS_IN, onFocusOn);
					cancelButton.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				}
				addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				addEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage);
				addEventListener(MouseEvent.CLICK, onMouseClick);
			}
			drawRoundRect();
		}

		private function drawRoundRect():void {
//			with (bg.graphics) {
//				clear();
//				beginFill(0, 0.5);
//				drawRoundRect(0, 0, width - 20, height - 40, 6, 6);
//				endFill();
//			}
		}

		private function onMouseClick(event:MouseEvent):void {
			setFocus();
		}

		private function onAddedToStage(event:Event):void {
			setFocus();
		}

		private function onRemovedToStage(event:Event):void {
			if (bitmap && bitmap.parent) {
				bitmap.parent.removeChild(bitmap);
			}
		}

		private function onOkHandler(event:MouseEvent):void {
			if (yesHandler != null) {
				if (params != null)
					yesHandler.apply(null, params);
				else
					yesHandler.apply();
			}
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}

		private function onCancelHandler(event:MouseEvent):void {

			if (noHandler != null) {
				if (params != null)
					noHandler.apply(null, params);
				else
					noHandler.apply();
			}
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}

		public function setFocus():void {
			if (autoFocus && stage) {
				if (bitmap == null || bitmap.parent == null) {
					stage.focus=okButton;
				}
			}
		}

		private function onKeyDown(event:KeyboardEvent):void {
			event.stopPropagation();
			//var target:Button = Button(event.currentTarget);
			if (event.keyCode == InputKey.ENTER && bitmap && bitmap.parent) {
				if (bitmap.name == "ok") {
					onOkHandler(null);
				} else if (bitmap.name == "cancel") {
					onCancelHandler(null);
				}
			}
		}

		private var bitmap:Bitmap;

		private function onFocusOn(event:FocusEvent):void {
			var b:Button=Button(event.currentTarget);
			if (bitmap == null) {
				bitmap=new Bitmap();
				bitmap.bitmapData=Style.getUIBitmapData(GameConfig.T1_UI, "kuang");
			}
			bitmap.name=b.name;
			bitmap.x=b.x;
			bitmap.width=b.width;
			bitmap.height=b.height;
			bitmap.y=b.y;
			addChild(bitmap);
		}

		private function onFocusOut(event:FocusEvent):void {
			if (bitmap && bitmap.parent) {
				bitmap.parent.removeChild(bitmap);
			}
		}

		private function onLinkText(event:TextEvent):void {
			if (linkHandler != null) {
				linkHandler.apply(null, [event]);
			}
		}
	}
}