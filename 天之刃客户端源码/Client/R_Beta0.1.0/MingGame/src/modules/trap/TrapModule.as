package modules.trap {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneUtils.SceneUnitType;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.roleStateG.AttackModeContant;
	import modules.scene.cases.MapCase;
	
	import proto.common.p_map_trap;
	import proto.line.m_trap_enter_toc;
	import proto.line.m_trap_quit_toc;

	public class TrapModule extends BaseModule {
		private static var _instance:TrapModule;
		private var traps:Dictionary;

		
		public function TrapModule() {
			traps=new Dictionary();
		}

		public static function getInstance():TrapModule {
			if (_instance == null)
				_instance=new TrapModule();
			return _instance;
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.TRAP_ENTER, onEnter);
			addSocketListener(SocketCommand.TRAP_QUIT, onQuit);
		}

		public function onEnter(vo:m_trap_enter_toc):void {
			add(vo.trap_list);
		}

		public function onQuit(vo:m_trap_quit_toc):void {
			remove(vo.trap_id);
		}
		
//		public function check():void{
//			for(var i:String in traps){
//				
//			}
//		}
		
		public function add($traps:Array):void {
			var l:int=$traps.length;
			for (var i:int=0; i < l; i++) {
				var vo:p_map_trap=p_map_trap($traps[i]);
				if (checkShow(vo)) {
					MapCase.getInstance().onTrapEnter(vo);
				} else {
					traps[vo.trap_id]=vo;
				}
			}
		}

		public function remove($traps:Array):void {
			var l:int=$traps.length;
			for (var i:int=0; i < l; i++) {
				var id:int=$traps[i];
				if (traps.hasOwnProperty(id)) {
					traps[id]=null;
					delete traps[id];
				}
				GameScene.getInstance().removeUnit($traps[i], SceneUnitType.TRAP_TYPE);
			}
		}

		/**
		 * 根据陷阱的PK模式决定,陷阱是否可以让玩家看见,陷阱对玩家无伤害则可见
		 */
		public function checkShow(vo:p_map_trap):Boolean {
			if (vo.trap_type == 2) { //火墙
				return true;
			}
			if (vo.owner_id == GlobalObjectManager.getInstance().user.base.role_id && vo.owner_type == SceneUnitType.ROLE_TYPE) {
				return true;
			}
			switch (vo.pk_mode) {
				case AttackModeContant.PEACE:
					return true;
				case AttackModeContant.ALL:
					return false;
				case AttackModeContant.TEAM:
					if (vo.team_id == GlobalObjectManager.getInstance().user.base.team_id) {
						return true;
					} else {
						return false;
					}
				case AttackModeContant.FAMILY:
					if (vo.family_id == GlobalObjectManager.getInstance().user.base.family_id) {
						return true;
					} else {
						return false;
					}
				case AttackModeContant.FACTION:
					if (vo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id) {
						return true;
					} else {
						return false;
					}
				case AttackModeContant.KINDEVIL:
					if (GlobalObjectManager.getInstance().user.base.pk_points > 18) {
						return false;
					} else {
						return true;
					}
			}
			return true;
		}

		public function createSkin(id:int):String {
			switch (id) {
				case 1:
					return GameConfig.EFFECT_SKILL_PATH + "trap/jing_ji_xian_jing.swf";
				case 2:
					return GameConfig.EFFECT_SKILL_PATH + "trap/huo_yao_xian_jing_huo.swf";
			}
			return "";
		}
	}
}