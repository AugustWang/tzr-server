package modules.help {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
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
	import modules.playerGuide.TipsView;

	/**
	 * 比较通用的新手引导弹窗提示，具有道具提示功能
	 */	   
	public class HelpTipItem extends Sprite {
        
        private var titleText:TextField;
        private var contentText:TextField;
        private var closeButton:UIComponent;
        private var rewardBox:UIComponent;
        private var goodsImage:GoodsImage;
        private var awardBtn:Button;
		private var tips:TipsView;
		
		public var callBack:Function;
		public var btnLabel:String="";
        
		public function HelpTipItem() {
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"itemgiftbg"));
            
            var tf:TextFormat = Style.textFormat;
            tf.leading=4;
            tf.align = TextFormatAlign.CENTER;
            titleText = ComponentUtil.createTextField("",30,10,tf,this.width - 60,25,this);
            titleText.wordWrap = false;
            titleText.multiline = false;
            titleText.htmlText = "";
            titleText.filters=[Style.BLACK_FILTER];
			
			tips = new TipsView();
            
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
            goodsImage.x = 2;
            goodsImage.y = 2;
            
            
            contentText = ComponentUtil.createTextField("",5,rewardBox.y + rewardBox.height + 5,tf,this.width - 10,NaN,this);
            contentText.wordWrap = true;
            contentText.multiline = true;
            contentText.htmlText = "";
            contentText.filters=[Style.BLACK_FILTER];
            
            awardBtn = ComponentUtil.createButton("", 88, 105, 76, 25,this);
			awardBtn.addEventListener(MouseEvent.CLICK, doBtnCallback);
		}
        private function onRollOverHandler(evt:MouseEvent):void{
            var cur_ui:UIComponent = evt.currentTarget as UIComponent;
            var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
            if(baseItemVo){
                ItemToolTip.show(baseItemVo,this.x + rewardBox.x,this.y + rewardBox.y + rewardBox.height,true);
            }
        }
        private function onRollOutHandler(evt:MouseEvent):void{
            ItemToolTip.hide();
        }

		public function show( baseItemVo:BaseItemVO, txtComment:String,txtTip:String ):void {
			awardBtn.label = btnLabel;
			rewardBox.data=baseItemVo;
			goodsImage.setImageContent( baseItemVo, baseItemVo.path );

			contentText.htmlText=txtComment;
			this.awardBtn.enabled=true;

			var color:String=ItemConstant.COLOR_VALUES[ baseItemVo.color ];
			titleText.htmlText=HtmlUtil.fontBr( HtmlUtil.bold( baseItemVo.name ), color, 14 );
			
			x = (GlobalObjectManager.GAME_WIDTH - this.width) / 2;
			y = (GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			
			tips.show( txtTip,TipsView.LEFT);
			tips.x = awardBtn.x + awardBtn.width*2;
			tips.y = awardBtn.y;
			addChild(tips);
			
			WindowManager.getInstance().openDialog(this,false);
		}

		private function onCloseHandler( event:MouseEvent ):void {
			if ( parent ) {
				parent.removeChild( this );
			}
		}

		private function doBtnCallback( e:Event ):void {
			if ( callBack != null ) {
				callBack.call();
			}
			WindowManager.getInstance().closeDialog(this);
		}
        
	}
}