package modules.deal.views
{
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.KeyWord;
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.deal.views.stallViews.StallItem;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_stall_open_toc;
	import proto.line.m_stall_request_tos;
	import proto.line.p_stall_goods;
	import proto.line.p_stall_sell_goods;
	
	/**
	 * 点背包摆摊按钮时，出来的 摆摊操作界面 
	 * @author Administrator
	 * 
	 */	
	
	public class HandleStallView extends BasePanel
	{
		
		public static const COUNT:int = 30;
		public static const COLUMN_COUNT:int = 6;
		public static const HPADDING:int = 2;
		public static const VPADDING:int = 2;
		
		private var textformat:TextFormat;
		
		private var tileSprite:Sprite;
		
		private var selfRadioBtn:RadioButton;
		
		private var salaryRadionBtn:RadioButton;
		
		private var sal:TextField;     //雇佣：
		
		private var inputTxt:TextInput;  // 几个小时
		
		private var salaryCost:TextField;  //  小时，消耗工资XXX银
		private var taxTf:TextField;
		
		private var tipsTxt:TextField;    // 雇佣店小二，不管是练级还是下线休息，都不用收摊了。
		
		
		private var stallName:TextInput;  //摊位名称！
		
		private var stallBtn:Button;        // 摆摊
		
		private var clearBtn:Button;        // 清空
		
		
		/////////　变量　/////////
		private var name_str:String;    //店名
		
		private var mode:int = 0;       //摆摊模式 0为自己摆摊 1为系统托管
		
		//private var goods:Array ; ////摆摊物品列表  [p_stall_sell_goods, ...]
		
		private var time_hour:int;  //如果是托管模式， 代表要托管多少个小时
		
		private var goods:Vector.<BaseItemVO> = new Vector.<BaseItemVO>;  //
		
		private var _error:StallErrorTip;
		
		
		public function HandleStallView()
		{
			super();
			
			title = "摆  摊";
			this.width = 278;//241;
			this.height = 385;//327;
			
			initView();
			
			addEventListener(DragItemEvent.DRAG_THREW, onThrewHandler);
		}
		
		private function initView():void
		{
			textformat = new TextFormat("Tahoma",12, 0xdeecd5);
			
			var tileBg:UIComponent = new UIComponent();
			tileBg.width = 247;
			tileBg.height = 197;
			tileBg.x = 15;
			tileBg.y = 0;
			Style.setBorderSkin(tileBg);
			addChild(tileBg);
//			var backBg:Sprite = Style.getViewBg("packageBg");
//			backBg.x = 15;
//			backBg.y = 14;
//			backBg.width = 198
//			addChild(backBg);
			
			tileSprite = new Sprite();
			tileSprite.x = 24;
			tileSprite.y = 5;
			
			addChild(tileSprite);
			
			createItems();
			
			var belowBg:UIComponent = new UIComponent();
			belowBg.width = 247;
			belowBg.height = 119;
			belowBg.x = 15;
			belowBg.y = 201;
			Style.setBorderSkin(belowBg);
			addChild(belowBg);
			
			selfRadioBtn = new RadioButton("亲自摆摊");
			selfRadioBtn.x = 25;
			selfRadioBtn.y = 210;
			selfRadioBtn.width = 135;
//			selfRadioBtn.height = 20;
			selfRadioBtn.selected = true;
			selfRadioBtn.textFormat = textformat;
//			selfRadioBtn.htmlText = "<font color='#deecd5'>亲自摆摊</font>"
			addChild(selfRadioBtn);
			selfRadioBtn.addEventListener(RadioButton.SELECTED, onSelfSelected);
			
			//雇佣店小二，不管是练级还是下线休息，都不用收摊了。
			//"亲自摆摊，交易税1%"
			//雇佣店小二，练级、下线休息，都不用收摊。
			var tf:TextFormat = new TextFormat("Tahoma",12, 0xdeecd5);
			tf.align = "center";
			tf.leading = 10;
			tipsTxt = ComponentUtil.createTextField(DealConstant.SELF_STALL_TIP,20,230,tf,230,55,this); //
			tipsTxt.multiline = true;
			tipsTxt.wordWrap = true;
			
			
			salaryRadionBtn = new RadioButton("雇佣店小二");
			salaryRadionBtn.x = 153;
			salaryRadionBtn.y = 210;
			salaryRadionBtn.width = 111;
//			salaryRadionBtn.height = 20;
			salaryRadionBtn.selected = false;
			salaryRadionBtn.textFormat = textformat;
			
			addChild(salaryRadionBtn);
			salaryRadionBtn.addEventListener(RadioButton.SELECTED, onSelected);
			
			stallName = new TextInput();
			stallName.x = 23;
			stallName.y = 283;
			stallName.width = 230;
			stallName.height = 25;
			stallName.maxChars = 15;
			stallName.text = "这里输入摊位名";
			stallName.textField.setTextFormat(new TextFormat("Tahoma",12,0xacacac,null ,null,null,null,"right"));
			
			addChild(stallName);
			stallName.addEventListener(FocusEvent.FOCUS_IN, onFocus);
			stallName.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			stallName.addEventListener(Event.CHANGE, onTextChange);
			
			
			stallBtn = ComponentUtil.createButton("摆摊",125,323,65,23,this); // new Button();
			
			stallBtn.addEventListener(MouseEvent.CLICK, stallHandler);
			
			
			clearBtn = ComponentUtil.createButton("清空", 194,323, 65,23,this); // new Button();
			clearBtn.enabled = false;
			clearBtn.addEventListener(MouseEvent.CLICK, clearHandler);
			
			_error=new StallErrorTip();
			_error.x=66;
			_error.y=145;
			_error.visible=false;
			addChild(_error);
			
			
			_costPhour = DealConstant.EMPLOY_P_HOUR;
			//addEventListener(Event.ADDED_TO_STAGE,onshowFocus);
		}
		
//		private function onshowFocus():void
//		{
//			
//		}
		
		private function onFocus(evt:FocusEvent):void
		{
			if(stallName.text == "这里输入摊位名")
			{
				stallName.text = "";
				stallName.textField.setTextFormat(new TextFormat("Tahoma",12,0xffffff,null,null,null,null,"right"));
//				stallName.setStyle("textFormat",new TextFormat("Arial",12,0x000000,true,null,null,null,"right"));
			}
		}
		private function onFocusOut(evt:FocusEvent):void
		{
			if(stallName.text == "")
			{
				stallName.text = "这里输入摊位名";
				stallName.textField.setTextFormat(new TextFormat("Tahoma",12,0xacacac,null,null,null,null,"right"));
//				stallName.setStyle("textFormat",new TextFormat("Arial",12,0xacacac,true,null,null,null,"right"));
			}
		}
		
		
		private function onSelfSelected(event:Event):void
		{
			//  trace("RadioButton");
			if(selfRadioBtn.selected == true)
			{
				removeStallType();
				mode = 0;
				stallBtn.enabled = true;
				salaryRadionBtn.selected = false;
			}else{
				
				
			}
		}
		private function onSelected(event:Event):void
		{
			//  trace("RadioButton");
			if(salaryRadionBtn.selected == true)
			{
				//  trace("RadioButton　店小二");
				addStallType();
				mode = 1;
				selfRadioBtn.selected = false;
				
			}else{
				
				removeStallType();
				mode = 0;          //自己摆
				stallBtn.enabled = true;
			}
		}
		
		private function addStallType():void
		{
			if(!sal)
			{
				sal = ComponentUtil.createTextField("雇佣:",20,233,textformat,58,23,this); // new TextField();
				
				
				inputTxt = new TextInput();
				inputTxt.x = 50;
				inputTxt.y = 233;//242
				inputTxt.width = 42;
				inputTxt.height = 20;
				inputTxt.enabled = false;
				inputTxt.restrict = "0-9";
				inputTxt.maxChars = 3;
				addChild(inputTxt);
				
				inputTxt.enabled = true;
//				stage.focus = inputTxt;
				inputTxt.text = "1";
				inputTxt.setFocus();
				inputTxt.validateNow();
				inputTxt.textField.setSelection(0,1);
				inputTxt.addEventListener(Event.CHANGE,salaryTimeinput);
				
				inputTxt.addEventListener(MouseEvent.ROLL_OVER,onTip);
				inputTxt.addEventListener(MouseEvent.ROLL_OUT,onHideTip);
				
				
				salaryCost = ComponentUtil.createTextField("",96,233,textformat,170,20,this); // new TextField();
				salaryCost.multiline = true;
				
				salaryCost.htmlText = "<font color='#deecd5'>小时，消耗工资<font color='#ffff00'>"+ DealConstant.silverToOtherString(_costPhour) +
                                      "银子</font></font>"; //\n雇佣店小二摆摊，交易税3%
				
				taxTf = ComponentUtil.createTextField("雇佣店小二摆摊，交易税3%",60,258,textformat,200,20,this);
			}
			if(tipsTxt)
			{
				if(this.contains(tipsTxt))
				{
					removeChild(tipsTxt);
				}
			}
		}
		
		private function removeStallType():void
		{
			if(sal)
			{
				removeChild(sal);
				sal = null;
				
				removeChild(inputTxt);
				inputTxt.removeEventListener(Event.CHANGE,salaryTimeinput);
				inputTxt.removeEventListener(MouseEvent.ROLL_OVER,onTip);
				inputTxt.removeEventListener(MouseEvent.ROLL_OUT,onHideTip);
				inputTxt = null;
				
				removeChild(salaryCost);
				salaryCost = null;
				
				removeChild(taxTf);
				taxTf = null;
				
			}
			
			if(!this.contains(tipsTxt))
			{
				addChild(tipsTxt);
			}
		}
		
		
		private function onTip(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().show("雇佣店小二，最多只能雇佣24小时。");
		}
		private function onHideTip(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		private var salaryTime:int = 1;
		private var _costPhour:int = 1;
		private function salaryTimeinput(evt:Event):void
		{
			
			if(inputTxt.text == "" || inputTxt.text =="0")
			{
				inputTxt.text ="1";
				inputTxt.validateNow();
				inputTxt.textField.setSelection(0,1);
				salaryTime = 1;
			}else{
				salaryTime = int(inputTxt.text);
			}
			if(salaryTime>24)
			{
				salaryTime = 24;
				inputTxt.text = "24"
			}
				
				
			setCostText();
		}
		
		private function setCostText():void
		{
			var cost_silver:int = salaryTime*_costPhour;
			var totalSilver:int = GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind;
			
			if(cost_silver > totalSilver)
			{
				stallBtn.enabled = false;//<font color='#deecd5'>小时，消耗工资<font color='#ffff00'>"+ DealConstant.silverToOtherString(_costPhour) +
				//"银子</font>\n雇佣店小二摆摊，交易税3%</font>";
				salaryCost.htmlText = "<font color='#deecd5'>小时，消耗工资 " +
					"<font color='#ff0000'>" +
					DealConstant.silverToOtherString(salaryTime*_costPhour) + "银子</font>" +
						""; //\n雇佣店小二摆摊，交易税3%</font>
			}else{
				
				stallBtn.enabled = true;
				salaryCost.htmlText = "<font color='#deecd5'>小时，消耗工资 " +
					"<font color='#ffff00'>" +
					DealConstant.silverToOtherString(salaryTime*_costPhour) + "银子</font>" +
						"</font>";//\n雇佣店小二摆摊，交易税3%</font>
			}
		}
		
		private function regExp(str:String):Boolean
		{
			var objExp:RegExp = new RegExp("^[A-Za-z0-9\u4E00-\u9FA5]*$");
			if (objExp.test(str) == true) {
				return true;
			}
			else {
				return false;
			} 
		}
		
		private function onTextChange(e:Event):void
		{
			if(stallName.text!="")
			{
				var isOK:Boolean=checkNameEach();
				stallBtn.enabled = isOK;
			}else{
				stallBtn.enabled = true;
			}
//			_submitBtn.enabled=isOK;
		}
		
		private var regEx:RegExp=/([^\u4e00-\u9fa5a-zA-Z0-9])+/;
		
		private function checkNameEach():Boolean
		{
			var isOK:Boolean;
			if (regEx.test(stallName.text))
			{
				_error.turnon("只能用中文、英文、数字，不能用特殊符号");
				isOK=false;
			}
			else if (KeyWord.instance().hasUnRegisterString(stallName.text))
			{
				var str:String=KeyWord.instance().takeUnRegisterString(stallName.text);
				_error.turnon(str);
				isOK=false;
			}
			else
			{
				isOK=true;
			}
			return isOK;
		}
		
		private function yesHandler():void
		{
			stallName.text = "";
			stallName.validateNow();
			stallName.setFocus();
		}
		
		private function stallHandler(evt:MouseEvent):void
		{
//			var vo:m_stall_confirm_tos = new m_stall_confirm_tos();
			
			if(stallName.text == "这里输入摊位名"||stallName.text=="")
			{
				name_str = GlobalObjectManager.getInstance().user.base.role_name + "的摊位";//"四个X的摊位";
				
			}else{
				name_str = stallName.text;
//				if(!regExp(name_str))
//				{
//					Alert.show("你输入了非法字符，请重新输入！","提示：",yesHandler,null,"确定","",null,false);
//					return;
//				}
				
			}
			while(goods.length>0)
			{
				var tmp:BaseItemVO = goods.pop();
				tmp = null ;
			}
			var vo:m_stall_request_tos = new m_stall_request_tos();
			
			if(contains(tileSprite))
			{
				//  trace(" contains .... ");
			}
			
			vo.name = name_str;
			vo.mode = mode;
			//mode
			if(mode==1)
			{
				time_hour = salaryTime ;
				vo.time_hour = time_hour ;
			}
			
			
			if(!checkHaveGoods())
			{
				Alert.show("请摆上要出售的物品！","提示：",null,null,"确定","",null,false);
			}else{
				
				DealModule.getInstance().StallConfirm(vo);    // 发摆上来的物品等信息给服务端。
			}
		}
		
		
		private function clearHandler(evt:MouseEvent):void
		{
			DealModule.getInstance().getAllBack();
			
//			sendAllToPackage();
		}
		
		private function createItems():void
		{
			for(var i:int=0;i<COUNT;i++){
				var item:StallItem = new StallItem();//PackageItem = new PackageItem();
//				item.packId = PACK_1;
				item.index = i;
				item.addEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);			
				var row:int = i / COLUMN_COUNT;
				var column:int = i % COLUMN_COUNT;
				item.x = column*item.width + column*HPADDING;
				item.y = row*item.height + row*VPADDING;
				tileSprite.addChild(item);
				
//				item.data
			}			
		}
		
		
		private function onThrewHandler(evt:DragItemEvent):void
		{
			var itemVo:BaseItemVO = evt.dragData as BaseItemVO;
			var color:String = ItemConstant.COLOR_VALUES[itemVo.color];
			Alert.show("你是否确定要丢弃该"+HtmlUtil.font("【"+itemVo.name+"】",color)+"?","警告",desctoryGoods,updateItem);
			function desctoryGoods():void
			{
				
			}
			function updateItem():void
			{
				
			}
		}
		
		
		
		public function setItemVoPrice(pos:int , price:int, priceType:int):void
		{
			var stallItem:StallItem = tileSprite.getChildAt(pos-1) as StallItem;
			var tempData:BaseItemVO = stallItem.baseItemVo;
			tempData.unit_price = price;
			tempData.price_type = priceType;
			clearBtn.enabled = true;
		}
		
		
		public function setDatas(vo:m_stall_open_toc):void
		{
			if(vo.state != 3) //  == 3 未摆摊  其它是已经摆　或　过期
			{
				return;
			}
			//  trace("// 有物品摆出来看。"+ vo.goods.length);
			
			if(vo.goods.length>0)
			{
				delItems();
				clearBtn.enabled = true;
			}else{
				clearBtn.enabled = false;
				delItems();
				return;
			}
			// 有物品摆出来看。
			for(var i:int = 0; i<vo.goods.length ; i++)
			{
				var stallGood:p_stall_goods = vo.goods[i] as p_stall_goods;
				
				var bsItemVo:BaseItemVO = PackageModule.getInstance().getBaseItemVO(stallGood.goods);
				bsItemVo.unit_price = stallGood.price;
				bsItemVo.price_type = stallGood.price_type;
				
				setTileContent(stallGood.pos,null,bsItemVo);
				
				var packItem:BaseItemVO = PackManager.getInstance().getItemById(bsItemVo.oid);
				if(packItem)
					PackManager.getInstance().lockGoods(packItem,true);
			}
			
			
		}
		
		/**
		 * 上次摆摊过期了剩余的物品显示在该摆摊操作的界面上！ 
		 * @param pos　    位置
		 * @param content　GoodsItem
		 * @param vo       baseItemVo
		 * 
		 */	
		//需求改了，　在摆摊界面上显示了！
		
		public function setTileContent(pos:int,content:*,vo:BaseItemVO):void
		{
			if(pos<1)
				return;
			var stallItem:StallItem = tileSprite.getChildAt(pos-1) as StallItem;
			stallItem.updateContent(vo); 
			//stallItem.
		}
		
		private function itemDownHandler(event:MouseEvent):void
		{
			var item:StallItem = event.currentTarget as StallItem;
			if(item.data && !DragItemManager.isDragging()){
				
				DragItemManager.instance.startDragItem(this,item.getContent(),DragConstant.STALL_ITEM,item.data);
			}
		}
		
		public function getGoodsVoById(goods_id:int):BaseItemVO
		{
			for(var i:int = 0; i<tileSprite.numChildren; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				if(item.baseItemVo)
				{
					var bsvo:BaseItemVO = item.baseItemVo;
					if(bsvo.oid == goods_id)
					{
						return bsvo;
					}
				}
			}
			return null;
		}
		
		private function checkHaveGoods():Boolean
		{
			var have_goods:Boolean = false;
			for(var i:int=0; i<tileSprite.numChildren; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				var tempData:BaseItemVO = item.baseItemVo;
				//  trace("...temp...:" + tempData);
				if(tempData)
				{
					goods[goods.length] = tempData;
					
					var good:p_stall_sell_goods = new p_stall_sell_goods();
					good.good_id = tempData.typeId;
					good.silver = tempData.unit_price;//DealConstant.price_arr[i];  //  锭　两　文   1锭=100两   1两=100文
					good.pos = i;                      //位置从　0　开始
					
					have_goods = true;
					
				}
			}
			if(have_goods)
			{
				clearBtn.enabled = true;
			}else{
				clearBtn.enabled = false;
			}
			return have_goods;
		}
		
		public function delItemById(goods_id:int):void
		{
			var item:BaseItemVO = getGoodsVoById(goods_id);
			deleteByItemVo(item);
			
			checkHaveGoods();
		}
		
		private function deleteByItemVo(bsItemVo:BaseItemVO):void
		{
			if(!bsItemVo)
			{
				return;
			}
			for(var i:int = 0; i<tileSprite.numChildren; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				if(item.baseItemVo == bsItemVo)
				{
					setTileContent(i+1,null,null);
					return;
				}
			}
		}
		
		public function sendAllToPackage():void
		{
			//to do   for  tileSprite.numChild  ...
			var childlen:int = tileSprite.numChildren;
			
			for(var i:int; i<childlen; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				var tempData:BaseItemVO = item.baseItemVo;
				
				if(tempData)
				{
					tempData.unit_price = -1;
					tempData.state = 0 ;
					PackManager.getInstance().lockGoods(tempData , false);
					item.disposeContent();
				}
//				tileSprite.removeChild(item);
//				item = null;
				
			}
			
			clearBtn.enabled = false;
				
		}
		
		public function haveItems():Boolean
		{
			var childlen:int = tileSprite.numChildren;
			
			for(var i:int; i<childlen; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				var tempData:BaseItemVO = item.baseItemVo;
				
				if(tempData)
				{
					return true;
				}
			}
			return false;
		}
		
		private function delItems():void
		{
			var num:int = tileSprite.numChildren;
			for(var i:int = 0; i<num; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				
				//				item.removeEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				item.disposeContent();
				setTileContent(i+1,null,null);
				
				
			}
		}
		
		public function deletePackGoods():void
		{
			var childlen:int = tileSprite.numChildren;
			
			for(var i:int; i<childlen; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				var tempData:BaseItemVO = item.baseItemVo;
				
				if(tempData)
				{
//					tempData.unit_price = -1;
					PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,null);
//					PackManager.getInstance().lockGoods(tempData , false);
				}
			}
		}
		
		public function sendToPackage(pos:int):void
		{
			if(pos <= 0 || pos >tileSprite.numChildren)
				return;
			var item:StallItem = tileSprite.getChildAt( pos-1) as StallItem;
			var tempData:BaseItemVO = item.baseItemVo;
			
			if(tempData)
			{
				tempData.unit_price = -1;
//				PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,tempData);
				PackManager.getInstance().lockGoods(tempData , false);
//				item.removeEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				item.disposeContent();
			}
		}
		
		
	}
}


