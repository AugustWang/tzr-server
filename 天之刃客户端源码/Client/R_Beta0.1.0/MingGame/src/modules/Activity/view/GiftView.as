package modules.Activity.view {
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import modules.Activity.activityManager.ActAwardLocator;
	import modules.Activity.view.itemRender.GiftRender;
	
	import proto.line.m_activity_pay_gift_info_toc;

	public class GiftView extends UIComponent {
		private var canvas:Canvas;
//		public var dynamicRender:GiftRender;
		//存放小窗口的的数组
		private var giftRenderArray:Array;
		
		public function GiftView() {
			super();
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}
		
		private var inited:Boolean = false;
		private function addToStageHandler(event:Event):void{
			createItemRender();	
			removeEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}

		private function createItemRender():void {
			var pointArray:Array=[new Point(8, 9), new Point(325, 9), new Point(8, 185), new Point(325, 185)];
			giftRenderArray = new Array();
			
			for (var i:int=0; i < 4; i++) {
				var giftRender:GiftRender=new GiftRender();
				giftRender.x=pointArray[i].x;
				giftRender.y=pointArray[i].y;
				addChild(giftRender);
				giftRenderArray.push(giftRender);
			}
		}
		
		public function updateData(vo:m_activity_pay_gift_info_toc):void
		{
			var type1:Object = new Object();
			type1.type = 1;
			type1.receiver = vo.has_get_pay_first_gift;
			type1.data = vo.pay_first_goods_list;
			(giftRenderArray[0] as GiftRender).data = type1;
			
			var type2:Object = new Object();
			type2.type = 2;
			type2.receiver = false;
			type2.data = vo.happy_gift_goods_list;
			(giftRenderArray[1] as GiftRender).data = type2;
			
			var type3:Object = new Object();
			type3.type = 3;
			type3.receiver = vo.has_get_accumulate_pay_gift;
			var array:Array = [];
			vo.accumulate_pay_goods_info.id = 9999;
			array.push(vo.accumulate_pay_goods_info);
			type3.data = array;
			(giftRenderArray[2] as GiftRender).data = type3;
			
			var type4:Object = new Object();
			type4.type=4;
			(giftRenderArray[3] as GiftRender).data = type4;
		}
	}
}