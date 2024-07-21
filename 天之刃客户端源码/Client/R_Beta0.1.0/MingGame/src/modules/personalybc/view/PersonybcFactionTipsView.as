package modules.personalybc.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
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
	import modules.personalybc.PersonalYbcModule;
	import modules.scene.SceneDataManager;
	
	import proto.line.m_personybc_info_toc;
	
	public class PersonybcFactionTipsView extends BasePanel
	{
		private var dataTxt:TextField
		public var color:int;
		public var desc:String
		public var info_toc:m_personybc_info_toc
		private var sureBtn:Button
		
		private var helpActionText:TextField;
		private var txt:TextField;
		
		public function PersonybcFactionTipsView(key:String=null)
		{
			super(key);
			initView()
		}
		
		public function initView():void
		{
			
			this.title = "国运通知";
			this.mouseEnabled=true;
			this.mouseChildren=true;
			var ui:Sprite=new Sprite();
			ui.x=3
			ui.width=425;
			ui.height=205;
			this.addChild(ui);
			this.dataTxt=new TextField;
			dataTxt.filters=[new GlowFilter(0,1,2,2)]
			dataTxt.x=25;
			dataTxt.y=10
			this.width = 435
			this.height =245;
			this.x = (1002-this.width)/2;
			this.y = (GlobalObjectManager.GAME_HEIGHT-this.height)/2;
			dataTxt.width = 410
			dataTxt.height =200;
			dataTxt.multiline=true;
			dataTxt.wordWrap=true;
			dataTxt.selectable=false;
			this.addChild(dataTxt);
			
			this.sureBtn=new Button;
			this.sureBtn.buttonMode=true;
			this.addChild(sureBtn);
			this.sureBtn.width=70
			this.sureBtn.x=340;
			this.sureBtn.y=170;
			sureBtn.addEventListener(MouseEvent.CLICK,sureFunc);
			sureBtn.label='我知道了';
			Style.setRedBtnStyle(sureBtn);
			var dataTxtStr:String = '<font color="#ffffff"><b>本国国运已发布：</b>\n';
			dataTxtStr += '1 国运时间<font color="#3be450">40</font>分钟。\n';
			dataTxtStr += '2 等级<font color="#3be450">≥31</font>级的玩家可参与国运拉镖。\n';
			dataTxtStr += '3 领取国运镖车将扣除<font color="#3be450">5</font>点门派贡献度和一定的不绑定银子。\n';
			dataTxtStr += '4 国运期间完成国运拉镖任务，获得的银子奖励<font color="#3be450">15%</font>为不绑定银子。\n';
			dataTxtStr += '5 必须在国运的<font color="#3be450">40</font>分钟内领取和提交镖车才能获得不绑定银子奖励。</font>\n';
			
			var _tf:TextFormat = new TextFormat();
			_tf.leading = 5;
			this.dataTxt.defaultTextFormat = _tf;
			
			this.dataTxt.htmlText = dataTxtStr;
			helpActionText = new TextField();
			helpActionText.multiline=true;
			helpActionText.wordWrap=true;
			helpActionText.selectable=false;
			helpActionText.width = dataTxt.width;
			helpActionText.height =40;
			
			helpActionText.y = 130;
			helpActionText.x = 250;
			
			var _space:String = '                           ';
			var helpActionTextStr:String = _space+'<A HREF="event:manual"><FONT color="#EBED32"><U>寻路前往参与</U></FONT></A>\n<A HREF="event:transform"><FONT color="#EBED32"><U>传送前往参与(消耗传送卷*1)</U></FONT></A>';
			helpActionText.htmlText = helpActionTextStr;
			
			this.addChild(helpActionText);
			helpActionText.addEventListener(TextEvent.LINK, onLink);
		}
		
		
		private function onLink(e:TextEvent):void
		{
			var type:String=e.text;
			
			if(type == 'transform') {
				transformGoTo();
			}else{
				manualGoTo();
			}
			
		}
		
		private function transformGoTo():void{
			
			var chuanSongJuan:BaseItemVO = PackManager.getInstance().getGoodsByEffectType([ItemConstant.EFFECT_TRANSFORM_MAP]);
			if(!chuanSongJuan){
				BroadcastSelf.getInstance().appendMsg("<font color='#ff0000'>背包里没有传送卷，传送卷可在商店购买</font>");
				return;
			}
			
			var npcID:String = PersonalYbcModule.getInstance().view.info_toc.info.public_npc_id.toString();
			PathUtil.carryToNPC(npcID);
			closeWindow();
		}
		
		private function manualGoTo():void{
			
			if(SceneDataManager.mapData.isSub==1||SceneDataManager.isRobKingMap||SceneDataManager.mapData.map_id==10202)
			{
				BroadcastSelf.getInstance().appendMsg("<font color='#ff0000'>特殊场景，无法自动寻路。</font>")
				return;
			}
			
			var _npcID:String = PersonalYbcModule.getInstance().view.info_toc.info.public_npc_id.toString();
			//前往目的地模式
			PathUtil.findNpcAndOpen(_npcID);
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