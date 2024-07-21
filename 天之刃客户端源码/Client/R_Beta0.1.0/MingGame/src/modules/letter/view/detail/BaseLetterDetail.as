package modules.letter.view.detail
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	import modules.letter.LetterModule;
	
	public class BaseLetterDetail extends BasePanel{
		protected var sender_desc_txt:TextField;
		protected var sender_txt:TextField;
		protected var type_desc_txt:TextField;
		protected var type_txt:TextField;
		protected var content:TextArea;
		public var accessory:AccessoryView;
		protected var contentBackUI:Skin;
		protected var lineUI:Bitmap;
		
		public function BaseLetterDetail(key:String,xValue:Number = NaN, yValue:Number = NaN){
			super(key);
			
			this.width = 326;
			this.height = 395;
			
			//内容提要背景
			contentBackUI = Style.getPanelContentBg();
			contentBackUI.setSize(306,240);
			contentBackUI.x = 10;
			contentBackUI.y = 75;
			addChild(contentBackUI);
			
			initView();
		}
		
		
		private function initView():void{
			sender_desc_txt = ComponentUtil.createTextField("发件人：",14,10,null,50,21,this);
			sender_desc_txt.textColor = 0xAFE1EC;
			sender_desc_txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			sender_desc_txt.mouseEnabled = false;
			
			sender_txt = ComponentUtil.createTextField("",60,10,null,440,21,this);
			sender_txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			sender_txt.mouseEnabled = false;
			
			//间隔条
			lineUI = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			this.addChild(lineUI);
			lineUI.width = 298;
			lineUI.x = 15;
			lineUI.y = sender_desc_txt.y + sender_desc_txt.height + 3;
			
			
			type_desc_txt = ComponentUtil.createTextField("类 型：",14,lineUI.y + lineUI.height +5,null,50,21,this);
			type_desc_txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			type_desc_txt.textColor = 0xAFE1EC;
			type_desc_txt.mouseEnabled = false;
			
			type_txt = ComponentUtil.createTextField("",60,lineUI.y + lineUI.height +5,null,80,20,this);
			type_txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			type_txt.mouseEnabled = false;
			
			//内容面板
			content = new TextArea();
			this.addChild(content);
			content.addEventListener(TextEvent.LINK, onLinkText);
			content.x = contentBackUI.x;
			content.y = contentBackUI.y +1;
			content.width = contentBackUI.width;
			content.height = 200;
			content.textField.maxChars = 200;
			content.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
			content.bgSkin = null;
		}
		
		private function onLinkText(e:TextEvent):void
		{
			if (e.text == 'openShouchongWin') {
				ActivityModule.getInstance().openShouchongWin();
			}
		}
		
		public function lockAccessory():void{}
		
		/**
		 * 解除锁定附件，bool为true标志提取或者发送成功后解除锁定 
		 * @param bool
		 * 
		 */		
		public function unlockAccessory(bool:Boolean):void{}
	}
}