package modules.reward.view.items
{
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.reward.view.RewardWindow;
	
	import proto.common.p_goods;
	import proto.line.p_level_gift_info;
	
	public class RewardItemRender extends UIComponent implements IDataRenderer
	{
		private var box:Sprite;
		public function RewardItemRender()
		{
			super();
			box = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			this.addChild(box);
			
			this.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
		}
		
		private function onRollOverHandler(evt:MouseEvent):void{
			if(data){
				var point:Point = new Point(this.x,this.y);
				point = this.parent.localToGlobal(point);
				ToolTipManager.getInstance().show(data,50,0,0,"targetToolTip");
			}
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		override public function get data():Object{
			return super.data;
		}
		
		private var arr:Array = [];
		override public function set data(value:Object):void{
			var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(p_goods(value));
			super.data = baseItemVo;
			var image:GoodsImage = new GoodsImage();
			box.addChild(image);
			image.x = 8;
			image.y = 7;
			image.setImageContent(baseItemVo,baseItemVo.path);
			arr.push(image);
			
			var tf:TextFormat = new TextFormat();
			tf.color = 0xffffff;
			tf.align = TextFormatAlign.CENTER;
			var numTxt:TextField = ComponentUtil.createTextField(baseItemVo.num.toString(),23,25,tf,20,20,box);
			arr.push(numTxt);
		}
		
		public function clear():void{
			if(arr.length != 0){
				for each(var i:DisplayObject in arr){
					box.removeChild(i);
				}
				arr.length = 0;
			}
		}
	}
}