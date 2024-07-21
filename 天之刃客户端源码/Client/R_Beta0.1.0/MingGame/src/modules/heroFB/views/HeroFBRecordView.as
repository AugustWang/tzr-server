package modules.heroFB.views
{
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.heroFB.HeroFBDataManager;
	import modules.rank.RankModule;
	
	import proto.line.m_hero_fb_report_toc;
	
	public class HeroFBRecordView extends DragUIComponent
	{
		private var _title:TextField;
		private var _data:DataGrid;
		
		public function HeroFBRecordView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			this.width = 368;
			this.height = 190;
			Style.setRectBorder(this);
			this.showCloseButton = true;
			this.x = (GlobalObjectManager.GAME_WIDTH - this.width) / 2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			
			_title = ComponentUtil.createTextField("最近五位打败【怪物名】的玩家信息：", 10, 7, null, 350, 20, this);
			
			_data = new DataGrid;
			_data.itemRenderer = HeroFBRecordRender;
			_data.x = 10;
			_data.y = 30;
			_data.width = 350;
			_data.height = 150;
			_data.addColumn("玩家名字", 125);
			_data.addColumn("国家", 100);
			_data.addColumn("过关成绩", 125);
			_data.itemHeight = 25;
			_data.pageCount = 5;
			_data.verticalScrollPolicy = ScrollPolicy.OFF;
			this.addChild(_data);
			
			var btn:Button = ComponentUtil.createButton("大明英雄榜", 262, 4, 80, 25, this);
			btn.addEventListener(MouseEvent.CLICK, btnClickHandler);
		}
		
		private function btnClickHandler(evt:Event):void
		{
			RankModule.getInstance().openRankWindow(10);
		}
		
		public function setData(vo:m_hero_fb_report_toc):void
		{
			var monsterVo:MonsterType = HeroFBDataManager.getInstance().getBossVoByBarrierId(vo.barrier_id);
			_title.text = "打败【" + monsterVo.monstername + "】玩家的最佳成绩：";
			//_data.dataProvider = vo.fb_record;
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			WindowManager.getInstance().removeWindow(this);
		}
	}
}