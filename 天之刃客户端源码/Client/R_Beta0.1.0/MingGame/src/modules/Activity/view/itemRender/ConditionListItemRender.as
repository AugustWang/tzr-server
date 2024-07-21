package modules.Activity.view.itemRender {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.loaders.CommonLocator;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.Text;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.view.SpecialActivityView;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_activity_condition;
	import proto.common.p_activity_prize_goods;

	
	public class ConditionListItemRender extends UIComponent {
		private var btnGetReward:ToggleButton;
		private var txtConditionContent:TextField;
		private var txtPrizeGoodList:TextField;
		private var image:Image;
		private var sp:Sprite;
		private var txt:TextField;
		public function ConditionListItemRender() {
			super();
			initView();
		}
		
		private function initView():void {
			drawLine();
			var tf:TextFormat = new TextFormat("Tahoma", 12, 0xF6F5CD,null,null,null,null,null,"center");
			txtConditionContent = ComponentUtil.createTextField( "", 0, 9, tf, 175, 27, this ); 
	
			
			btnGetReward=ComponentUtil.createToggleButton("", 410, 4, 65, 23, this);
			//specialActivityBtn.selected=true;
			btnGetReward.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				onGetRewardClick();
			});
			
			this.validateNow();
		}
		
		override public function set data(value:Object):void {
			drawLine();
			super.data=value;
			var strGoods:String = new String;
			var vo:p_activity_condition=value as p_activity_condition;
			txtConditionContent.htmlText=vo.condition;
			if(vo.able==1){//未完成
				btnGetReward.enabled=false;
				btnGetReward.label="未完成";
			}
			else if(vo.able==2){//领取
				btnGetReward.enabled=true;
				btnGetReward.label="领取";
			}
			else if(vo.able==3){//已领取
				btnGetReward.enabled=false;
				btnGetReward.label="已领取";
			}
			else if(vo.able==4){//已领取
				btnGetReward.enabled=false;
				btnGetReward.label="不可领";
			}
			this.validateNow();
			showGoods(vo.simple_goods);
		}
		private function onGetRewardClick():void{
			var limit:int = SpecialActivityView.curSpecialActivityLimit;
			if(limit==0){
				yesHandler();	
			}else{
				Alert.show("该活动只能领一次奖励，确认领取？", "提示", yesHandler);
			}
		}
		
		private function yesHandler():void { 
			var ActivityKey:int= SpecialActivityView.curSpecialActivityKey;
			var Condition:p_activity_condition = data as p_activity_condition;
			var ConditionID:int = Condition.condition_id;
			ActivityModule.getInstance().requestGetSpclActReward(ActivityKey,ConditionID);
		}
		
		private var parentContain:Sprite=null;
		private function showGoods(vo:Array):void{
			if(parentContain == null){
				parentContain = new Sprite();
			}else {
				while(parentContain.numChildren > 0){
					var child:UIComponent = parentContain.getChildAt(0) as UIComponent;
					child.removeEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
					child.removeEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
					parentContain.removeChild(child);
				}
			}
			parentContain.x=200;
			parentContain.y=1;
			var len:int = vo.length;
			if(!vo || len == 0)
				return;
			for (var i:int=0; i < len ; i++) {
				var prizeGoods:p_activity_prize_goods=vo[i];
				var rewardBox:UIComponent=new UIComponent;
				rewardBox.x= 35*i;
				rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
				rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
				//var box:Sprite = Style.getViewBg("packItemBg");

				//box.mouseEnabled = false;
				var baseItemVo:BaseItemVO = ItemLocator.getInstance().getObject(prizeGoods.type_id);
				var image:GoodsImage = new GoodsImage();
				//box.addChild(image);
				rewardBox.data = baseItemVo;
				image.x = 2;
				image.y = 2;
				if(prizeGoods.bind != 0){
					if(prizeGoods.bind == 1){//绑定
						baseItemVo.bind = true;
					}else{//非绑定
						baseItemVo.bind = false;
					}
				}
				//物品数量
				var txt:TextField = new TextField;
				if(prizeGoods.num>1)
				{
					var tf:TextFormat = StyleManager.textFormat;
					tf.size = 11;
					txt= ComponentUtil.createTextField(prizeGoods.num+"",0,18,tf,33,NaN,image);
					txt.filters = [new GlowFilter(0x000000,1,2,2,4,1,false,false)];
					txt.selectable = false;		
					txt.autoSize = "right";	
				}
				baseItemVo.num = prizeGoods.num;
				if((baseItemVo is EquipVO)){
					baseItemVo.color = prizeGoods.color;
					EquipVO(baseItemVo).quality = prizeGoods.quality;
				}
				image.setImageContent(baseItemVo, baseItemVo.path);
				image.height=30;
				image.width=30;
				rewardBox.addChild(image);
				parentContain.addChild(rewardBox);
			} 
			addChild(parentContain);
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			var cur_ui:UIComponent = evt.currentTarget as UIComponent;
			var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
			if(baseItemVo){
				ToolTipManager.getInstance().show(baseItemVo,100,0,0,"targetToolTip");
			}
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		override public function dispose():void {
			super.dispose();
			while (this.numChildren > 0) {
				var displayobj:DisplayObject=this.getChildAt(0);
				removeChild(displayobj);
				displayobj=null;
			}
			
		}
		
		private function drawLine():void {
			graphics.lineStyle( 1, 0x577470 );
			graphics.moveTo( 0, 0 );
			graphics.lineTo( 475, 0 );
		}
	}
}