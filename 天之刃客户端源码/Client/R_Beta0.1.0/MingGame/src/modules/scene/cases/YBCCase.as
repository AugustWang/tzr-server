package modules.scene.cases {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.PathUtil;

	import flash.geom.Point;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.family.FamilyYBCModule;
	import modules.personalybc.PersonalYbcModule;
	import modules.scene.SceneDataManager;

	import proto.line.m_ybc_dead_toc;
	import proto.line.m_ybc_enter_toc;
	import proto.line.m_ybc_faraway_toc;
	import proto.line.m_ybc_notify_pos_toc;
	import proto.line.m_ybc_pos_toc;
	import proto.line.m_ybc_quit_toc;
	import proto.line.m_ybc_speed_toc;
	import proto.line.m_ybc_walk_toc;

	public class YBCCase extends BaseModule {
		private static var _instance:YBCCase;

		public function YBCCase():void {
		}

		public static function getInstance():YBCCase {
			if (_instance == null) {
				_instance=new YBCCase;
			}
			return _instance;
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		/**
		 * 镖车进入
		 * @param vo
		 *
		 */
		public function onEnter(vo:m_ybc_enter_toc):void {
			if (SceneDataManager.isGaming == false) {
				return; //忽略
			}
			var ybc:YBC=SceneUnitManager.getUnit(vo.ybc_info.ybc_id, SceneUnitType.YBC_TYPE) as YBC;
			if (ybc == null) {
				ybc=UnitPool.getYBC();
				ybc.reset(vo.ybc_info);
				view.addUnit(ybc, vo.ybc_info.pos.tx, vo.ybc_info.pos.ty, vo.ybc_info.pos.dir);
			} else {
				if (ybc.parent == null) {
					view.midLayer.addChild(ybc);
				}
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.ybc_info.pos.tx, 0, vo.ybc_info.pos.ty));
				ybc.x=p.x;
				ybc.y=p.y;
				ybc.pvo=vo.ybc_info;
			}
		}

		public function onWalk(vo:m_ybc_walk_toc):void {
			var ybc:YBC=SceneUnitManager.getUnit(vo.ybc_id, SceneUnitType.YBC_TYPE) as YBC;
			if (ybc != null) {
				var arr:Array=[new Pt(vo.pos.tx, 0, vo.pos.ty)];
				ybc.run(arr);
			}
		}

		public function onYBCSpeed(vo:m_ybc_speed_toc):void {
			var ybc:YBC=SceneUnitManager.getUnit(vo.ybc_id, SceneUnitType.YBC_TYPE) as YBC;
			if (ybc != null) {
				ybc.speed=vo.move_speed;
			}
		}

		/**
		 * 镖车死
		 * @param vo
		 *
		 */
		public function onDead(vo:m_ybc_dead_toc):void {
			var ybc:YBC=SceneUnitManager.getUnit(vo.ybc_id, SceneUnitType.YBC_TYPE) as YBC;
			if (ybc != null) {
				ybc.die();
			}
		}

		/**
		 * 镖车退
		 * @param vo
		 *
		 */
		public function onQuit(vo:m_ybc_quit_toc):void {
			view.removeUnit(vo.ybc_id, SceneUnitType.YBC_TYPE);
		}


		/**
		 * 服务端通知镖车位置,登录时的，只有一次
		 *
		 */
		public function onNotifyPos(vo:m_ybc_notify_pos_toc):void {
			this.dispatch(ModuleCommand.YBC_NOTIFY_POS, vo);
		}

		//给雷达显示的
		public function onYBCPos(vo:m_ybc_pos_toc):void {
			if (vo.map_id == SceneDataManager.mapData.map_id) {
				var p:Point=new Point(vo.tx, vo.ty);
				this.dispatch(ModuleCommand.YBC_POS, p);
			}
		}
		private var hasFar:Boolean;

		public function onYbcFarway(vo:m_ybc_faraway_toc):void {
			if (hasFar == false) {
				if (view.hero != null) {
					view.hero.normal();
					MoveCase.getInstance().walkPathUp([view.hero.index]);
					hasFar=true;
				}
			}
			BroadcastModule.getInstance().popupMsg("你已远离镖车，镖车不再跟随，镖车丢失无法完成任务！", "寻回镖车", findYBC, vo);
		}

		private function findYBC(vo:m_ybc_faraway_toc):void {
			PathUtil.goto(vo.map_id, new Pt(vo.pos.tx, 0, vo.pos.ty));
		}

		private function setYBCArray():void {
			view.clearSign();
			var mapIndex:int=SceneDataManager.YBCMapIndex;
			if (mapIndex == -1) { //不在京城，平江，边城
				return;
			}
			var posArr:Array;
			var img:Image;
			if (PersonalYbcModule.getInstance().showYBCArrow) {
				var level:int=GlobalObjectManager.getInstance().user.attr.level;
				if (mapIndex == 0) { //京城
					posArr=personalJingCheng;
				} else if (mapIndex == 1) { //平江
					if (level < 40) {
						posArr=personalPingJiang1;
					} else {
						posArr=personalPingJiang2;
					}
				} else if (mapIndex == 2) { //边城
					if (level >= 40 && level < 60) {
						posArr=personalBianCheng1;
					} else if (level >= 60) {
						posArr=personalBianCheng2;
					}
				}
			}
			if (FamilyYBCModule.getInstance().showYbcArrow) {
				posArr=familyArr;
			}
			if (posArr != null) {
				var imgs:Array=[];
				for (var i:int=0; i < posArr.length; i++) {
					var ybcArr:Array=posArr[i]; //0是tx,1是ty,2是方向
					var url:String=GameConfig.ROOT_URL + "com/assets/jt" + ybcArr[2] + ".png";
					img=new Image;
					img.source=url;
					img.alpha=0.9;
					var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(ybcArr[0], 0, ybcArr[1]));
					img.x=p.x;
					img.y=p.y;
					imgs.push(img);
				}
				view.addSign(imgs);
			}
		}

		private function clearYBCArray():void {
			view.clearSign();
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, setYBCArray);
			addMessageListener(ModuleCommand.SCENE_SHOW_SIGN, setYBCArray);
			addMessageListener(ModuleCommand.SCENE_CLEAR_SIGN, clearYBCArray);
			addSocketListener(SocketCommand.YBC_ENTER, onEnter); //镖车进入
			addSocketListener(SocketCommand.YBC_WALK, onWalk); //镖车走路
			addSocketListener(SocketCommand.YBC_DEAD, onDead); //镖车死亡
			addSocketListener(SocketCommand.YBC_QUIT, onQuit); //镖车清除
			addSocketListener(SocketCommand.YBC_NOTIFY_POS, onNotifyPos); //镖车位置提醒
			addSocketListener(SocketCommand.YBC_POS, onYBCPos); //镖车位置
			addSocketListener(SocketCommand.YBC_FARAWAY, onYbcFarway); //镖车远离
			addSocketListener(SocketCommand.YBC_SPEED, onYBCSpeed); //镖车速度改变
		}
		private var personalJingCheng:Array=[[109, 31, 2], [102, 33, 1], [90, 39, 3], [90, 49, 3], [90, 60, 3], [90, 70, 3], [90, 89, 3], [90, 99, 3], [90, 109, 3], [90, 117, 3], [90, 139, 3], [90, 152, 3]];
		//平江1-39级
		private var personalPingJiang1:Array=[[62, 28, 3], [63, 41, 3], [62, 48, 2]];
		//平江40级以上	
		private var personalPingJiang2:Array=[[62, 28, 3], [63, 41, 3], [54, 46, 1], [39, 46, 1], [23, 45, 2], [15, 54, 2], [4, 56, 1]];
		//边城段40-59级
		private var personalBianCheng1:Array=[[137, 71, 1], [124, 71, 1], [109, 71, 1], [95, 66, 1], [84, 59, 1]];
		//边城段60级以上
		private var personalBianCheng2:Array=[[137, 71, 1], [124, 71, 1], [109, 71, 1], [95, 66, 1], [86, 65, 2], [73, 66, 1], [62, 61, 1], [48, 59, 2], [42, 65, 2], [32, 71, 1], [19, 71, 1], [4, 71, 1]];
		private var familyArr:Array=[[109, 31, 2], [102, 33, 1], [90, 39, 3], [90, 49, 3], [90, 60, 3], [90, 70, 3], [90, 89, 3], [90, 99, 3], [90, 109, 3], [90, 117, 3], [90, 139, 3], [90, 152, 3], [62, 28, 3], [63, 41, 3], [54, 46, 1], [39, 46, 1], [23, 45, 2], [15, 54, 2], [4, 56, 1], [137, 71, 1], [124, 71, 1], [109, 71, 1], [95, 66, 1], [86, 65, 2], [73, 66, 1], [62, 61, 1], [48, 59, 2], [42, 65, 2], [32, 71, 1], [19, 71, 1], [4, 71, 1]];
	}
}