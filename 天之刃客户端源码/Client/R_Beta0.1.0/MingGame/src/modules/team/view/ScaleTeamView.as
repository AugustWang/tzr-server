package modules.team.view
{
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ScaleTeamView extends DragUIComponent
	{
		private static var _instance:ScaleTeamView;
		public static function getInstance():ScaleTeamView{
			if(!_instance){
				_instance = new ScaleTeamView();
			}
			return _instance;
		}
		public function ScaleTeamView()
		{
			super();
			this.width = 285;
			this.height = 25;
			
			var bitmapdata:BitmapData = Style.getUIBitmapData(GameConfig.T1_UI,"tou");
			var skin_bg:Bitmap = new Bitmap(bitmapdata);
			skin_bg.width = 285;
			addChild(skin_bg);
			
			var title:TextField = new TextField();
			this.addChild(title);
			title.text = "推荐组队";
			title.mouseEnabled = false;
			title.setTextFormat(new TextFormat("宋体",14,0xFFF2BA,true));
			title.filters = [new GlowFilter(0x000000,1,2,2,4)];
			title.width = 80;
			title.height = 25;
			title.x = (this.width - title.width)/2+10;
			title.y = (this.height - title.height)/2+5;
			
//			var recommendTxt:TextField = ComponentUtil.createTextField("推荐组队",35,10,null,70,25,this);
//			recommendTxt.textColor = 0x000000;
//			var levelTxt:TextField = ComponentUtil.createTextField("级别",recommendTxt.x + recommendTxt.width + 23,recommendTxt.y,null,50,25,this);
//			levelTxt.textColor = 0x000000;
//			var refreshBtn:Button = ComponentUtil.createButton("刷新",190,10,50,19,this);
//			refreshBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			
			//放大button
			var changeSmallBtn:UIComponent = new UIComponent();
			this.addChild(changeSmallBtn);
			changeSmallBtn.buttonMode = true;
			changeSmallBtn.x = 242;
			changeSmallBtn.y = 5;
			changeSmallBtn.bgSkin = Style.getButtonSkin("task_big","task_bigOver","task_bigDown",null,GameConfig.T1_UI);
			changeSmallBtn.addEventListener(MouseEvent.CLICK,onClickForSmallHandler);
			
			//关闭button
			var closeBtn:UIComponent = new UIComponent();
			closeBtn.x  = 262;
			closeBtn.y = changeSmallBtn.y;
			closeBtn.buttonMode=true;
			closeBtn.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI)
			closeBtn.addEventListener(MouseEvent.CLICK,closeWinHandler);
			addChild(closeBtn);
			closeBtn.width=closeBtn.height=18;
		}
		
		//关闭
		private function closeWinHandler(evt:MouseEvent):void{
			WindowManager.getInstance().removeWindow(this);
			RecommendTeamView.getInstance().closeWinHandler();
		}
		
		//刷新
		private function onMouseClickHandler(evt:MouseEvent):void{}
		
		//还原
		private function onClickForSmallHandler(evt:MouseEvent):void{
			WindowManager.getInstance().removeWindow(this);
			RecommendTeamView.getInstance().visible = true;
			RecommendTeamView.getInstance().x = this.x;
			RecommendTeamView.getInstance().y = this.y;
		}
	}
}