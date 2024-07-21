package modules.pet.view
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import modules.mypackage.vo.BaseItemVO;

	public class GoodsListTip extends UIComponent
	{
		private var tip:GoodsToolTipView;//提示信息显示视图
		private var ui:UIComponent;//父级容器
		private var posX:int;
		private var posY:int;
		private var s:Stage;
		private static var _instance:GoodsListTip;
		public function GoodsListTip()
		{
			super();
			initView();
		}
		public static function getInstance():GoodsListTip{
			if(_instance==null){
				_instance=new GoodsListTip();
			}
			return _instance;
		}
		private function initView():void{
			this.bgSkin=Style.getInstance().tipSkin;
		}
		public function point(xi:int,yi:int,parent:UIComponent):void{
			posX=xi;
			posY=yi;
			s=parent.stage;
			ui=parent;
		}
		public function show(item:BaseItemVO):void{
			if(item!=null){
				s.addChild(this);
				setItem(item);
			}
		}
		public function hide():void{
			if(tip&&tip.parent){
				removeChild(tip);
				tip=null;
			}
			if(ui&&s.contains(this)){
				s.removeChild(this);
			}
		}
		private function setItem(item:BaseItemVO):void{
			if(tip&&tip.parent){
				removeChild(tip);
				tip=null;
			}
			tip=new GoodsToolTipView();
			tip.createItemTip(item);
			addChild(tip);
			this.width=tip.width;
			this.height=tip.height;
			this.x=posX;
			if(posY+this.height>GlobalObjectManager.GAME_HEIGHT){
				this.y=GlobalObjectManager.GAME_HEIGHT-this.height;
			}else{
				this.y=posY;
			}
		}
	}
}