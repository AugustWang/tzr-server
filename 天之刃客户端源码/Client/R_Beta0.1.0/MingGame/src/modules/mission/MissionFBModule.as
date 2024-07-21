package modules.mission {
	import com.components.MessageIcon;
	import com.components.alert.Alert;
	import com.loaders.SourceLoader;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.heroFB.views.HeroFBRecordView;
	import modules.heroFB.views.HeroFBStateView;
	import modules.heroFB.views.HeroFBView;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.playerGuide.PlayerGuideModule;
	
	import proto.common.p_role_hero_fb_info;
	import proto.line.m_mission_fb_enter_toc;
	import proto.line.m_mission_fb_enter_tos;
	import proto.line.m_mission_fb_prop_toc;
	import proto.line.m_mission_fb_prop_tos;
	import proto.line.m_mission_fb_quit_toc;
	import proto.line.m_mission_fb_quit_tos;

	public class MissionFBModule extends BaseModule {
		public static var isOpenHeroFBPanel:Boolean;

		private static var _instance:MissionFBModule;

		private var _source:SourceLoader;
		private var _heroView:HeroFBView;
		private var _heroFBInfo:p_role_hero_fb_info;
		private var _stateView:HeroFBStateView;
		private var _isInHeroFb:Boolean=false;
		private var _recordView:HeroFBRecordView;
		private var _icon:MessageIcon;
		private var _currentBarrier:int;
		private var _toEnterBarrier:int=0;

		public function MissionFBModule() {
			super();
		}

		public static function getInstance():MissionFBModule {
			if ( !_instance )
				_instance=new MissionFBModule();

			return _instance;
		}
		
		
		

		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_97, onEnter102MissionFb);
			addMessageListener(NPCActionType.NA_98, onEnter101MissionFb);
			addMessageListener(NPCActionType.NA_99, onQuitSingeFb);
			
			
			addMessageListener( ModuleCommand.CHANGE_MAP, onChangeMap );
			addMessageListener( ModuleCommand.MISSION_FB_ROLE_DEAD, onFbRoleDead );
			addMessageListener( ModuleCommand.STAGE_RESIZE, stageResizeHandler );

			addSocketListener( SocketCommand.MISSION_FB_ENTER, onMissionFbEnterReturn );
			addSocketListener( SocketCommand.MISSION_FB_QUIT, onMissionFbQuitReturn );
			addSocketListener( SocketCommand.MISSION_FB_PROP, onMissionFbPropReturn );
		}

		/**
		 * 退出任务的单人副本 
		 */		
		private function onQuitSingeFb(vo:NpcLinkVO=null):void {
			requestQuitMissionFb();
		}
		
		/**
		 * 进入地主大院的副本 
		 */		
		public function onEnter101MissionFb(vo:NpcLinkVO=null):void {
			requestEnterMissionFb(101);
		}

		/**
		 * 进入元军军营的副本
		 */		
		public function onEnter102MissionFb(vo:NpcLinkVO=null):void {
			requestEnterMissionFb(102);
		}

		/**
		 * 请求退出任务的个人副本
		 */
		public function requestQuitMissionFb(quitType:int=0 ):void {
			var vo:m_mission_fb_quit_tos = new m_mission_fb_quit_tos();
			vo.quit_type = quitType;
			sendSocketMessage(vo);

		}

		/**
		 * 请求进入任务的个人副本
		 */
		public function requestEnterMissionFb(barrier_id:int):void {
			var vo:m_mission_fb_enter_tos = new m_mission_fb_enter_tos();
			vo.barrier_id = barrier_id;
			sendSocketMessage(vo);
		}
		
		/**
		 * 请求获取个人副本的道具
		 */
		public function requestPropMissionFb(barrier_id:int):void {
			var vo:m_mission_fb_prop_tos = new m_mission_fb_prop_tos();
			vo.barrier_id = barrier_id;
			sendSocketMessage(vo);
		}
		
		private function onMissionFbPropReturn(vo:m_mission_fb_prop_toc):void {
			if ( vo.succ){
				PlayerGuideModule.getInstance().hookMissionFbProp(vo.barrier_id,vo.prop_id);
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function onMissionFbQuitReturn(vo:m_mission_fb_quit_toc):void {
			if (!vo.succ)
				Tips.getInstance().addTipsMsg(vo.reason);
		}

		private function onMissionFbEnterReturn(vo:m_mission_fb_enter_toc):void {
			if (!vo.succ){
				if( vo.barrier_id>0 && vo.error_code>0 ){
					if( vo.error_code==10001 ){
						if( vo.barrier_id==101 ){
							Tips.getInstance().addTipsMsg("跟功夫教头接受【斗地主】的任务才可进入该副本");
						}else if( vo.barrier_id==102 ){
							Tips.getInstance().addTipsMsg("跟徐将军接受【血海深仇】的任务才可进入该副本");
						}
						return;
					}else if( vo.error_code==10002 ){
						Tips.getInstance().addTipsMsg("完成任务后不能重复进入该副本地图");
						return;
					}	
				}
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}



		/**
		 * 屏幕自适应
		 */

		private function stageResizeHandler( value:Object ):void {
			if ( _stateView )
				_stateView.onStageResize();

			if ( _heroView )
				_heroView.stageResizeHandler();
		}


		/**
		 * 角色在副本中死亡
		 */

		private function onFbRoleDead():void {
			//Alert.show( "你他妈太牛了，竟然这么容易的都打不过！", "挑战失败", null, null, "返回入口", "", null, false );
		}

		/**
		 * 进入地图hook
		 */
		private function onChangeMap( mapId:int ):void {
			//暂时先写死副本ID，之后修改为xml
			if( mapId==10302 ){
				requestPropMissionFb( 101 );
			}else if( mapId==10303 ){
				PlayerGuideModule.getInstance().showMonsterGuideTip();
			}
		}



		/**
		 * 是否是任务副本的地图 
		 */
		public function isMapMisssionFB( mapId:int ):Boolean {
			return ( 10302 == mapId || 10303 == mapId );
		}
	}
}