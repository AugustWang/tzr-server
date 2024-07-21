package modules.Activity.view.itemRender {
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.Activity.ActivityModule;
	import modules.broadcast.views.Tips;
	import modules.greenHand.GreenHandModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	/**
	 *
	 * @author Owner
	 */
	public class GiftRender extends UIComponent {
		/**
		 *
		 * @param data
		 */
		public function GiftRender() {
			super();
			this.height=169;
			this.width=310;
			init();
		}

		private var giftCanvas:GiftListCanvas;
		private var giftBTN:GiftBtnCanvas;
		private var textformat:TextFormat;
		//头背景
		private var headleftBg:Bitmap;
		//title
		private var nameTxt:TextField;

		private function init():void {
			Style.setBorderSkin(this);
			
			textformat=new TextFormat("", 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER);

			headleftBg=Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			addChild(headleftBg);
			headleftBg.width=this.width - 1;
			headleftBg.height=19;
			
			nameTxt = ComponentUtil.createTextField("",0,3, textformat, headleftBg.width, 20, this);
			nameTxt.filters = Style.textBlackFilter;
		}
		
		//type为4时的input
		private var giftNumber:TextInput;
		
		private function addUI(data:Object):void
		{
			var type:int = data.type;
			switch(type)
			{
				case 1:
					nameTxt.text="首充大礼包";
					break;
				case 2:
					nameTxt.text="开心大礼包";	
					break;
				case 3:
					nameTxt.text="充值累积大礼包";
					break;
				case 4:
					nameTxt.text="活动礼包";
					
					// 蛋疼的设计
					
					var contentText:TextField=new TextField();
					var contentTextFormat:TextFormat=new TextFormat("Tahoma", 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.
						LEFT);
					contentText.defaultTextFormat=contentTextFormat;
					contentText.text="将活动放送的激活码粘贴到左框，点击“领取礼包”赢大奖";
					contentText.x=217;
					contentText.y=30;
					contentText.width=70;
					contentText.wordWrap=true;
					addChild(contentText);
					
					var btn:Button = new Button();
					btn.x = 217;
					btn.y = contentText.y + contentText.height - 10;
					btn.label = "领取礼包";
					btn.width = 65;
					btn.height = 25;
					btn.addEventListener(MouseEvent.CLICK, onGetGift);
					addChild(btn);
					
					giftNumber = new TextInput();
					giftNumber.x = 15;
					giftNumber.y = 34;
					giftNumber.width=120;
					giftNumber.height=26;
					giftNumber.text="请ctr+v输入激活码";
					giftNumber.addEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
					giftNumber.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
					addChild(giftNumber);
					
					return;
					
			}
			
			if(giftBTN == null)
			{
				giftBTN=new GiftBtnCanvas(data.type);
				addChild(giftBTN);
				
				giftBTN.firstBTN.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
				giftBTN.secondBTN.addEventListener(MouseEvent.CLICK, onGetGiftMouseClickHandler);
			}
			
			if(giftCanvas == null)
			{
				giftCanvas=new GiftListCanvas(data.type, data.data);
				addChild(giftCanvas);
			}
		}
		
		private function onFocusInHandler(evt:FocusEvent):void {
			giftNumber.text="";
		}
		
		private function onFocusOutHandler(evt:FocusEvent):void {
			//不去掉这句，在开服时会出现领取不了的现象
			//txtInput.text="请输入激活码";
		}
		
		protected function onGetGift(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var rep:RegExp = /^[A-Za-z0-9]+$/g;
			var code:String = StringUtil.trim(giftNumber.text);
			if(rep.test(code)){
				GreenHandModule.getInstance().requestActivationCode(code);
				Button(event.currentTarget).enabled = false;
				giftNumber.text = "已经领取";
			}else{
				Tips.getInstance().addTipsMsg("激活码不正确，新重新输入！");
				giftNumber.text = "请ctr+v输入激活码";
			}
		}
		
		public function dispost():void {
			if (giftBTN.firstBTN.hasEventListener(MouseEvent.CLICK)) {
				giftBTN.firstBTN.removeEventListener(MouseEvent.CLICK, onMouseClickHandler);
			}

			if (giftBTN.secondBTN.hasEventListener(MouseEvent.CLICK)) {
				giftBTN.secondBTN.removeEventListener(MouseEvent.CLICK, onGetGiftMouseClickHandler);
			}

			giftCanvas.dispost();
		}
		
		private var rep:RegExp=/\|/g;
		private function onMouseClickHandler(evt:MouseEvent):void {
			var label:String=Button(evt.currentTarget).label;
			if (label == "快速充值") {
				JSUtil.openPaySite();
			} else if (label == "领取新手卡") {
				var activateCodeUrl:String=GameParameters.getInstance().activateCodeUrl;
				JSUtil.openWebSite(activateCodeUrl);
			}
		}

		private function onGetGiftMouseClickHandler(evt:MouseEvent):void {
			var type:String = this.data.type;
			switch (type) {
				case "1":
					//请求首充大礼包
					ActivityModule.getInstance().requestGetFirstPayGift(1);
					break;
				case "2":
					var rep:RegExp=/^[A-Za-z0-9]+$/g;
					var code:String=StringUtil.trim(giftCanvas.txtInput.text);
					if (rep.test(code)) {
						GreenHandModule.getInstance().requestActivationCode(code);
							//						Button(evt.currentTarget).enabled = false;
					} else {
						Tips.getInstance().addTipsMsg("激活码不正确，新重新输入！");
					}
					break;
				case "3":
					//获取单个武器礼包
					ActivityModule.getInstance().requestGetFirstPayGift(2);
			}
		}

		override public function get data():Object {
			return super.data;
		}

		private var itemId:int;

		override public function set data(value:Object):void {
			if (value != null) {
				super.data=value;
				addUI(value);
			}
		}
	}
}
import com.globals.GameConfig;
import com.globals.GameParameters;
import com.ming.managers.ToolTipManager;
import com.ming.ui.controls.Button;
import com.ming.ui.controls.Image;
import com.ming.ui.controls.TextInput;
import com.ming.ui.style.StyleManager;
import com.ming.utils.StringUtil;
import com.utils.ComponentUtil;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import modules.Activity.ActivityModule;
import modules.broadcast.views.Tips;
import modules.greenHand.GreenHandModule;
import modules.mypackage.ItemConstant;
import modules.mypackage.managers.ItemLocator;
import modules.mypackage.views.GoodsImage;
import modules.mypackage.vo.BaseItemVO;
import modules.mypackage.vo.EquipVO;

import proto.common.p_goods;

class GiftBtnCanvas extends Sprite {

	private var contentText:TextField;
	/**
	 *
	 * @default
	 */
	public var firstBTN:Button;
	/**
	 *
	 * @default
	 */
	public var secondBTN:Button;
	//类型判断
	private var type:int;

	function GiftBtnCanvas(type:int) {
		initUI(type);
	}

	private function initUI(type:int):void {
		this.type=type;

		contentText=new TextField();
		var contentTextFormat:TextFormat=new TextFormat("Tahoma", 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.
			LEFT);
		contentText.defaultTextFormat=contentTextFormat;
		if (type == 2) {
			contentText.text="将新手卡输入到左框,点击领取礼包即可。";
			firstBTN=ComponentUtil.createButton("领取新手卡", 216, contentText.height - 5, 70, 25, this);
			secondBTN=ComponentUtil.createButton("兑换礼包", 216, contentText.height + firstBTN.height, 70, 25, this);
		} else {
			contentText.text="充值后点击领取礼包即可获得。";
			firstBTN=ComponentUtil.createButton("快速充值", 216, contentText.height - 5, 70, 25, this);
			secondBTN=ComponentUtil.createButton("领取奖品", 216, contentText.height + firstBTN.height, 70, 25, this);
		}

		contentText.x=217;
		contentText.y=30;
		contentText.width=70;
		contentText.wordWrap=true;

		addChild(contentText);
		addChild(firstBTN);
		addChild(secondBTN);
	}
}

class GiftListCanvas extends Sprite {
	//存放图片的sprite
	/**
	 *
	 * @default
	 */
	public var parentCanvas:Sprite;
	/**
	 *
	 * @default
	 */
	public var txtInput:TextInput;
	private var data:Array;
	private var baseItemVo:BaseItemVO;
	private var type:int;

	function GiftListCanvas(type:int, data:Array) {
		this.data=data;
		this.type=type;
		initUI(type, data);
	}

	private function createCountLabel(num:String, parent:Sprite):void {
		var tf:TextFormat=StyleManager.textFormat;
		tf.size=11;
		var countlb:TextField=ComponentUtil.createTextField("", 0, 18, tf, 33, NaN, parent);
		countlb.text=num
		countlb.filters=[new GlowFilter(0x000000)];
		countlb.selectable=false;
		countlb.autoSize="right";
	}

	private function initUI(type:int, data:Array):void {
		var length:int=data.length;
		var image:Image;
		var image2:GoodsImage;
		parentCanvas=new Sprite();
		if (type != 3) {
			for (var i:int=0; i < length; i++) {
				var o:Object=data[i];

				var icon:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
				icon.name=o.typeid;
				image=new Image();
				image.x=4;
				image.y=4;
				var imageURL:String=ItemLocator.getInstance().getGeneral(int(o.typeid)).path;
//				image.source = GameConfig.ROOT_URL+imageURL;
				image.source = imageURL;
//				var itemVO:BaseItemVO = ItemLocator.getInstance().getObject(int(o.itemId));
//				image.setImageContent(itemVO, itemVO.path);
				var row:int=i / 4;
				var column:int=i % 4;
				icon.addChild(image);
				icon.x=column * 42 + column * 2;
				icon.y=row * 40 + row * 2;
				//个数
				createCountLabel(o.num, icon);

				parentCanvas.addChild(icon);
			}
		} else {
			//武器的信息
			//var dataVO:Object = ItemLocator.getInstance().getGeneral(int(data[0].itemId));
			var dataVO:p_goods=data[0];
			var equipVO:EquipVO=new EquipVO();
			equipVO.copy(dataVO);
			//图片
			var icon2:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			this.addChild(icon2);
			icon2.name=equipVO.typeId.toString();
			icon2.x=26;
			icon2.y=10;
			image2=new GoodsImage();
			image2.setImageContent(equipVO, equipVO.path);
			image2.x=4;
			image2.y=4;
			
			image2.source=equipVO.path;
			icon2.addChild(image2);

			parentCanvas.addChild(icon2);
		}
		addChild(parentCanvas);
		switch (type) {
			case 1:
				this.y=30;
				this.x=10;
				parentCanvas.x=15;
				break;
			case 2:
				this.y=30;
				this.x=10;
				parentCanvas.y=35;

				txtInput=new TextInput();
				txtInput.x=3;
				txtInput.y=2;
				txtInput.width=120;
				txtInput.height=26;
				txtInput.text="请ctr+v输入激活码";
				txtInput.textField.selectable=true;
				addChild(txtInput);
				txtInput.addEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
				txtInput.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
				break;
			case 3:
				this.y=40;

				var name:TextField=new TextField();
				var nameTextFormat:TextFormat=new TextFormat("Tahoma", 14, ItemConstant.COLOR_VALUES2[int(equipVO.color)],
					null, null, null, null, null, TextFormatAlign.LEFT);
				name.defaultTextFormat=nameTextFormat;
				name.x=85;
				name.y=0;
				name.text=dataVO.name;
				this.addChild(name);

				var descTextField:TextField=new TextField();
				var descTextFormat:TextFormat=new TextFormat("Tahoma", 12, 0xDCDCDC, null, null, null, null, null, TextFormatAlign.
					LEFT);
				descTextField.defaultTextFormat=descTextFormat;
				descTextField.width=120;
				descTextField.wordWrap=true;
				descTextField.x=85;
				descTextField.y=25;
				descTextField.text=equipVO.desc;
				this.addChild(descTextField);
				break;
		}

		if (parentCanvas != null) {
			parentCanvas.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler, true);
			parentCanvas.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler, true);
		}
	}

	/**
	 *
	 */
	public function dispost():void {
		if (txtInput != null && txtInput.hasEventListener(FocusEvent.FOCUS_IN)) {
			txtInput.removeEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
			txtInput.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
		}
		if (parentCanvas != null && parentCanvas.hasEventListener(MouseEvent.ROLL_OVER)) {
			parentCanvas.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler, true);
			parentCanvas.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler, true);
		}
	}

	private function onFocusInHandler(evt:FocusEvent):void {
		txtInput.text="";
	}
	
	private function onFocusOutHandler(evt:FocusEvent):void {
		//不去掉这句，在开服时会出现领取不了的现象
		//txtInput.text="请输入激活码";
	}

	private function onMouseRollOverHandler(evt:MouseEvent):void {
		var target:Sprite=evt.target as Sprite;
		if (type == 3) {
			baseItemVo=ItemConstant.wrapperItemVO(data[0]);
		} else {
			var itemId:int=int(target.name);
			baseItemVo=ItemLocator.getInstance().getObject(itemId);
		}

		if (baseItemVo != null) {
			ToolTipManager.getInstance().show(baseItemVo, 0, 0, 0, "targetToolTip");
		}
	}

	private function onMouseRollOutHandler(evt:MouseEvent):void {
		ToolTipManager.getInstance().hide();
	}
}






