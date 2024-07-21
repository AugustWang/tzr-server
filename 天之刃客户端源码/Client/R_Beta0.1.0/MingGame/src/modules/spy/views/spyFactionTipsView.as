package modules.spy.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.scene.tile.Pt;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.scene.SceneDataManager;
	import modules.spy.SpyModule;
	
	import proto.line.m_spy_faction_toc;
	
	public class spyFactionTipsView extends BasePanel
	{
		private var dataText:TextField;
		private var helpActionText:TextField;
		private var sureBtn:Button;
		
		public function spyFactionTipsView(key:String=null)
		{
			super(key);
			initView();
		}
		
		public function initView():void
		{
			this.title = "国探通知";
			this.mouseEnabled = true;
			this.mouseChildren = true;
			
			var ui:Sprite = new Sprite();
			ui.x = 3;
			ui.width = 425;
			ui.height = 205;
			this.addChild(ui);
			
			this.width = 435;
			this.height = 245;
			this.x = (1002 - this.width) / 2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			
			this.dataText = new TextField;
			dataText.filters =  [new GlowFilter(0, 1, 2, 2)];
			dataText.x = 25;
			dataText.y = 10;
			dataText.width = 410;
			dataText.height = 200;
			dataText.multiline = true;
			dataText.wordWrap = true;
			dataText.selectable = false;
			this.addChild(dataText);
			
			this.sureBtn = new Button;
			this.sureBtn.buttonMode = true;
			this.sureBtn.width = 70;
			this.sureBtn.x = 340;
			this.sureBtn.y = 170;
			sureBtn.label = "我知道了";
			this.addChild(sureBtn);
			sureBtn.addEventListener(MouseEvent.CLICK, sureFunc);
			Style.setRedBtnStyle(sureBtn);
			
			var dataTxtStr:String = '<font color="#ffffff"><b>本国国探已发布：</b>\n';
			dataTxtStr += '1 国探时间<font color="#3be450">30</font>分钟。\n';
			dataTxtStr += '2 等级<font color="#3be450">≥40</font>级的玩家可参与国探。\n';
			dataTxtStr += '3 国探期间完成刺探军情任务可额外获得<font color="#3be450">30%</font>的<font color="#3be450">经验奖励</font>（必须在国探期\n间领取和提交任务才能获得额外的经验奖励）。\n';
			
			var _tf:TextFormat = new TextFormat;
			_tf.leading = 5;
			this.dataText.defaultTextFormat = _tf;			
			this.dataText.htmlText = dataTxtStr;
			
			this.helpActionText = new TextField();
			helpActionText.multiline = true;
			helpActionText.wordWrap = true;
			helpActionText.selectable = false;
			helpActionText.width = dataText.width;
			helpActionText.height = 40;
			helpActionText.x = 250;
			helpActionText.y = 130;
			
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 40) {
				var _space:String = '                          ';
				var helpActionTextStr:String = _space+'<A HREF="event:manual"><FONT color="#EBED32"><U>寻路前往参与</U></FONT></A>\n<A HREF="event:transform"><FONT color="#EBED32"><U>传送前往参与(消耗传送卷*1)</U></FONT></A>';
				helpActionText.htmlText = helpActionTextStr;				
				this.addChild(helpActionText);
				helpActionText.addEventListener(TextEvent.LINK, onLink);
			}
		}
		
		private function onLink(e:TextEvent):void
		{
			var type:String=e.text;
			var spyFactionVo:m_spy_faction_toc = SpyModule.getInstance().spyFactionVo;
			
			if (spyFactionVo) {				
				if(type == 'transform') {
					transformGoTo(spyFactionVo);
				}else{
					manualGoTo(spyFactionVo);
				}
			}
			
		}
		
		private function transformGoTo(spyFactionVo:m_spy_faction_toc):void{
			var chuanSongJuan:BaseItemVO = PackManager.getInstance().getGoodsByEffectType([ItemConstant.EFFECT_TRANSFORM_MAP]);
			
			if (!chuanSongJuan) {
				BroadcastSelf.getInstance().appendMsg("<font color='#ff0000'>背包里没有传送卷，传送卷可在商店购买</font>");
				return;
			}
			
			PathUtil.carry(spyFactionVo.map_id, new Pt(spyFactionVo.tx, 0, spyFactionVo.ty));
			closeWindow();
		}
		
		private function manualGoTo(spyFactionVo:m_spy_faction_toc):void{
			
			if (SceneDataManager.mapData.isSub == 1 || SceneDataManager.isRobKingMap || SceneDataManager.mapData.map_id == 10202) {
				BroadcastSelf.getInstance().appendMsg("<font color='#ff0000'>特殊场景，无法自动寻路。</font>")
				return;
			}
			
			PathUtil.findNpcAndOpen(spyFactionVo.npc_id.toString());
			closeWindow();
		}
		
		private function sureFunc(e:MouseEvent):void
		{
			this.closeWindow();
		}
		
		override public function closeWindow(save:Boolean = false):void
		{
			super.closeWindow(save)
		}
	}
}