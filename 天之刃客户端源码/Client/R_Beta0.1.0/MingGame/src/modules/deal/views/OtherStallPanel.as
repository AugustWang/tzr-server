package modules.deal.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.deal.DealModule;
	import modules.deal.views.stallViews.StallItem;
	import modules.deal.views.stallViews.StallList;
	import modules.market.MarketModule;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_stall_buy_toc;
	import proto.line.m_stall_chat_toc;
	import proto.line.m_stall_detail_toc;
	import proto.line.p_stall_goods;
	
	public class OtherStallPanel extends BasePanel
	{
		// 打开其它人的摊位面板
		public static const COUNT:int = 30;
		public static const COLUMN_COUNT:int = 6;
		public static const HPADDING:int = 2;
		public static const VPADDING:int = 2;
		
		private var tileSprite:Sprite;
		
		private var searchNear:Button;     // 搜索附近摊位  
		
		private var stallNameTxt:TextField; 
		
		private var ownerText:TextField;   //摊主：名字
		
		private var ownerId:int;           //摊位主的 id
		
		private var chatList:StallList;    //显示留言　和　购买信息
		
		private var input:TextInput;
		private var sendBtn:Button;
		
		private var content:String;
		
		private var bsItemVo:BaseItemVO;  //暂时保存购买时的物品
		private var pos:int;              //物品更新时要的位置，
		
		public function OtherStallPanel()
		{
			super();
			
			title = "摆  摊";
			this.width = 433;//468;
			this.height = 304;//362;
			
			initView();
		}
		
		private function initView():void
		{
			
//			title = "骑着驴的帅哥的摊位";
			
			var backBg:UIComponent = ComponentUtil.createUIComponent(10,5,236,228); 
			Style.setBorder1Skin(backBg);
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			var infoBg:UIComponent = ComponentUtil.createUIComponent(252,5,168,228); 
			Style.setBorder1Skin(infoBg);
			infoBg.mouseEnabled = false;
			addChild(infoBg);
			
			var inputbg:UIComponent = new UIComponent();
			inputbg.x = 16;
			inputbg.y = 11;
			inputbg.width = 220;
			inputbg.height = 23;
			inputbg.bgSkin = Style.getInstance().textInputSkin;
			addChild(inputbg);
			
			stallNameTxt = ComponentUtil.createTextField("骑着驴的帅哥的摊位",20,13,null,218,22,this); //// new TextField();
			
			
			tileSprite = new Sprite();
			tileSprite.x = 13;
			tileSprite.y = 40;
			addChild(tileSprite);
			
			searchNear = ComponentUtil.createButton("打开市场界面",158,240,110,23,this); // new Button();
			
			searchNear.addEventListener(MouseEvent.CLICK, onRequestSearch);
			
			createItems();
			
			var txtformat:TextFormat = new TextFormat("宋体",12,0x0e90ff);
			ownerText = ComponentUtil.createTextField("摊主：",257,12,txtformat,157,24,this);
			ownerText.border = true;
			ownerText.borderColor = 0xffc1c1;
			
			chatList = new StallList();
			chatList.x = 256;
			chatList.y = 47;
			addChild(chatList);
			
			// for test 
			//test();
			
			input = new TextInput();
			input.x = 253;
			input.y = 207;// 242;
			input.width = 115;
			input.maxChars = 30;
			
			input.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addChild(input);
			
			sendBtn = ComponentUtil.createButton("发送",368,207,50,22,this);
			Style.setRedBtnStyle(sendBtn);
			sendBtn.addEventListener(MouseEvent.CLICK, onSendHandler);
			
		}
		
		private function keyUpHandler(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ENTER)
			{
				sendMsg();
			}
		}
		
		private function onSendHandler(e:MouseEvent):void
		{
			sendMsg();
		}
		
		private function sendMsg():void
		{
			if(!input.text||input.text == "")
			{
				return;
			}
			
			content = input.text;
			DealModule.getInstance().sendMsg(ownerId,content);
			
			input.text = "";
		}
		
		public function receiveMsg(vo:m_stall_chat_toc):void
		{
			if(vo.return_self)
			{
//				var date:Date = new Date();
//				var time:String =DateUtil.getHMBysecond(date.getTime()/1000);
				vo.src_role_id = GlobalObjectManager.getInstance().user.base.role_id;
				vo.src_role_name = GlobalObjectManager.getInstance().user.base.role_name;
				vo.content = content;
//				vo.time = 
			}
			
			chatList.appendMsg(vo,false);
		}
		
		public function receiveBuyMsg(vo:m_stall_buy_toc):void
		{
			if(!vo)
				return;
			
			chatList.appendMsg( vo, true);
			bsItemVo.num = bsItemVo.num - vo.num;
			if(bsItemVo.num == 0)
			{
				setTileContent(pos, null, null);
			}
			else if(bsItemVo.num > 0)
			{
				setTileContent(pos, null, bsItemVo);
			}
		}
		
		
		private function onRequestSearch(evt:MouseEvent):void
		{
//			DealModel.getInstance().requestSearch(1);//openSearchPanel(); 暂时未做处理， 服务端弄成收摊了！
			MarketModule.getInstance().openMarketView();
		}
		
		
		private function createItems():void
		{
			for(var i:int=0;i<COUNT;i++){
				var item:StallItem = new StallItem();   // 
				item.isOtherStall = true;
				item.index = i;
				item.addEventListener(ItemEvent.ITEM_CLICK,itemClickHandler);
				//				item.doubleClickEnabled = true;
				//				item.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);				
				var row:int = i / COLUMN_COUNT;
				var column:int = i % COLUMN_COUNT;
				item.x = column*item.width + column*HPADDING;
				item.y = row*item.height + row*VPADDING;
				tileSprite.addChild(item);
			}			
		}
		
		
		private function itemClickHandler(evt:ItemEvent):void
		{
			//to do 弹出购买面板！
			var item:StallItem = evt.target as StallItem;
			bsItemVo = item.baseItemVo;
			pos = item.index + 1;
			
			DealModule.getInstance().openBuyWindow(ownerId,pos, bsItemVo);
		}
		
		
		/**
		 * 界面数据赋值！ 
		 * @param vo
		 * 
		 */		
		public function setDatas(vo:m_stall_detail_toc):void
		{
			if(!vo)
				return;
			
//			
			setTitle(vo.name);
			setOwner(vo.role_name);
			ownerId = vo.role_id;
			
			delItems();
			
			for(var i:int = 0; i<vo.goods.length ; i++)
			{
				var stallGood:p_stall_goods = vo.goods[i] as p_stall_goods;
				
				var bsItemVo:BaseItemVO = PackageModule.getInstance().getBaseItemVO(stallGood.goods);
				
				bsItemVo.unit_price = stallGood.price;
				bsItemVo.price_type = stallGood.price_type;
				setTileContent(stallGood.pos,null,bsItemVo);
			}
			
			if(vo.buy_logs.length>0 || vo.chat_logs.length>0)
				chatList.clearArr();
			if(vo.buy_logs.length>0)
				chatList.stall_log(vo.buy_logs,true);
			if(vo.chat_logs.length>0)
				chatList.stall_log(vo.chat_logs,false);
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
		
		
		/**
		 * 改变格子里的物品内容 
		 * @param pos
		 * @param content
		 * @param vo
		 * 
		 */		
		public function setTileContent(pos:int,content:*,vo:BaseItemVO):void
		{
			var stallItem:StallItem = tileSprite.getChildAt(pos-1) as StallItem;
			//stallItem.setContent(content,vo);
			stallItem.updateContent(vo);
		}
		
		private function setTitle(str:String):void
		{
			stallNameTxt.text = str;
			//title = str;
		}
		
		
		
		private function setOwner(ownerName:String):void
		{
			ownerText.text = "摊主：" + ownerName;
		}
		
		public function getRoleId():int
		{
			return ownerId;
		}
	}
}

