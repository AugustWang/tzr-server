package modules.deal.views {
	import com.common.GameColors;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.TimerButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.deal.NpcDealModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	/**
	 * 兑换子界面
	 * @author caochuncheng2002@gmail.com
	 *
	 */
	public class NpcDealItem extends UIComponent {
        public static var DEAL_ITEM_WIDTH:int = 165;
        public static var DEAL_ITEM_HEIGHT:int = 90;
		
		private var useGoodID:String;
		private var useNum:int=0;
		private var exchangeViewData:Object={};//传值给批量处理视图，交易项目id，图片物品ID，标题字符。
		public var haveItemInfo:Array = null;
		public function NpcDealItem() {
			super();
			this.initView();

		}
        private var titleText:TextField;
        private var descText:TextField;
        private var line:Sprite;
        private var dealBtn:TimerButton;
        
		/**
		 * 初始化界面
		 */
		private function initView():void {
			this.width = DEAL_ITEM_WIDTH;
			this.height = DEAL_ITEM_HEIGHT;
            
			Style.setItemBgSkin(this);
            
            var tf:TextFormat = Style.textFormat;
            tf.leading=4;
            tf.color=0xffffff;
            tf.align = TextFormatAlign.CENTER;
            titleText = ComponentUtil.createTextField("", 1, 2, tf, this.width - 6, 20, this);
            titleText.filters=[Style.BLACK_FILTER];
            
            
            line=ComponentUtil.drawDubbleLine(this.width - 4, 0x426e75, 0x213e46, this, 2,titleText.y + titleText.height);
            
            tf.align = TextFormatAlign.LEFT;
            descText = ComponentUtil.createTextField("", 42, 30, tf, 115, NaN, this);
            descText.filters=[Style.BLACK_FILTER];
            descText.wordWrap = true;
            descText.multiline = true;
            
            dealBtn = new TimerButton();
            dealBtn.x = this.width - 65;
            dealBtn.y = this.height - 27;
            dealBtn.width = 60;
            dealBtn.height = 25;
            Style.setRedBtnStyle(dealBtn);
            dealBtn.label = "兑换";
            dealBtn.repeatCount = 1;
			Style.setRedBtnStyle(dealBtn);
			dealBtn.addEventListener(MouseEvent.CLICK,onDealClickHandler);
            this.addChild(dealBtn);
		}
        /**
         * 兑换处理 
         * @param evt
         * 
         */   
		private function getMaxChange(goodsID:String,useNum:int):int
		{
			var goodsValue:int = 0;
			for each(var item:String in haveItemInfo)
			{
				var tempMsg:Array = item.split("|");
				
				if(tempMsg[2] == goodsID||tempMsg[0]==goodsID)
				{
					goodsValue = tempMsg[1];
					break;
				}
				
			}
			return goodsValue/useNum;
		}
		
		private function onDealClickHandler(evt:MouseEvent):void 
		{
			this.exchangeViewData.MaxChangeNum = getMaxChange(useGoodID,useNum);
			NpcDealBatchView.getInstance().data=this.exchangeViewData;
			NpcDealBatchView.getInstance().showView();

		}
        private function doneNpcDeal(opType:int):void{
            if(this._dealItemData != null && opType == 1){
                Dispatch.dispatch(ModuleCommand.EXCHANGE_NPC_DEAL, _dealItemData);
            }
        }
        private var _dealItemData:Object;
        public function set dealItemData(value:Object):void{
            this._dealItemData = value;
				exchangeViewData.dealType=value.dealType;
				exchangeViewData.id=value.id;
				exchangeViewData.limitNum=value.limitNum;
			if(_dealItemData.dealType==1||_dealItemData.dealType==3){
				exchangeViewData.imgId=value.awardItemArr[0].id;//获取图片id数组。
			}else if(_dealItemData.dealType==2){
				exchangeViewData.imgId=value.needItemArr[0].id;
			}
			
			if(_dealItemData.awardItemArr != null && _dealItemData.awardItemArr.length > 0)
			{
				var rewardBox:UIComponent;
				for(var i:int =0;i<_dealItemData.awardItemArr.length;i++){
					var awardItemObj:Object = _dealItemData.awardItemArr[i];
					
					rewardBox = new UIComponent();
					this.addChild(rewardBox);
					rewardBox.width = rewardBox.height = 36;
					rewardBox.x = 2 + i*36+5;
					rewardBox.y =  line.y + line.height + 2;
					rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
					rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
					var box:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
					box.mouseEnabled = false;
					var baseItemVo:BaseItemVO = ItemLocator.getInstance().getObject(awardItemObj.id);
					
					if(i == 0){
						
						this.titleText.htmlText = "<font color=\"" + GameColors.getHtmlColorByIndex(baseItemVo.color) + "\">" + baseItemVo.name+ "</font>";
						exchangeViewData.title=this.titleText.htmlText;
					}
					var image:GoodsImage = new GoodsImage();
					box.addChild(image);
					rewardBox.data = baseItemVo;
					image.x = 2;
					image.y = 2;
					baseItemVo.bind = false;
					if(awardItemObj.bind == 1){
						baseItemVo.bind = true;
					}
					if(!(baseItemVo is EquipVO)){
						var numTxt:TextField = ComponentUtil.createTextField(awardItemObj.number.toString(),18,18,new TextFormat(null,11,0xfffffff,null,null,null,null,null,TextFormatAlign.CENTER),20,20,box);
					}else{
						baseItemVo.color = awardItemObj.color;
						EquipVO(baseItemVo).quality = awardItemObj.quality;
					}
					
					image.setImageContent(baseItemVo, baseItemVo.path);
					rewardBox.addChild(box);
				}
				if(_dealItemData.needItemArr != null && _dealItemData.needItemArr.length > 0){
					var needItemObj:Object =  _dealItemData.needItemArr[0];
					var needItemVo:BaseItemVO;
					if(needItemObj!=null&&int(needItemObj.id)!=0)
					{
					 	needItemVo = ItemLocator.getInstance().getObject(needItemObj.id);
						this.descText.htmlText = "<font color=\"#AFE1EC\">消耗【" + 　needItemVo.name + "】×" + String(needItemObj.number) + "</font>";
						useGoodID = needItemObj.id;
					}
					else
					{
						this.descText.htmlText = "<font color=\"#AFE1EC\">消耗" + 　needItemObj.name  + String(needItemObj.number) +needItemObj.unit+ "</font>";
						useGoodID = needItemObj.name;
					}
					useNum = needItemObj.number;
				}				
			}
			else if(_dealItemData.needItemArr != null && _dealItemData.needItemArr.length > 0){
				var needObj:Object =  _dealItemData.needItemArr[0];
				var needVo:BaseItemVO = ItemLocator.getInstance().getObject(needObj.id);
				this.titleText.htmlText = "使用<font color=\"" + GameColors.getHtmlColorByIndex(needVo.color) + "\">【" + 　needVo.name + "】×" + String(needObj.number)+ "</font>";
				exchangeViewData.title="使用<font color=\"" + GameColors.getHtmlColorByIndex(needVo.color) + "\">【" + 　needVo.name + "】</font>";
				this.descText.x = 3;
				this.descText.y = line.y + line.height + 2;
				this.descText.width = this.width - 6;
				var descStr:String =  "<font color=\"#AFE1EC\">兑换：";
				if(_dealItemData.exp != 0){
					descStr = descStr + "<font color=\"#FFFF00\">"+ String(_dealItemData.exp) + "</font> 经验\n"
				}
				if(_dealItemData.family_money != 0){
					descStr = descStr + "         <font color=\"#FFFF00\">"+ String(_dealItemData.family_money) + "</font> 文门派资金"
				}
				this.descText.htmlText = descStr + "</font>";
				useGoodID = needObj.id
				useNum = 1;
			}							
		}
			
            
                
     
        private function onRollOverHandler(evt:MouseEvent):void{
            var cur_ui:UIComponent = evt.currentTarget as UIComponent;
            var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
            if(baseItemVo){
                ToolTipManager.getInstance().show(baseItemVo,500,0,0,"targetToolTip");
            }
        }
        private function onRollOutHandler(evt:MouseEvent):void{
            ToolTipManager.getInstance().hide();
        }
	}
}