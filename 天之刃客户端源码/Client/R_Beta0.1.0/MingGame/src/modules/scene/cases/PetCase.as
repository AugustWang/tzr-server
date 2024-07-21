package modules.scene.cases {
	import com.common.GlobalObjectManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.MyPet;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;

	import flash.geom.Point;
	import flash.utils.getTimer;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.pet.PetDataManager;
	import modules.pet.config.PetConfig;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneDataManager;

	import proto.common.p_map_pet;
	import proto.line.m_pet_dead_toc;
	import proto.line.m_pet_enter_toc;
	import proto.line.m_pet_quit_toc;

	public class PetCase extends BaseModule {
		private static var _instance:PetCase;
		public static var prepareQuit:Array=[]; //可以清除的怪物ID

		public function PetCase():void {
		}

		public static function getInstance():PetCase {
			if (_instance == null) {
				_instance=new PetCase;
			}
			return _instance;
		}

		public function onPetEnter(vo:m_pet_enter_toc):void {
			for (var i:int=0; i < vo.pets.length; i++) {
				perEnter(vo.pets[i]);
			}
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		private function perEnter(vo:p_map_pet):void {
			if (SceneDataManager.isGaming == false) {
				return; //忽略，切地图map_enter_toc之前，后台莫名发这消息过来
			}
			var qIndex:int=prepareQuit.indexOf(vo.pet_id);
			if (qIndex != -1) { //把此宠物从删除列表里面删除
				prepareQuit.splice(qIndex, 1);
			}
			var master:MutualAvatar=SceneUnitManager.getUnit(vo.role_id) as MutualAvatar;
			var p:Point;
			if (master != null) {
				var pos:Pt=master.index;
				var petPos:Pt=ScenePtMath.getPetPt(pos, master.dir, 2);
				if (vo.role_id == GlobalObjectManager.getInstance().user.base.role_id) {
					var mypet:MyPet=SceneUnitManager.getUnit(vo.pet_id, SceneUnitType.PET_TYPE) as MyPet;
					if (mypet == null) {
						mypet=new MyPet;
						mypet.reset(vo);
						view.addUnit(mypet, petPos.x, petPos.z, master.dir);
						if (PetDataManager.thePet == null) {
							var word:String=PetConfig.getSayWordByAction("born").data;
							if (PetConfig.getSayWordByAction("born").addName == "yes") {
								word=GlobalObjectManager.getInstance().user.base.role_name + "，" + word;
							}
							mypet.say(word);
						}
					} else {
						p=TileUitls.getIsoIndexMidVertex(new Pt(petPos.x, 0, petPos.z));
						mypet.x=p.x;
						mypet.y=p.y;
						if (mypet.parent == null) {
							view.midLayer.addChild(mypet);
						}
					}
					dispatch(ModuleCommand.BATTLE_PET_CHANGE, vo);
				} else {
					var pet:Pet=SceneUnitManager.getUnit(vo.pet_id, SceneUnitType.PET_TYPE) as Pet;
					if (pet == null) {
						pet=UnitPool.getPet();
						pet.reset(vo);
						view.addUnit(pet, petPos.x, petPos.z, master.dir);
					} else {
						p=TileUitls.getIsoIndexMidVertex(new Pt(petPos.x, 0, petPos.z));
						pet.x=p.x;
						pet.y=p.y;
						if (pet.parent == null) {
							view.midLayer.addChild(pet);
						}
					}
				}
			}
		}

		public function onDead(vo:m_pet_dead_toc):void {
			var pet:MutualAvatar=SceneUnitManager.getUnit(vo.pet_id, SceneUnitType.PET_TYPE) as MutualAvatar;
			if (pet != null) {
				pet.isDead=true;
				if (pet is Pet) {
					Pet(pet).curState=RoleActState.DEAD;
				} else if (pet is MyPet) {
					MyPet(pet).curState=RoleActState.DEAD;
				}
				LoopManager.setTimeout(delayDie, 460, [pet]);
			}
//			trace("宠物死亡时间：" + getTimer());
		}

		private function delayDie(tar:MutualAvatar):void {
			if (tar.parent != null) {
				tar.parent.removeChild(tar);
				view.lowEffLayer.addChild(tar);
			}
			tar.die();
		}

		public function onQuit(vo:m_pet_quit_toc):void {
			if (prepareQuit.indexOf(vo.pet_id) == -1) { //添加到删除列表
				prepareQuit.push(vo.pet_id);
			}
			LoopManager.setTimeout(sendToRoleState, 2000, [vo]);
		}

		private function sendToRoleState(vo:m_pet_quit_toc):void {
			var qIndex:int=prepareQuit.indexOf(vo.pet_id)
			if (qIndex != -1) { //只有在删除列表里面的怪才能删除,否则此怪已经重生
				prepareQuit.splice(qIndex, 1);
				view.removeUnit(vo.pet_id, SceneUnitType.PET_TYPE);
				var selected:SeletedRoleVo=RoleStateDateManager.seletedUnit;
				if (selected && selected.key == (SceneUnitType.PET_TYPE + "_" + vo.pet_id)) { //请被选头像
					dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'see': false, 'vo': null});
				}
				var mypet:MutualAvatar=SceneUnitManager.getUnit(vo.pet_id, SceneUnitType.PET_TYPE) as MutualAvatar;
				if (mypet && mypet is MyPet) { //重置自己的宠物头像
					dispatch(ModuleCommand.BATTLE_PET_CHANGE);
				}
			}
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.PET_ENTER, onPetEnter); //宠物进入
			addSocketListener(SocketCommand.PET_DEAD, onDead); //宠物死亡
			addSocketListener(SocketCommand.PET_QUIT, onQuit); //宠物清除
		}
	}
}