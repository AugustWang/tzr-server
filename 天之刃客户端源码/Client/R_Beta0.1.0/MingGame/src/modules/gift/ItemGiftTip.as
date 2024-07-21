package modules.gift {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;

    /**
     * 领取道具奖励提示界面
     * @author caochuncheng
     * 
     */    
	public class ItemGiftTip extends Sprite {
        
        private var titleText:TextField;
        private var contentText:TextField;
        private var closeButton:UIComponent;
        private var rewardBox:UIComponent;
        private var goodsImage:GoodsImage;
        private var awardBtn:Button;
        
		public function ItemGiftTip() {
            addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"itemgiftbg"));
            
            var tf:TextFormat = Style.textFormat;
            tf.leading=4;
            tf.align = TextFormatAlign.CENTER;
            titleText = ComponentUtil.createTextField("",30,10,tf,this.width - 60,25,this);
            titleText.wordWrap = false;
            titleText.multiline = false;
            titleText.htmlText = "";
            titleText.filters=[Style.BLACK_FILTER];
            
            
            rewardBox = new UIComponent();
            this.addChild(rewardBox);
            rewardBox.width = rewardBox.height = 36;
            rewardBox.x = int(this.width >> 1) - 18;
            rewardBox.y =  int(this.height >> 1) - 36;
            rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
            rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
            var box:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
            rewardBox.addChild(box);
            box.mouseEnabled = true;
            goodsImage = new GoodsImage();
            box.addChild(goodsImage);
			goodsImage.x = 4;
			goodsImage.y = 4;
            
            
            contentText = ComponentUtil.createTextField("",5,rewardBox.y + rewardBox.height + 5,tf,this.width - 10,NaN,this);
            contentText.wordWrap = true;
            contentText.multiline = true;
            contentText.htmlText = "";
            contentText.filters=[Style.BLACK_FILTER];
            
            closeButton = new UIComponent();
			closeButton.buttonMode=true;
            closeButton.addEventListener(MouseEvent.CLICK,onCloseHandler);
            closeButton.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
            closeButton.x = this.width - closeButton.width - 30;
            closeButton.y = 12;
            addChild(closeButton);
            
            awardBtn = ComponentUtil.createButton("领取奖励", 88, 105, 76, 25,this);
            awardBtn.addEventListener(MouseEvent.CLICK, onAwardItemGift);
		}
        private function onRollOverHandler(evt:MouseEvent):void{
            var cur_ui:UIComponent = evt.currentTarget as UIComponent;
            var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
            if(baseItemVo){
				var baseItemX:Number=this.x + rewardBox.x+50;//this.x + rewardBox.x;
				var baseItemY:Number=this.y -50;//this.y + rewardBox.y + rewardBox.height;
                ItemToolTip.show(baseItemVo,baseItemX,baseItemY,true);
            }
        }
        private function onRollOutHandler(evt:MouseEvent):void{
            ItemToolTip.hide();
        }
        
        private var _tipData:Object;
        public function set tipData(value:Object):void{
            this._tipData = value;
            var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(this._tipData.goods);
            rewardBox.data = baseItemVo;
            goodsImage.setImageContent(baseItemVo, baseItemVo.path);
            if(GlobalObjectManager.getInstance().user.attr.level >= this._tipData.role_level){
                contentText.htmlText = String(this._tipData.role_level) + " 级即可领取" ;
                this.awardBtn.enabled = true;
				this.awardBtn.label = '领取奖励';
            }else{
                contentText.htmlText = "<font color=\"#F53F3C\">" + String(this._tipData.role_level) + " 级即可领取</font>" ;
				this.awardBtn.label = '稍后再来';
            }
            var color:String = ItemConstant.COLOR_VALUES[baseItemVo.color];
            titleText.htmlText = HtmlUtil.fontBr(HtmlUtil.bold(baseItemVo.name),color,14);
        }
        
        private function onCloseHandler(event:MouseEvent):void{			
            Dispatch.dispatch(ModuleCommand.GIFT_ITEM_TIP_CLOSE); 			
        }
        private function onAwardItemGift(evt:MouseEvent):void{
			if(GlobalObjectManager.getInstance().user.attr.level >= this._tipData.role_level){
	            if(this._tipData){
	                var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(this._tipData.goods);
	                if(GlobalObjectManager.getInstance().user.attr.level >= this._tipData.role_level){
	                    Dispatch.dispatch(ModuleCommand.GIFT_ITEM_AWARD,baseItemVo);
	                }else{
	                    Tips.getInstance().addTipsMsg("你的等级不够哦，赶快升到" + String(this._tipData.role_level) + "级吧");
	                }
	            }
			} else {
				onCloseHandler(evt);
			}
        }
        
	}
}