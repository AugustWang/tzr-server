package modules.market.view {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.common.InputKey;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.KeyUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_goods;
	import proto.line.p_stall_list_item;
	
	public class MarketListItemRenderer extends UIComponent {
		
		private var goodImage:DisplayGoods; //物品的图片
		private var goodName:TextField; //物品的名字
		private var goodPrice:TextField; //物品的价格
		private var goodNum:TextField; //物品的数量
		private var level:TextField; //摊主名字
		private var buyText:TextField; //购买,
		private var leaveMsg:TextField; //留言
		private var sendMsgView:SendMsgView; //留言面板
		private var dataVo:BaseItemVO; //物品数据
		
		public function MarketListItemRenderer() {
			this.height=30;
			goodImage=new DisplayGoods();
			goodImage.y=2;
			this.addChild(goodImage);
			goodImage.addEventListener(MouseEvent.CLICK, onClick);
			goodImage.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler);
			goodImage.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler);
			
			goodName=new TextField();
			goodName.y=5;
			goodName.x=40;
			this.addChild(goodName);
			
			goodPrice=new TextField();
			goodPrice.x=goodName.x + goodName.width + 25;
			goodPrice.y=5;
			this.addChild(goodPrice);
			
			goodNum=new TextField();
			goodNum.x=goodPrice.x + goodPrice.width + 25;
			goodNum.y=5;
			this.addChild(goodNum);
			
			level=new TextField();
			level.x=goodNum.x + goodNum.width + 5;
			level.y=5;
			this.addChild(level);
			
			buyText=new TextField();
			buyText.addEventListener(TextEvent.LINK, onLinkHandler);
			buyText.x=level.x + level.width - 10;
			buyText.y=5;
			buyText.htmlText="<font color='#3be450'><a href ='event:bug'><u>购买</u></a></font>";
			this.addChild(buyText);
			
			leaveMsg=new TextField();
			leaveMsg.addEventListener(TextEvent.LINK, onLinkHandler);
			leaveMsg.name="leaveMsg";
			leaveMsg.x=buyText.x + 30;
			leaveMsg.y=5;
			leaveMsg.htmlText="<font color='#3be450'><a href ='event:leaveMsg'><u>留言</u></a></font>";
			this.addChild(leaveMsg);
			
			var tiao:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			tiao.y=27;
			tiao.width=590;
			addChild(tiao);
			
			addEventListener(Event.ADDED, onAdded);
		}
		
		private function onClick(e:MouseEvent):void {
			var isTildeDown:Boolean=KeyUtil.getInstance().isKeyDown(InputKey.TILDE);
			if (isTildeDown == true && dataVo && dataVo is BaseItemVO) {
//				if (dataVo.typeId == 12300154) { //幻形丹
//					Dispatch.dispatch(ModuleCommand.REQUSET_PET_DETAIL, [dataVo.quality, false]); //特殊处理，拿这个当pet_id
//				}
			}
		}
		
		private var _buywindow:BugView;
		
		private function onMouseRollOutHandler(e:MouseEvent):void {
			ItemToolTip.hide();
		}
		
		private function onMouseRollOverHandler(e:MouseEvent):void {
			if (dataVo != null) {
				var p:Point=new Point(goodImage.x + goodImage.width, goodImage.y);
				p=goodImage.parent.localToGlobal(p);
				ItemToolTip.show(dataVo, p.x, p.y, false);
			}
		}
		
		private function onLinkHandler(e:TextEvent):void {
			var dataItem:p_stall_list_item=super.data as p_stall_list_item;
			//目前玩家的id
			var userID:int=GlobalObjectManager.getInstance().user.base.role_id;
			if (userID != dataItem.role_id) {
				if (e.text == "bug") {
					if (dataVo) {
						dataVo.unit_price=data.price;
						dataVo.price_type=data.price_type;
						if (!_buywindow) {
							_buywindow=new BugView();
							//							_buywindow.x=320;
							//							_buywindow.y=100;
						}
						//						LayerManager.alertLayer.alert(_buywindow);
						WindowManager.getInstance().popUpWindow(_buywindow);
						WindowManager.getInstance().centerWindow(_buywindow);
						_buywindow.setGoodsVo(data.role_id, goodPrice.text, dataVo);
					}
				} else if (e.text == "leaveMsg") {
					if (sendMsgView == null) {
						sendMsgView=new SendMsgView();
						sendMsgView.x=int((GlobalObjectManager.GAME_WIDTH - sendMsgView.width) / 2);
						sendMsgView.y=int((GlobalObjectManager.GAME_HEIGHT - sendMsgView.height) / 2);
					}
					WindowManager.getInstance().openDialog(sendMsgView,false);
					sendMsgView.ownerID=dataItem;
				}
			} else {
				Tips.getInstance().addTipsMsg("不能对自己的摆放的商品进行任何操作");
			}
		}
		
		private function onAdded(event:Event):void {
			width=parent.width;
			height=28;
		}
		
		public override function set data(value:Object):void {
			if (value != null) {
				var data:p_stall_list_item=value as p_stall_list_item;
				super.data=data;
				
				dataVo=ItemLocator.getInstance().getObject(int(data.goods_detail.typeid)) as BaseItemVO;
				dataVo.copy(data.goods_detail);
				
				var path:String=dataVo.path;
				goodImage.setImageContent(dataVo, path);
				goodImage.height=27;
				goodImage.width=27;
				
				var color:String=ItemConstant.COLOR_VALUES[data.goods_detail.current_colour];
				
				goodName.htmlText="<font color='" + color + "'>" + data.goods_detail.name + "</font>";
				
				if (data.price_type == DealConstant.STALL_PRICE_TYPE_SILVER) {
					goodPrice.htmlText="<font color='#AFE1EC'>" + DealConstant.silverToOtherString(data.price) + "</font>";
				} else if (data.price_type == DealConstant.STALL_PRCIE_TYPE_GOLD) {
					goodPrice.htmlText="<font color='#AFE1EC'>" + data.price + "元宝</font>";
				}
				
				goodNum.htmlText="<font color='#AFE1EC'>" + data.goods_detail.current_num + "</font>";
				
				level.htmlText="<font color='#AFE1EC'>" + data.goods_detail.level + "</font>";
			}
		}
	}
}