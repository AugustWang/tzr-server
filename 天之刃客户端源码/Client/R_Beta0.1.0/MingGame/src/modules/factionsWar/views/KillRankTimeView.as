package modules.factionsWar.views
{
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class KillRankTimeView extends UIComponent
	{
		private var _heightValue:Number=0;
		
		override public function get height():Number
		{
			return _heightValue;
		}
		
		public function KillRankTimeView()
		{
			super();
			initUI();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			var borderView:UIComponent=new UIComponent;
			borderView.width=100;
			borderView.height=40;
			Style.setMenuItemBg(borderView); //背景
			this.addChild(borderView);
			
			var textFormat:TextFormat=new TextFormat();
			textFormat.color="0xFFF673";
			textFormat.size=12;
			textFormat.align="left";
			var text:TextField=ComponentUtil.createTextField("国战击杀榜", 5, 8, textFormat, 100, 20, this);
			this.addEventListener(MouseEvent.CLICK,onOpenKillRankViewHandle);
			//高度，由于实际才20，所以必须重写height方法
			_heightValue = 40;
		}
		
		//资源路径
		private var url:String = "com/assets/killRank/killRank.swf";
		//loader
		private var sourceLoader:SourceLoader;
		//点击打开杀人榜的回调函数
		protected function onOpenKillRankViewHandle(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if(sourceLoader == null){
				sourceLoader = new SourceLoader();
				sourceLoader.loadSource(GameConfig.ROOT_URL+url,"正在加载杀人榜UI",onComplete);
			}else{
				killRankView.openWindow();
			}
		}
		
		private var killRankView:KillRankView;
		private function onComplete():void
		{
			// TODO Auto Generated method stub
			if(killRankView == null){
				killRankView = new KillRankView(sourceLoader);
			}
			killRankView.openWindow();
		}
		
	}
}