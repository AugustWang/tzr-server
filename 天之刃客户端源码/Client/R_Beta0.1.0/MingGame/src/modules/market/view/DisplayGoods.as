package modules.market.view
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	
	import flash.display.Bitmap;
	
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class DisplayGoods extends Image
	{
		private var bgColor:Bitmap;
		private var bind:Bitmap;
		
		public function DisplayGoods()
		{
			super();
		}
		
		public function setImageContent(goods:BaseItemVO,content:*):void{
			var equip:EquipVO = goods as EquipVO;
			if(bgColor && bgColor.parent){
				bgColor.parent.removeChild(bgColor);
				bgColor = null;
			}
			if(equip){
				bgColor = new Bitmap();
				bgColor.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"color"+equip.color);
				addChildAt(bgColor,0);
			}
			if(bind && goods && !goods.bind){
				bind.parent.removeChild(bind);
				bind=null
			}
			if(!bind && goods && goods.bind){
				bind = new Bitmap();
				bind.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"suo");
				addChild(bind);
				bind.x = 1;
				bind.y = 18;
			}
			source = content;
		}
		
		override public function set width(value:Number):void{
			super.width = value;
			if(this.bgColor != null){
				this.bgColor.width = value;
			}
		}
		
		override public function set height(value:Number):void{
			super.height = value;
			if(this.bgColor != null){
				this.bgColor.height = value;
			}
			
		}
		
		/**
		 * 当图标没有加载完成时进行拖拽，那时宽度为0就导致拖拽绘制克隆位图时出错。 
		 */		
		override public function get width():Number{
			var w:Number = super.width;
			if(w == 0 || isNaN(w)){
				return 36;
			}
			return w;
		}
		
		override public function get height():Number{
			var h:Number = super.width;
			if(h == 0 || isNaN(h)){
				return 36;
			}
			return h;
		}
	}
}