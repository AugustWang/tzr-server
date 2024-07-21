package modules.scene.cases {

	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;
	
	import proto.common.p_map_monster;
	import proto.line.m_monster_attr_change_toc;
	import proto.line.m_monster_dead_toc;
	import proto.line.m_monster_enter_toc;
	import proto.line.m_monster_quit_toc;
	import proto.line.m_monster_talk_toc;
	import proto.line.m_monster_walk_toc;

	public class MonsterCase extends BaseModule {
		private static var _instance:MonsterCase;
		private var _view:GameScene;
		public static var prepareQuit:Array=[]; //可以清除的怪物ID

		public function MonsterCase():void {
			_view=GameScene.getInstance();
		}

		public static function getInstance():MonsterCase {
			if (_instance == null) {
				_instance=new MonsterCase;
			}
			return _instance;
		}

		/**
		 * 怪物走路
		 * @param vo
		 *
		 */
		public function onWalk(vo:m_monster_walk_toc):void {
			if (SceneDataManager.isGaming == false) {
				return;
			}
			var monster:Monster=SceneUnitManager.getUnit(vo.monsterinfo.monsterid, SceneUnitType.MONSTER_TYPE) as Monster;
			if (monster != null) {
				monster.speed=vo.monsterinfo.move_speed;
				var arr:Array=[new Pt(vo.pos.tx, 0, vo.pos.ty)];
				monster.run(arr);
			}
		}

		/**
		 *怪物出生
		 * @param vo
		 *
		 */
		public function onEnter(vo:m_monster_enter_toc):void {
			if (SceneDataManager.isGaming == false) {
				return; //忽略，切地图map_enter_toc之前，后台莫名发这消息过来
			}
			for (var i:int=0; i < vo.monsters.length; i++) {
				monsterEnter(vo.monsters[i]);
			}
		}

		private function monsterEnter(i:p_map_monster):void {
			var qIndex:int=prepareQuit.indexOf(i.monsterid)
			if (qIndex != -1) { //把此怪从删除列表里面删除
				prepareQuit.splice(qIndex, 1);
			}
			var monster:Monster=SceneUnitManager.getUnit(i.monsterid, SceneUnitType.MONSTER_TYPE) as Monster;
			if (monster == null) {
				monster=UnitPool.getMonster();
				monster.reset(i);
				_view.addUnit(monster, i.pos.tx, i.pos.ty, i.pos.dir);
			} else {
				monster.reset(i);
				var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(i.pos.tx, 0, i.pos.ty));
				monster.x=p.x;
				monster.y=p.y;
			}
		}


		/**
		 * 怪物消失
		 * @param vo
		 *
		 */
		public function onQuit(vo:m_monster_quit_toc):void {
			if (prepareQuit.indexOf(vo.monsterid) == -1) { //添加到删除列表
				prepareQuit.push(vo.monsterid);
			}
			LoopManager.setTimeout(sendToRoleState, 2000, [vo]);
		}

		private function sendToRoleState(vo:m_monster_quit_toc):void {
			var qIndex:int=prepareQuit.indexOf(vo.monsterid)
			if (qIndex != -1) { //只有在删除列表里面的怪才能删除,否则此怪已经重生
				prepareQuit.splice(qIndex, 1);
				_view.removeUnit(vo.monsterid, SceneUnitType.MONSTER_TYPE);
				var selected:SeletedRoleVo=RoleStateDateManager.seletedUnit;
				if (selected && selected.key == (SceneUnitType.MONSTER_TYPE + "_" + vo.monsterid)) {
					dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'see': false, 'vo': null});
				}
			}
		}

		/**
		 * 怪物死亡
		 * @param vo
		 *
		 */
		public function onDead(vo:m_monster_dead_toc):void {
			var monster:Monster=SceneUnitManager.getUnit(vo.monsterid, SceneUnitType.MONSTER_TYPE) as Monster;
			if (monster != null) {
				monster.isDead=true;
				monster.runEnd=true;
				LoopManager.setTimeout(delayDie, 460, [monster]);
			}
		}

		private function delayDie(monster:Monster):void {
			SceneUnitManager.removeUnit(monster.pvo.monsterid, SceneUnitType.MONSTER_TYPE);
			if (monster.unitKey == FightCase.getInstance().attackTargetKey) {
				FightCase.getInstance().attackTargetKey=""
			}
			monster.die();
			//清除被选头像
			var selected:SeletedRoleVo=RoleStateDateManager.seletedUnit;
			if (selected && selected.key == (SceneUnitType.MONSTER_TYPE + "_" + monster.id)) {
				dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'see': false, 'vo': null});
			}
		}

		public function onAttrChange(vo:m_monster_attr_change_toc):void {
		}

		public function onMonsterSay(vo:m_monster_talk_toc):void {
			var monster:Monster=SceneUnitManager.getUnit(vo.monster_id, SceneUnitType.MONSTER_TYPE) as Monster;
			if (monster != null && monster.isDead == false) {
				monster.say(vo.content);
			}
		}
		
		/**
		 * 攻击怪物的新手引导，特别针对任务副本。 
		 */
		public function addHitMonsterGuide():void{
			var monsters:Dictionary = SceneUnitManager.monsterHash;
			var target:Monster;
			var isFindMonsther:Boolean = false;
			if(SceneDataManager.mapID == 10302){
				for each(target in monsters){
					if(target.pvo.typeid == 10302001){
						isFindMonsther = true;
						break;
					}	
				}
			}else if(SceneDataManager.mapID == 10303){
				for each(target in monsters){
					if(target.pvo.typeid == 10303001){
						isFindMonsther = true;
						break;
					}	
				}
			}
			if(isFindMonsther){
				target.addTipView("点击此处攻击怪物！");
			}
		}
		
		override protected function initListeners():void {
			addSocketListener(SocketCommand.MONSTER_ENTER, onEnter); //怪物进入
			addSocketListener(SocketCommand.MONSTER_WALK, onWalk); //怪物走路
			addSocketListener(SocketCommand.MONSTER_DEAD, onDead); //怪物死亡
			addSocketListener(SocketCommand.MONSTER_QUIT, onQuit); //怪物清除
			addSocketListener(SocketCommand.MONSTER_ATTR_CHANGE, onAttrChange); //怪物数据改变
			addSocketListener(SocketCommand.MONSTER_TALK, onMonsterSay); //怪物清除
			addMessageListener(ModuleCommand.SHOW_HIT_MONSTER_GUIDE,addHitMonsterGuide);
		}
	}
}