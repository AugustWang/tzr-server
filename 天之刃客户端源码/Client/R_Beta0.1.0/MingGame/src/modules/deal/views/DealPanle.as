package modules.deal.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.deal.DealModule;
	import modules.mypackage.vo.BaseItemVO;
	
	public class DealPanle extends BasePanel
	{
		
		private var _srcRoleName:String;//交易发起方
		private var _tarRoleName:String;//交易目标
		
		public function DealPanle(srcRoleName:String,tarRoleName:String)
		{
			_srcRoleName = srcRoleName;
			_tarRoleName = tarRoleName;
			this.width = 304;
			this.height = 450;
		
			title = "交易";
			setupUI();
		}
		
		private var _MoneyLab:TextField;//货币标签
		private var _selfSprite:UIComponent;//自己的交易区
		private var _selfNameTF:TextField;//已方角色名
		private var _selfSilverDingTI:TextInput;//绽
		private var _selfSilverLiangTI:TextInput;//两
		private var _selfSilverWenTI:TextInput;//文
		private var _selfGoldTI:TextInput;// 我的交易的元宝
		
		private var _otherSprite:UIComponent;//Sprite;//对方的交易区
		private var _otherNameTF:TextField;//对方角色名
		private var _otherSilverTI:TextInput;//对方的交易银子
		private var _otherGoldTI:TextInput;//对方的交易元宝
		
		public var locklBtn:Button;//取消交易
		private var _commitBtn:Button;//确定交易
		
		private var otherTile:DealTile;
		private var selfTile:DealTile;
		
		private function setupUI():void
		{
			_otherSprite = new UIComponent();
			Style.setBorderSkin(_otherSprite);
			_otherSprite.x = 10;
			_otherSprite.y = 5;
			_otherSprite.width = 285;
			_otherSprite.height = 185;
			
			otherTile = new DealTile(false);
			otherTile.x = 6;
			otherTile.y = 20;//18;
			
			var otherNameLab:TextField = createLab(5,2,0xFFFFFF,"对方：")
			var otherName:String;
			_tarRoleName?otherName=_tarRoleName:otherName="";
			
			_otherNameTF = createLab(48,2,0xFFFFFF,otherName);
			
			var tf:TextFormat = new TextFormat;
			tf.color = 0xFFCC00;
			var otherGoldText:TextField = ComponentUtil.createTextField("元宝：", 5, _otherSprite.height - 48, tf, 35, 25, _otherSprite);
			_otherGoldTI = createTI(otherGoldText.x + 40, _otherSprite.height - 48, 230, 20, 0xFFFFFF,4);
			_otherGoldTI.enabled = false;
			_otherSprite.addChild(_otherGoldTI);
			
			// 银子提示文本框
			var otherLab:TextField = createLab(5,_otherSprite.height - 25,0xFFCC00,"银子:");
			_otherSilverTI = createTI(otherLab.x + 40,_otherSprite.height -25,230,20,0xffffff,10,new Rectangle(2,2,44,14));
			_otherSilverTI.enabled = false;
				
			_otherSprite.addChild(otherNameLab);
			_otherSprite.addChild(_otherNameTF);	
			_otherSprite.addChild(otherLab);
			_otherSprite.addChild(_otherSilverTI);
			
			_otherSprite.addChild(otherTile);
			
			_selfSprite = new UIComponent();//Style.getViewBg("roundBorderOver"); // 
			Style.setBorderSkin(_selfSprite);
			_selfSprite.x = _otherSprite.x;
			_selfSprite.y = _otherSprite.y + _otherSprite.height + 2;//10;
			
			_selfSprite.width = 285;
			_selfSprite.height = 185;
			
			selfTile = new DealTile();
			selfTile.x = 6;
			selfTile.y = 20;//18;
			
			var selfNameLab:TextField = createLab(5,2,0x00FF00,"我方：");
			var selfName:String;
			_srcRoleName?selfName=_srcRoleName:selfName=""; 
			
			_selfNameTF = createLab(48,2,0xFFFFFF,selfName);
			
			var selfGoldText:TextField = ComponentUtil.createTextField("元宝：", 5, _selfSprite.height - 48, tf, 35, 25, _selfSprite);
			_selfGoldTI = createTI(selfGoldText.x + 40, _selfSprite.height - 48, 230, 20, 0xFFFFFF,4);
			_selfSprite.addChild(_selfGoldTI);
			_selfGoldTI.addEventListener(Event.CHANGE, onGoldChangeHandler);
			
			var selfLab:TextField = createLab(5,_selfSprite.height - 25,0xFFCC00,"银子：");
			
			_selfSilverDingTI = createTI(selfLab.x + 40,_selfSprite.height - 25,55,20,0xFFFFFF,4);
			_selfSilverDingTI.addEventListener(Event.CHANGE,onMoneyChangeHandler);
			var selfGoldLab:TextField = createLab(_selfSilverDingTI.x + _selfSilverDingTI.width + 4 ,_selfSprite.height - 25,0xFFCC00,"锭");
			
			_selfSilverLiangTI = createTI(selfGoldLab.x + 20,_selfSprite.height - 25,55,20);
			_selfSilverLiangTI.addEventListener(Event.CHANGE,onMoneyChangeHandler);
			var selfSilverLab:TextField = createLab(_selfSilverLiangTI.x + _selfSilverLiangTI.width + 4 ,_selfSprite.height - 25,0xFFCC00,"两");
			
			_selfSilverWenTI = createTI(selfSilverLab.x + 20,_selfSprite.height - 25,55,20);
			_selfSilverWenTI.addEventListener(Event.CHANGE,onMoneyChangeHandler);
			var selfCoinLab:TextField = createLab(	_selfSilverWenTI.x + _selfSilverWenTI.width + 4,_selfSprite.height -25,0xFFCC00,"文");		
			
			_selfSprite.addChild(selfNameLab);
			_selfSprite.addChild(_selfNameTF);
			
			_selfSprite.addChild(selfLab);
			
			_selfSprite.addChild(_selfSilverDingTI);
			_selfSprite.addChild(selfGoldLab);
			
			_selfSprite.addChild(_selfSilverLiangTI);
			_selfSprite.addChild(selfSilverLab);
			
			_selfSprite.addChild(_selfSilverWenTI);
			_selfSprite.addChild(selfCoinLab);
			
			_selfSprite.addChild(selfTile);
			
			
			_commitBtn = new Button();
			_commitBtn.label = "确定";// 交易
			_commitBtn.enabled = false
			_commitBtn.addEventListener(MouseEvent.CLICK,onCommitHandler);
			_commitBtn.setSize(70,25);
			_commitBtn.x = this.width - 83;
			_commitBtn.y = this.height - 72;
			
			locklBtn = new Button();
			locklBtn.label = "锁定"; //交易
			locklBtn.addEventListener(MouseEvent.CLICK,onLockHandler);
			locklBtn.setSize(70,25);
			locklBtn.x = _commitBtn.x - 80;
			locklBtn.y = _commitBtn.y ;
			
			addChild(_selfSprite);
			addChild(_otherSprite);
			addChild(_commitBtn);
			addChild(locklBtn);
		}
		
		private function onGoldChangeHandler(evt:Event):void
		{
			var gold:int = GlobalObjectManager.getInstance().user.attr.gold;
			var goldTmp:int = int(_selfGoldTI.text);
			if (goldTmp > gold)
				_selfGoldTI.text = gold.toString();
		}
		
		private function onMoneyChangeHandler(evt:Event):void
		{
			var sum:int = GlobalObjectManager.getInstance().user.attr.silver;
			var tempSum:int = int(_selfSilverDingTI.text)*10000 + int(_selfSilverLiangTI.text)*100 + int(_selfSilverWenTI.text);
			if(tempSum > sum)
			{
				var moneyArr:Array = MoneyTransformUtil.silverToOther(sum);
				_selfSilverDingTI.text = moneyArr[0];
				_selfSilverLiangTI.text = moneyArr[1];
				_selfSilverWenTI.text = moneyArr[2];
			}
		}
		
		/**
		 *设置我方与对方的交易名字 
		 * @param selfName
		 * @param otherName
		 * 
		 */		
		public function setName(selfName:String,otherName:String):void
		{
			if(_otherNameTF)
			{
				_otherNameTF.text = otherName;
			}
			
			if(_selfNameTF)
			{
				_selfNameTF.text = selfName;
			}
		}

		private function onCommitHandler(evt:MouseEvent):void
		{
			_commitBtn.enabled = false;
			DealModule.getInstance().dealCommit();
		}
		
		private function onLockHandler(evt:MouseEvent):void
		{
			locklBtn.enabled = false;
			setTextInputEditable(false)
			var ding:int = int(_selfSilverDingTI.text);
			var liang:int = int(_selfSilverLiangTI.text);
			var wen:int = int(_selfSilverWenTI.text);
			var gold:int = int(_selfGoldTI.text);
			
//获得goods项数组
			var goodsArr:Array = selfTile.goodsArr;
			var itemArr:Array = selfTile.itemArr;
			
			selfTile.onlock();
			DealModule.getInstance().dealLock(gold, ding,liang,wen,goodsArr);
			DealModule.getInstance().setItemsPos(itemArr);
			DealModule.getInstance().baseItemArr = itemArr;// baseItemArr;
		}
		
		public function setTextInputEditable(value:Boolean):void
		{
			_selfSilverDingTI.enabled = value;
			_selfSilverDingTI.mouseEnabled = _selfSilverDingTI.mouseChildren = value;
			_selfSilverLiangTI.enabled = value;
			_selfSilverLiangTI.mouseEnabled = _selfSilverLiangTI.mouseChildren = value;
			_selfSilverWenTI.enabled = value;
			_selfSilverWenTI.mouseEnabled = _selfSilverWenTI.mouseChildren = value;
		}
		
		/**
		 *锁定自己 
		 * 
		 */
		private var _selfLock:Boolean;
		public function lockSelf():void
		{
			//  trace("锁定自己");	
			locklBtn.label =  "已锁定";
//			setTextInputEditable(true);
			setSelfMask(_selfSprite.x,_selfSprite.y);
			_selfLock = true;
			if(_selfLock && _otherLock)
			{
				_commitBtn.enabled = true;
			}else
			{
				//  trace("等待对方锁定，请稍候。");
			}
		}
		
		/**
		 *锁定其它 
		 * 
		 */
		private var _otherLock:Boolean;
		public function lockOther(goods:Array,gold:int, ding:String,liang:String,wen:String):void
		{
			setOtherMask(_otherSprite.x,_otherSprite.y);
			if(goods)
			{
				otherTile.setGoods(goods);	
			}
			_otherGoldTI.text = String(gold);
			_otherSilverTI.text = ding + "绽  " + liang + "两  " + wen + "文";
			_otherLock = true
			if(_otherLock && _selfLock)
			{
				_commitBtn.enabled = true;
			}
		}
		
		public function reset(value:Boolean):void
		{
			_selfLock  = value;
			_otherLock = value;
			_commitBtn.enabled = value;
			locklBtn.enabled = !value;
			locklBtn.label = "锁定"
			if(_selfMask)
			{
				_selfMask.visible = false;
			}
			if(_otherMask)
			{
				_otherMask.visible = false;
			}
			_otherSilverTI.text = "";
			_selfSilverDingTI.text = "0";
			_selfSilverLiangTI.text = "0";
			_selfSilverWenTI.text = "0";
		}
		
		private function createLab(x:int,y:int,color:int,label:String):TextField
		{
			var tf:TextField = new TextField();
			tf.selectable = false;
			tf.defaultTextFormat = Style.textFormat
			tf.text = label;
			tf.textColor = color;
			tf.x = x;
			tf.y = y;
			tf.height = 25
			return tf;
		}
		
		private function createTI(x:int,y:int,width:int,height:int,color:uint=0xffffff,maxChars:int=2,rect:Rectangle=null):TextInput
		{
			var ti:TextInput = new TextInput();
			var tf:TextFormat = new TextFormat();
			tf.align = TextFormatAlign.CENTER;
			tf.color = color;
			tf.size = 12;
			tf.font = "Verdana";
			ti.maxChars = maxChars;
			ti.textField.defaultTextFormat = tf;
			ti.x = x;
			ti.y = y;
			ti.width = width;
			ti.height = height;
			ti.restrict = "0-9";
			return ti;
		}
		
		private var _selfMask:Sprite;
		private function setSelfMask(xPos:Number,yPos:Number):void
		{
			if(!_selfMask)
			{
				_selfMask = new Sprite();
				_selfMask.graphics.beginFill(0xaaaaaa,0.6);
				_selfMask.graphics.drawRect(xPos,yPos,289,183);
				_selfMask.graphics.endFill();
				
//				_selfMask = Style.getViewBg("dealMask");
			}
//			_selfMask.mouseChildren = false;
			_selfMask.mouseEnabled = false;
			_selfMask.visible = true;
			
			
			if(!contains(_selfMask))
			{
				addChild(_selfMask);
			}
		}
		
		private var _otherMask:Sprite;
		private function setOtherMask(xPos:Number=0,yPos:Number=0):void
		{
			if(!_otherMask)
			{
				_otherMask = new Sprite();
				_otherMask.graphics.beginFill(0xaaaaaa,0.6);
				_otherMask.graphics.drawRect(xPos,yPos,289,183);
				_otherMask.graphics.endFill();
//				_otherMask = Style.getViewBg("dealMask");
			}
//			_otherMask.mouseChildren = false;
			_otherMask.mouseEnabled = false;
			_otherMask.visible = true;
			
			if(!contains(_otherMask))
			{
				addChild(_otherMask);
			}
		}
		
		public function deleteItem(vo:BaseItemVO):void
		{
			var index:int = selfTile.getIndexByVo(vo);
			if(index>=0)
			{
				selfTile.updateGoods(index,null);
				selfTile.deleteOneRecord(index);
			}
		}
		
		
		
		
		public function disposeTile():void
		{
			selfTile.disposeItems();
			otherTile.disposeItems();
		}
		
		public function setRoleName(selfName:String,otherName:String):void
		{
			_otherNameTF.text = otherName;
			_selfNameTF.text = selfName;
		}
		
		public function get setlfTile():DealTile
		{
			return selfTile;
		}
	}
}