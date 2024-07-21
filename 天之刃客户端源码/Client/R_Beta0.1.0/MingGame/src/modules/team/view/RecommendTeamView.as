package modules.team.view
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.team.TeamModule;
	
	public class RecommendTeamView extends BasePanel
	{
		private var closeBtn:UIComponent;
		private var refreshBtn:Button;
		private var recommendTxt:TextField;
		private var levelTxt:TextField;
		private var descTxt:TextField;
		private var list:List;
		private var tipTxt:TextField;
		private var changeSmallBtn:UIComponent;
		
		private static var _instance:RecommendTeamView;
		
		public static function getInstance():RecommendTeamView{
			if(!_instance){
				_instance = new RecommendTeamView();
			}
			return _instance;
		}
		
		public function RecommendTeamView()
		{
			super();
			this.width = 285;
			this.height = 205+25;
			this.title = "推荐组队";
			this.titleAlign = 2;
			
			recommendTxt = ComponentUtil.createTextField("推荐组队",35,13,null,70,25,this);
			recommendTxt.textColor = 0xabdbe7;
			levelTxt = ComponentUtil.createTextField("级别",recommendTxt.x + recommendTxt.width + 23,recommendTxt.y,null,50,25,this);
			levelTxt.textColor = 0xabdbe7;
			refreshBtn = ComponentUtil.createButton("刷新",190,10,50,25,this);
			refreshBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			
			//缩小button
			changeSmallBtn = new UIComponent();
			this.addChildToSuper(changeSmallBtn);
			changeSmallBtn.buttonMode = true;
			changeSmallBtn.x = 240;
			changeSmallBtn.y = 6;
			changeSmallBtn.bgSkin = Style.getButtonSkin("small_1skin","small_2skin","small_3skin",null,GameConfig.T1_UI);
			changeSmallBtn.addEventListener(MouseEvent.CLICK,onClickForSmallHandler);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			this.addChild(line);
			line.width = 258;
			line.x = recommendTxt.x - 22;
			line.y = recommendTxt.y + recommendTxt.height;
			
			var skin:Skin = new Skin();
			list = new List();
			this.addChild(list);
			list.width = 258;
			list.height = 120;
			list.x  = line.x - 3;
			list.y = line.height + line.y;
			list.itemHeight = 23;
			list.verticalScrollPolicy = ScrollPolicy.OFF;
			list.itemRenderer = RecommendTeamItemRender;
			list.setOverItemSkin(skin);
			list.setSelectItemSkin(skin);
			list.bgSkin = null;
			
			var line1:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			this.addChild(line1);
			line1.width = 258;
			line1.x = recommendTxt.x - 22;
			line1.y = list.y + list.height;
			
			tipTxt = ComponentUtil.createTextField(" 和其他玩家组成队伍，可更轻松完成任务。",line1.x ,line1.y + line1.height,null,258,200,this);
			tipTxt.textColor = 0xc9e65a//0x36a0ff;
			tipTxt.multiline = true;
			tipTxt.wordWrap = true;
		}
		//点击缩小
		private function onClickForSmallHandler(evt:MouseEvent):void{
			WindowManager.getInstance().popUpWindow(ScaleTeamView.getInstance(),WindowManager.UNREMOVE);
			ScaleTeamView.getInstance().x = this.x;
			ScaleTeamView.getInstance().y = this.y;
			this.visible = false;
		}
		
		//刷新数据S
		private function onMouseClickHandler(evt:MouseEvent):void{
			TeamModule.getInstance().recommedTeam(this.x,this.y);
		}
		
		//给list添加数据
		public function setData(teamArr:Array,posX:int,posY:int):void{
			this.x = posX;
			this.y = posY;
			list.dataProvider = teamArr;
		}
		
		public function closeWinHandler(evt:MouseEvent = null):void{
			WindowManager.getInstance().removeWindow(this);
		}
	}
}