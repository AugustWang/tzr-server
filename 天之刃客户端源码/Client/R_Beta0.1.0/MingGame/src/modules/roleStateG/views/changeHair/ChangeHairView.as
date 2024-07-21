package modules.roleStateG.views.changeHair
{
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	
	import com.components.BasePanel;
	import com.utils.ComponentUtil;
	
	public class ChangeHairView extends BasePanel
	{
		private var tabBar:TabBar;
		private var _seletedIndex:int=0;
		private var viewX:int=8;
		private var viewY:int=40;
		
		private var hairView:HairView;
		private var headView:HeadView;
		
		public function ChangeHairView(key:String=null)
		{
			super(key);
			title="美容店";
			this.width=548;
			this.height=380;
			initView();
		}
		
		private function initView():void
		{
			tabBar=new TabBar();
			tabBar.x=12;
			tabBar.y=5;
			addChild(tabBar);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChanged);
			tabBar.addItem("改变头像", 68);
			tabBar.addItem("改变发型", 68);
			seletedIndex=0;
		}
		
		private function onChanged(e:TabNavigationEvent):void
		{
			seletedIndex=e.index;
		}
		
		public function set seletedIndex(value:int):void
		{
			if (value == 0)
			{ //换头像界面
				if (hairView != null && this.contains(hairView))
				{
					removeChild(hairView);
				}
				if (headView == null)
				{
					headView=new HeadView;
					headView.x=8;
					headView.y=30;
				}
				if (headView.parent == null)
				{
					addChild(headView);
				}
				headView.reset();
			}
			else
			{
				//换发型界面
				if (headView != null && this.contains(headView))
				{
					removeChild(headView);
				}
				if (hairView == null)
				{
					hairView=new HairView();
					hairView.x=8;
					hairView.y=30;
				}
				if (hairView.parent == null)
				{
					addChild(hairView);
				}
				hairView.reset();
			}
			_seletedIndex=value;
		}
		
		public function get seletedIndex():int
		{
			return _seletedIndex;
		}
		
		public function reset():void
		{
			if (headView != null)
			{
				headView.reset();
			}
			if (hairView != null)
			{
				hairView.reset();
			}
		}
		
		public function reduceHairCardNum():void
		{
			if (hairView != null)
				hairView.reduceHairCardNum();
		}
		
		public function reduceHeadCardNum():void
		{
			if (headView != null)
				headView.reduceHeadCardNum();
		}
	}
}

