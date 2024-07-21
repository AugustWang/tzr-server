package modules.mypackage.views
{
	import com.components.BasePanel;
	import com.loaders.CommonLocator;
	import com.managers.WindowManager;
	import com.ming.ui.containers.HBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Sprite;
	
	import modules.mypackage.views.itemRender.SimpleGoodInfo;
	
	public class BugExpackView extends BasePanel
	{
		
		//资源显示对象
		private var content:UIComponent;
		
		public function BugExpackView()
		{
			initUI();
			initData();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			this.title="购买扩展背包";
			this.titleAlign=2;
			this.width=230;
			this.height=230;
			
			addContentBG(5,5);
			
			content = new UIComponent();
			content.x=10;
			content.y=5;
			content.width=220;
			content.height=180;
			addChild(content);
		}
		
		private function initData():void
		{
			// TODO Auto Generated method stub
			var xml:XML = CommonLocator.getXML(CommonLocator.EXPACK);
			
			var length:int = xml.goods.length();
			for(var i:int=0; i<length; i++){
				var data:Object = {};
				data.name = xml.goods[i].@name.toString();
				data.silver = xml.goods[i].@silver.toString();
				data.goodId = xml.goods[i].@goodId.toString();
				data.num = xml.goods[i].@num.toString();
				
				var childView:SimpleGoodInfo = new SimpleGoodInfo();
				childView.y = 5;
				childView.setData(data);
				content.addChild(childView);
			}
			
			LayoutUtil.layoutHorizontal(content,5);
		}
		
		override public function open():void{
			if(WindowManager.getInstance().isPopUp(this) != true){
				WindowManager.getInstance().popUpWindow(this);
				WindowManager.getInstance().centerWindow(this);
			}else{
				//这个把窗口移到最上层
				WindowManager.getInstance().container.addChild(this);
			}
		}
	}
}