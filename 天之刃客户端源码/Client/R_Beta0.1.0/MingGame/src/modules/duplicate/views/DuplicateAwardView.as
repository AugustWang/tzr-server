package modules.duplicate.views
{
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.duplicate.DuplicateConstant;
	import modules.duplicate.views.vo.DuplicateAwardVO;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_goods;
	
	public class DuplicateAwardView extends BasePanel
	{
		public static const textColor:uint = 0xFFB43C; 
		public static const linkColor:uint = 0xFFB43C;
		public static const hoverColor:uint = 0xFFB43C;
		
		private var headerText:TextField;
		private var fbCountText:TextField;
		private var luckyCountText:TextField;
		private var sumCountText:TextField;
		private var feeText:TextField;
		private var updateBtn:Button;
		private var getRewardBtn:Button;
		
        
		public function DuplicateAwardView()
		{
			super();
			initView();
		}
		
		private function initView():void{
            this.width=275;
            this.height=345;
			
			var bg:UIComponent=new UIComponent();
			bg.x=9;
			bg.width=this.width - 18;
			bg.height=308;
			Style.setBorderSkin(bg);
			addChild(bg);
            
            title = "师门副本传送者";
            
//            this.panelSkin=Style.getInstance().panelSkinNoBg;
//            var npcBg:Sprite=Style.getViewBg("NPCPannel");
//            npcBg.width = this.width - 20;
//            npcBg.height = 300;
//            npcBg.x=10;
//            addChild(npcBg);
            
            var tf:TextFormat = Style.textFormat;
            tf.leading=4;
            tf.color=0xffffff;
            
            this.headerText=ComponentUtil.createTextField("", 23, 10, tf, 216, 22, this);
            this.headerText.filters=[Style.BLACK_FILTER];
            
            headerText.htmlText = "师门副本传送者："
            
			
			fbCountText = ComponentUtil.createTextField("",23,headerText.y + headerText.height,tf,216,22,this);
			luckyCountText = ComponentUtil.createTextField("",23,fbCountText.y + 22,tf,216,22,this);
			sumCountText = ComponentUtil.createTextField("",23,luckyCountText.y + 22,tf,216,22,this);
			
			
			
			
			updateBtn = ComponentUtil.createButton("重置奖励",int(this.width >> 1) -30 ,sumCountText.y + 82 ,60,25,this);
			updateBtn.addEventListener(MouseEvent.CLICK,onUpdate);
			
			feeText = ComponentUtil.createTextField("",23,updateBtn.y + 30,tf,216,NaN,this);
			feeText.multiline =true;
			feeText.wordWrap = true;
			feeText.htmlText = "花费 <font color=\"#3BE450\">2元宝</font> 可以重置奖励，" +
				"最终可获得<font color=\"#FFFF00\">极品灵石</font>！"
			
			
			getRewardBtn = ComponentUtil.createButton("领取奖励",this.width - 95, this.height - 75, 80, 25,this);
			getRewardBtn.addEventListener(MouseEvent.CLICK,onGetReward);
			
			
		}
		private var arr:Array = [];
		private function initViewData():void{
			
			fbCountText.htmlText = "本次副本积分：<font color=\"#ffffff\">" + _awardData.count.toString() + "</font>";
			luckyCountText.htmlText = "当前幸运积分：<font color=\"#ffffff\">" + _awardData.luckyCount.toString() + "</font>";
			sumCountText.htmlText = "总积分：<font color=\""+ _awardData.curAwardColorValue +"\">" + (_awardData.count + _awardData.luckyCount).toString() + 
				"</font>，可以获得以下奖励：";
			
			if(arr.length !=0){
				for(var m:int=0;m<arr.length;m++){
					if(this.contains(arr[m])){
						var currBox:UIComponent = arr[m] as UIComponent;
						this.removeChild(currBox);
						currBox = null;
					}
				}
				arr = [];
			}
			
			var rewardBox:UIComponent;
			var box:Sprite;
			var goodsItem:GoodsItem;
			for(var i:int =0;i<_awardData.awardGoodsArray.length;i++){
				var awardGoods:p_goods = p_goods(_awardData.awardGoodsArray[i]);
				rewardBox = new UIComponent();
				this.addChild(rewardBox);
				rewardBox.width = rewardBox.height = 36;
				rewardBox.x = 23 + i*36+5;
				rewardBox.y =  sumCountText.y + 30;
				rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
				rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
				box = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
				box.mouseEnabled = false;
				var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(awardGoods);
				goodsItem = new GoodsItem(baseItemVo);
				box.addChild(goodsItem);
				rewardBox.data = baseItemVo;
				goodsItem.x = 2;
				goodsItem.y = 2;
				rewardBox.addChild(box);
				arr.push(rewardBox);
			}
			if(_awardData.curAwardNumber < _awardData.maxAwardNumber){//不需要补格子
				for(var n:int = _awardData.curAwardNumber; n < _awardData.maxAwardNumber; n++){
					rewardBox = new UIComponent();
					this.addChild(rewardBox);
					rewardBox.width = rewardBox.height = 30;
					rewardBox.x = 23 + n*36+5;
					rewardBox.y =  sumCountText.y + 30;
					rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
					rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
					box = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
					box.mouseEnabled = false;
					goodsItem = new GoodsItem(null);
					box.addChild(goodsItem);
					goodsItem.x = 2;
					goodsItem.y = 2;
					rewardBox.addChild(box);
					arr.push(rewardBox);
				}
			}
            updateBtn.enabled = true;
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			var cur_ui:UIComponent = evt.currentTarget as UIComponent;
			var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
			if(baseItemVo){
				var p:Point = new Point(this.x + this.width,this.y);
				p = parent.localToGlobal(p);
				ItemToolTip.show(baseItemVo,p.x,p.y,true);
			}
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			ItemToolTip.hide();
		}
		
		
		private function onUpdate(event:MouseEvent):void{
			dispatchEvent(new ParamEvent(DuplicateConstant.AWARD_EVENT,{type:DuplicateConstant.AWARD_EVENT_REFRESH_COUNT,data:_awardData}));
		}
		
		private function onGetReward(event:MouseEvent):void{
			dispatchEvent(new ParamEvent(DuplicateConstant.AWARD_EVENT,{type:DuplicateConstant.AWARD_EVENT_AWARD_GOODS,data:_awardData}));
		}
		private var _awardData:DuplicateAwardVO;
		public function set awardData(data:DuplicateAwardVO):void{
			_awardData = data;
			initViewData();
		}
		public function get awardData():DuplicateAwardVO{
			return _awardData;
		}
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			dispatchEvent(new ParamEvent(DuplicateConstant.AWARD_EVENT,{type:DuplicateConstant.AWARD_EVENT_CLOSE_WIN,data:_awardData}));
		}
	}
}