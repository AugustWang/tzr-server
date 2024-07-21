package modules.scene.cases {

	import com.common.GlobalObjectManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.WorldManager;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.RoadManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.map.Map;
	import com.scene.sceneUtils.ConvertMath;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;

	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.mypackage.operateMode.OperateMode;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;

	import proto.common.p_pos;
	import proto.common.p_walk_path;
	import proto.line.m_move_sync_toc;
	import proto.line.m_move_walk_path_toc;
	import proto.line.m_move_walk_path_tos;
	import proto.line.m_move_walk_tos;

	public class MoveCase extends BaseModule {
		public static const NAME:String='MOVE';
		public static const MOVE_WALK_PATH:String="MOVE_WALK_PATH";
		public static const MOVE_WALK:String="MOVE_WALK";

		private static var _instance:MoveCase;
		private var view:GameScene;
		public var follow_id:int=-1;
		private var timeoutId:uint;

		public function MoveCase():void {
			view=GameScene.getInstance();
		}

		public static function getInstance():MoveCase {
			if (_instance == null) {
				_instance=new MoveCase;
			}
			return _instance;
		}

		public function walkUp(pt:Pt, dir:int):void {
			var vo:m_move_walk_tos=new m_move_walk_tos;
			vo.pos=new p_pos;
			vo.pos.tx=pt.x;
			vo.pos.ty=pt.z;
			vo.pos.dir=dir;
			sendSocketMessage(vo);
		}

		public function walkPathUp(path:Array):void {
			this.dispatch(ModuleCommand.DRAW_MY_PATH, path.concat());
			var vo:m_move_walk_path_tos=new m_move_walk_path_tos;
			vo.walk_path=new p_walk_path;
			vo.walk_path.path=ConvertMath.walkPath_pTile(path);
			sendSocketMessage(vo);
		}

		public function walkPathDown(vo:m_move_walk_path_toc):void {
			if (vo.roleid == GlobalObjectManager.getInstance().user.base.role_id) {
				return;
			}
			if (vo.walk_path.path.length == 0) {
				//  trace("错误：moveCase收到一条空路径");
				return;
			}
			vo.walk_path.path=ConvertMath.walkPath_pt(vo.walk_path.path);
			vo.walk_path.path=ConvertMath.revertPath(vo.walk_path.path);
			var role:Role=SceneUnitManager.getUnit(vo.roleid) as Role;
			if (role != null) {
				var followPt:Pt=vo.walk_path.path[vo.walk_path.path.length - 1] as Pt;
				role.run(vo.walk_path.path);

				//测试人物跟随
				if (vo.roleid == follow_id) {
					var tarRole:Role=SceneUnitManager.getUnit(vo.roleid) as Role;
					if (tarRole == null || tarRole.parent == null) {
						follow_id=-1;
					} else {
						clearTimeout(timeoutId);
						timeoutId=setTimeout(setFollow, 100, role.index, followPt);
					}
				}
			}
		}

		private function setFollow(tarpt:Pt, endpt:Pt):void {
			view.hero.follow(tarpt, endpt);
		}

		public function onSYNC(vo:m_move_sync_toc):void { //进入地图时后台一定发这个消息过来，后台的bug
			var role:MutualAvatar=SceneUnitManager.getUnit(vo.roleid) as MutualAvatar;
			var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
			if (role != null) {
				role.x=p.x;
				role.y=p.y;
				role.normal();
				if (vo.roleid == GlobalObjectManager.getInstance().user.base.role_id) {
					view.hero.checkSlice();
					Map.heroMoving=true;
//					view.hero.rerun();
				}
			}
		}

		public function runToMaster():void {
			if (follow_id != -1) {
				var role:Role=SceneUnitManager.getUnit(follow_id) as Role;
				if (role != null && view.hero != null) {
					view.hero.follow(role.index);
				}
			}
		}

		private function moveToPoint(vo:RunVo):void {
			if (SceneModule.isAutoHit == true) {
				SceneModule.getInstance().toAutoHitMonster();
			}
			if (vo.mapid == SceneDataManager.mapID && vo.pt.key == SceneDataManager.getMyPostion().pt.key && vo.action != null) {
				vo.action.execute(); //已经站在终点上了
				return;
			}
			var start:MacroPathVo=new MacroPathVo(SceneDataManager.mapData.map_id, SceneDataManager.getMyPostion().pt);
			var end:MacroPathVo=new MacroPathVo(vo.mapid, vo.pt);
			var path:Array=WorldManager.getWorldPath(start, end);
			if (path != null) {
				//////任务追踪时，取消僵硬时间///////
				var mode:int=OperateMode.getInstance().modeName;
				var isHooking:Boolean=GlobalObjectManager.getInstance().user.base.status == RoleActState.ON_HOOK;
				var isTraining:Boolean=GlobalObjectManager.getInstance().user.base.status == RoleActState.TRAINING;
				if (path.length == 1) {
					MyRoleControler.getInstance().runToPoint(path.shift().pt, vo.cut, vo.action);
				} else {
					MyRoleControler.getInstance().runToPoint(path.shift().pt);
				}
				RoadManager.pathAndAction(path,vo.cut,vo.action);
				var myRole:MyRole=UnitPool.getMyRole();
				myRole.showAutoRun(true);
			}
		}

		private function follow(roleid:int):void {
			follow_id=roleid;
			runToMaster();
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.MOVE_WALK_PATH, walkPathDown); //收到别人走路消息
			addSocketListener(SocketCommand.MOVE_SYNC, onSYNC); //校正玩家位置
			addMessageListener(ModuleCommand.ROLE_MOVE_TO, moveToPoint); //其他模块控制玩家走路
			addMessageListener(ModuleCommand.FOLLOW, follow);
		}
	}
}