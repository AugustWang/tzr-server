package modules.gift {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.BaseToolTip;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;

    /**
     * 道具礼包显示界面
     * @author caochuncheng
     * 
     */    
	public class ItemGiftPanel extends UIComponent {
        public static var ITEM_GIFT_WIDTH:int = 38;
        public static var ITEM_GIFT_HEIGHT:int = 38;
		public function ItemGiftPanel() {
			super();
            this.initView();
		}
        private var rewardBox:UIComponent;
        private var goodsImage:GoodsImage;
        private var _rewardThing:Thing;
        /**
         * 初始化界面
         */
        private function initView():void {
            this.buttonMode = true;
            this.x = GlobalObjectManager.GAME_WIDTH - 250;
            this.y = 104;
            //背景
            var blueBg:Sprite = Style.getBlackSprite(ITEM_GIFT_WIDTH,ITEM_GIFT_HEIGHT,3);
            this.addChild(blueBg); 
            rewardBox = new UIComponent();
            this.addChild(rewardBox);
            rewardBox.width = rewardBox.height = 36;
            rewardBox.x = 1;
            rewardBox.y =  1;
            rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
            rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
            rewardBox.addEventListener(MouseEvent.CLICK,onMouseClick);
            var box:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
            rewardBox.addChild(box);
            box.mouseEnabled = true;
            goodsImage = new GoodsImage();
            box.addChild(goodsImage);
			goodsImage.x = 4;
			goodsImage.y = 4;
            
            _rewardThing = new Thing();
            _rewardThing.load(GameConfig.OTHER_PATH + 'skillSelect.swf');
            _rewardThing.x = -12;
            _rewardThing.y = -12;
            this.addChild(_rewardThing);
            _rewardThing.play(5,true);
        }
        /**
         * 停止闪动效果
         */        
        public function stopRewardThing():void{
            if(_rewardThing != null){
                _rewardThing.stop();
                if(_rewardThing.parent)removeChild(_rewardThing);
            }
        }
        
        private var _giftData:Object;
        public function set giftGoods(value:Object):void{
            this._giftData = value;
            var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(this._giftData.goods);
            rewardBox.data = baseItemVo;
            goodsImage.setImageContent(baseItemVo, baseItemVo.path);
        }
        
        private function onRollOverHandler(evt:MouseEvent):void{
            var cur_ui:UIComponent = evt.currentTarget as UIComponent;
            var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
            if (GlobalObjectManager.getInstance().user.attr.level >= this._giftData.role_level){
                ToolTipManager.getInstance().show("" + String(this._giftData.role_level) + " 级点击领取！",0,this.x,this.y);
            }else{
                ToolTipManager.getInstance().show("<font color=\"#F53F3C\">" + String(this._giftData.role_level) + "</font> 级点击领取！",0,this.x,this.y);
            }
			var toolTipObj:BaseToolTip = ToolTipManager.getInstance().getTip("defaultTip");
			toolTipObj.x = this.x - toolTipObj.width - 1;
			toolTipObj.y = this.y+25;//+50了
            if(baseItemVo){
                ItemToolTip.show(baseItemVo,this.x,this.y,true);
				ItemToolTip.tips.y = this.y -105;//this.y + toolTipObj.height + 1;
				ItemToolTip.tips.x = this.x - ItemToolTip.tips.width - 50;//this.x - ItemToolTip.tips.width - 1;
            }
        }
        private function onRollOutHandler(evt:MouseEvent):void{
            ItemToolTip.hide();
            ToolTipManager.getInstance().hide();
        }
        private function onMouseClick(evt:MouseEvent):void{
            var cur_ui:UIComponent = evt.currentTarget as UIComponent;
            var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
            Dispatch.dispatch(ModuleCommand.GIFT_ITEM_TIP_SHOW,this._giftData);
//            if(GlobalObjectManager.getInstance().user.attr.level >= this._giftData.role_level){
//                Dispatch.dispatch(ModuleCommand.GIFT_ITEM_AWARD,baseItemVo);
//            }else{
//                Tips.getInstance().addTipsMsg("你的等级不够哦，赶快升到" + String(this._giftData.role_level) + "级吧");
//            }
           
        }
	}
}