package modules.prestige.views.item{
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.components.GoodsBox;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.TimerButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.prestige.PrestigeModule;
	
	import proto.common.p_prestige_item;

	/**
	 * 兑换子界面
	 *
	 */
	public class PrestigeExchangeItem extends UIComponent {
		
		private var goodsBox:GoodsBox;
		private var titleText:TextField;
		private var descText:TextField;
		private var dealBtn:TimerButton;
		private var baseItemVO:BaseItemVO;
		
		public function PrestigeExchangeItem() {
			super();
			this.initView();

		}
        
		/**
		 * 初始化界面
		 */
		private function initView():void {
			this.width = 165;
			this.height = 90;
            
			bgSkin = Style.getSkin("creditItemBg",GameConfig.CREDIT_UI,new Rectangle(10,10,55,41));
            
			goodsBox = new GoodsBox();
			goodsBox.tipType = GoodsBox.FULL_INFO;
			goodsBox.x = 5;
			goodsBox.y = 25;
			addChild(goodsBox);
			
            var tf:TextFormat = Style.textFormat;
            tf.leading=4;
            tf.color=0xffffff;
            titleText = ComponentUtil.createTextField("", 5, 2, tf, this.width - 6, 20, this);
            titleText.filters=[Style.BLACK_FILTER];
            
            
            tf.align = TextFormatAlign.LEFT;
            descText = ComponentUtil.createTextField("", 45, 25, tf, 115, NaN, this);
            descText.filters=[Style.BLACK_FILTER];
            descText.wordWrap = true;
            descText.multiline = true;
            
            dealBtn = new TimerButton();
			dealBtn.textColor = 0xffff00;
            dealBtn.x = this.width - 55;
            dealBtn.y = this.height - 27;
            dealBtn.width = 50;
            dealBtn.height = 25;
            dealBtn.label = "兑换";
            dealBtn.repeatCount = 1;
			dealBtn.visible = false;
			dealBtn.addEventListener(MouseEvent.CLICK,onDealClickHandler);
            this.addChild(dealBtn);
		}
		
		private function onDealClickHandler(evt:MouseEvent):void {
			Alert.show("你确定是否要兑换"+HtmlUtil.font(baseItemVO.name,ItemConstant.COLOR_VALUES[baseItemVO.color]),"兑换",yesHandler,null);
		}
                
		private function yesHandler():void{
			var vo:p_prestige_item = data as p_prestige_item;
			PrestigeModule.getInstance().dealPrestige(vo.group_id,vo.class_id,vo.key);
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				var vo:p_prestige_item = data as p_prestige_item;
				baseItemVO = ItemConstant.wrapperItemVO(vo.item);
				titleText.htmlText = HtmlUtil.font(baseItemVO.name,ItemConstant.COLOR_VALUES[baseItemVO.color]);
				var html:String = "";
				if(vo.min_level > 0){
					var level:int = GlobalObjectManager.getInstance().user.attr.level;
					var color:int = level >= vo.min_level ? 0x00ff00 : 0xff0000;
					html = "等级要求："+HtmlUtil.font2(vo.min_level+"级",color);
				}
				var prestigeColor:String;
				if(GlobalObjectManager.getInstance().user.attr.cur_prestige >= vo.need_prestige){
					prestigeColor = "#ffff00";
					dealBtn.enabled = true;
				}else{
					dealBtn.enabled = false;
					prestigeColor = "#ff0000";
				}
				html += "\n声望值："+HtmlUtil.font(vo.need_prestige.toString(),prestigeColor)
				descText.htmlText = html;
				goodsBox.baseItemVO = baseItemVO;
				goodsBox.visible = true;
				dealBtn.visible = true;
			}else{
				titleText.htmlText = "";
				descText.htmlText = "";
				dealBtn.visible = false;
				goodsBox.visible = false;
			}
		}
		
	}
}