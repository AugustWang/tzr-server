package modules.mypackage.views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import com.utils.HtmlUtil;

	/**
	 * 用于装提示显示的容器 
	 * @author Administrator
	 * 
	 */	
	public class ToolTipContainer extends Sprite
	{
		public var tipsPool:Array = [];
		public static const MAX_WIDTH:Number = 500;
		public var type:String;
		public function ToolTipContainer()
		{
			mouseChildren = mouseEnabled = false;
		}
		
		public function addToolTips(tipVOs:Array):void{
			width = height = 0
			removeAllChildren();
			var size:int=tipVOs.length;
			for(var i:int=0;i<size;i++){
				var item:ItemToolTip = getToolTip();
				item.useDesc = "";
				item.type = type;
				if(i > 0){
					item.useDesc = HtmlUtil.fontBr(HtmlUtil.bold("当前使用"),"#fffc00",14);
				}
				item.data = tipVOs[i];
				addChild(item);
			}
			layoutChildren();
			var useNewX:Boolean = false;
			if(x + width > stage.stageWidth){
				var count:int = numChildren;
				var startX:Number = 0;
				for(var j:int=count-1;j>=0;j--){
					var child:DisplayObject = getChildAt(j);
					child.x = startX;
					startX += child.width;
				}
				var newX:Number = x - PackageItem.ITEM_SIZE - width;
				if(newX < 0){
					x = 0;
					useNewX = true;
				}else{
					x = newX;
				}
			}
			if(useNewX){
				y += PackageItem.ITEM_SIZE;
				if(y + height+PackageItem.ITEM_SIZE > stage.stageHeight){
					y = Math.max(y - (height+PackageItem.ITEM_SIZE),0);
				}
			}else{
				if(y + height > stage.stageHeight){
					y = Math.max(y - (height - PackageItem.ITEM_SIZE),0);
				}
			}
		}
		
		private function removeAllChildren():void{
			while(numChildren > 0){
				var item:ItemToolTip = removeChildAt(0) as ItemToolTip;
				if(item){
					tipsPool.push(item);
				}
			}
		}
		
		private function layoutChildren():void{
			var size:int = numChildren;
			var tempX:Number=0,tempY:Number=0;
			for(var i:int = 0;i<size;i++){
				var child:DisplayObject = getChildAt(i);
				child.x = tempX;
				if(tempX > MAX_WIDTH){
					child.y = tempY;
				}else{
					child.y = 0;
				}
				tempX += child.width;
				tempY = Math.max(tempY,child.height);
				width = Math.max(tempX,width);
				height = Math.max(child.height,height);
			}
		}
		
		private function getToolTip():ItemToolTip{
			if(tipsPool.length > 0){
				return tipsPool.shift();
			}else{
				return new ItemToolTip();
			}
		}
		
		private var _width:Number=0;
		override public function set width(value:Number):void{
			this._width = value;
		}
		
		override public function get width():Number{
			return  _width;
		}
		
		private var _height:Number=0;
		override public function set height(value:Number):void{
			this._height = value;
		}		
		
		override public function get height():Number{
			return _height;
		}
	}
}