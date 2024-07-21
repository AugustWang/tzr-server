package modules.broadcast.views
{
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.tile.Hash;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class CountdownView extends UIComponent
	{
		public function CountdownView(){
			this.x=550;
		}
		
		/**
		 * 
		 * @param $chilren
		 *	删除children 
		 */		
		public function removeChildren($chilren:DisplayObject):void{
			var ch:DisplayObject;
			var num:int;
			if($chilren.name == "FactionCountDownView" && $chilren.parent == timeContainer2){
				num = timeContainer2.numChildren;
				for(var i:int=0; i<num; i++){
					ch = timeContainer2.getChildAt(i) as DisplayObject;
					if(ch === $chilren){
						timeContainer2.removeChild(ch);
						//每次增加删除，都要重新排序
						layout();
						return;
					}
				}
			}else{
				num = timeContainer.numChildren;
				for(var j:int=0; j<num; j++){
					ch = timeContainer.getChildAt(j) as DisplayObject;
					if(ch === $chilren){
						timeContainer.removeChild(ch);
						//每次增加删除，都要重新排序
						layout();
						return;
					}
				}
			}
		}
		
		//用来装除了国战外的所有图标
		private var timeContainer:Sprite;
		//用来装国战的图标
		private var timeContainer2:Sprite;
		/**
		 * 
		 * @param $chilren
		 * 增加children
		 */		
		public function addChilren($chilren:DisplayObject):void{
			if($chilren.name == "FactionCountDownView"){
				if(!timeContainer2){
					timeContainer2 = new Sprite();
					timeContainer2.y = 10;
					this.addChild(timeContainer2);
				}
				timeContainer2.addChild($chilren);
			}else{
				if(!timeContainer){
					timeContainer = new Sprite();
					timeContainer.y = 10;
					this.addChild(timeContainer);
				}
				timeContainer.addChild($chilren);
			}
			//每次增加删除，都要重新排序
			layout();
		}
		
		
		private function layout():void{
			//子对象的个数
			var num:int;
			//子对象
			var _ch:DisplayObject;
			if(timeContainer && timeContainer.numChildren > 0){
				//设置timeContainer2的x
				if(timeContainer2 != null){
					timeContainer2.x = 50;
				}
				//上一个child的高
				var lastHeight:int =0;
				//上一个child的y坐标
				var lastY:int=0;
				num = timeContainer.numChildren;
				for(var j:int=0;j<num;j++){
					_ch = timeContainer.getChildAt(j) as DisplayObject;
					_ch.x = timeContainer.x;
					_ch.y = lastY + lastHeight;
					//重新记录一次
					lastY = _ch.y;
					lastHeight = _ch.height;
				}
			}
			if(timeContainer2 && timeContainer2.numChildren > 0){
				//上一个child的高
				var lastHeight2:int =0;
				//上一个child的y坐标
				var lastY2:int=0;
				num = timeContainer2.numChildren;
				 for(var i:int=0; i<num; i++){
					 _ch = timeContainer2.getChildAt(i) as DisplayObject;
					 _ch.x = timeContainer2.x;
					 _ch.y = lastY2 + lastHeight2;
					 //重新记录一次
					 lastY2 = _ch.y;
					 lastHeight2 = _ch.height;
				 }
			}
		}
		
		/**
		 * 显示
		 */
		
		public function show():void
		{
			var num:int = this.numChildren;
			for (var i:int = 0; i < num; i ++) {
				var child:DisplayObject = this.getChildAt(i);
				child.visible = true;
			}
		}
		
		/**
		 * 隐藏
		 */
		
		public function hide():void
		{
			var num:int = this.numChildren;
			for (var i:int = 0; i < num; i ++) {
				var child:DisplayObject = this.getChildAt(i);
				child.visible = false;
			}
		}
	}
}