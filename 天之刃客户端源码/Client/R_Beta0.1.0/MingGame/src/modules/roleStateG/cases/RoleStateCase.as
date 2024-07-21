package modules.roleStateG.cases {
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.cursor.cursors.MagicHandCursor;
	import com.events.ParamEvent;
	import com.managers.LayerManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUtils.SceneUnitType;
	
	import flash.events.Event;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.mypackage.PackageModule;
	import modules.roleStateG.SeletedRoleVo;
	import modules.roleStateG.views.states.AttackModeView;
	import modules.roleStateG.views.states.RoleBuffView;
	import modules.roleStateG.views.states.RoleMyStateView;
	import modules.roleStateG.views.states.RoleSelectedStateView;
	import modules.scene.SceneDataManager;
	import modules.skill.SkillModule;
	
	import proto.common.p_role;
	import proto.line.m_map_update_actor_mapinfo_toc;
	import proto.line.m_map_update_actor_mapinfo_tos;
	import proto.line.m_role2_levelup_toc;
	import proto.line.m_role2_pkmodemodify_toc;
	import proto.line.m_role2_pkmodemodify_tos;

	public class RoleStateCase extends BaseModule {
		private var myState:RoleMyStateView; //左上角的角色状态
		private var selectedState:RoleSelectedStateView; //被选中的角色状态
		private var _inited:Boolean;

		public function RoleStateCase() {
		}

		public function initView():void {
			if (_inited == false) {
				myState=new RoleMyStateView;
				selectedState=new RoleSelectedStateView;
				selectedState.x=400; //206;
				selectedState.y = 13;
				LayerManager.uiLayer.addChild(myState);
				LayerManager.uiLayer.addChild(selectedState);
				myState.addEventListener(AttackModeView.EVENT_CHANGE_ATTACK_MODE, toChangeAttack);
				myState.addEventListener(RoleMyStateView.EVENT_ROLE_HEAD_CLICK, onClickMyHead);
				myState.addEventListener(RoleMyStateView.EVENT_ROLE_BLOOD_CLICK, onClickMyBlood);
				selectedState.addEventListener(RoleSelectedStateView.EVENT_UPDATE_SELECTED, toUpdateSelected);
				_inited=true;
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.SYSTEM_CONFIG_INIT, configChanged);
			addMessageListener(ModuleCommand.CONFIG_CHANGED, configChanged);
		}
		
		private function configChanged():void {
			if (myState) {
				myState.configChanged();
			}
		}
		
		private function onClickMyBlood(event:Event):void {
			if (GlobalObjectManager.getInstance().selectTarget) {
				useSkill();
			}
		}

		/**
		 * 点击头像使用技能
		 */
		private function useSkill():void {
			var selectTargetKey:String=SceneUnitType.ROLE_TYPE + "_" + GlobalObjectManager.getInstance().user.attr.role_id;
//			if (SkillMode.getInstance().selectSkillTarget(selectTargetKey))
//			{
//				this.dispatch(ModuleCommand.ACTION_DO_SKILL, {skill:new SkillVO, target:selectTargetKey});
//			}
		}

		private function onClickMyHead(e:Event):void {
			var vo:SeletedRoleVo=new SeletedRoleVo();
			vo.setupMyRole();
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'see': true, 'vo': vo});
			if (CursorManager.getInstance().currentCursor == CursorName.MAGIC_HAND) {
				var magicCursor:MagicHandCursor=CursorManager.getInstance().getCursor(CursorName.MAGIC_HAND) as MagicHandCursor;
				PackageModule.getInstance().useItem(magicCursor.data.oid, 1, vo.id);
				return;
			}
			if (CursorManager.getInstance().currentCursor == CursorName.SELECT_TARGET) {
				SkillModule.getInstance().skillToTarget(SceneUnitManager.getSelf()); //选择技能后就去打
				return;
			}
		}

		private function toUpdateSelected(e:ParamEvent):void {
			var pvo:SeletedRoleVo=e.data as SeletedRoleVo;
			var vo:m_map_update_actor_mapinfo_tos=new m_map_update_actor_mapinfo_tos();
			vo.actor_id=pvo.id;
			vo.actor_type=pvo.unit_type;
			vo.map_id=SceneDataManager.mapData.map_id;
			this.sendSocketMessage(vo);
		}

		public function onUpdateSelected(vo:m_map_update_actor_mapinfo_toc):void {
			if (selectedState) {
				selectedState.onUpdateInfo(vo);
			}
		}

		public function onDeadAlive(alive:Boolean):void {
		}

		private function toChangeAttack(e:ParamEvent):void {
			var vo:m_role2_pkmodemodify_tos=new m_role2_pkmodemodify_tos;
			vo.pk_mode=int(e.data);
			this.sendSocketMessage(vo);
		}

		public function onChangeAttackMode(vo:m_role2_pkmodemodify_toc):void {
			myState.updateAttackMode(vo);
		}

		public function onLevelUp(vo:m_role2_levelup_toc):void {
			var pvo:p_role=GlobalObjectManager.getInstance().user;
			pvo.attr.next_level_exp=vo.next_level_exp;
			pvo.attr.level=vo.level;
			pvo.base.max_hp=vo.maxhp;
			pvo.base.max_mp=vo.maxmp;
			var addNum:Number=vo.exp - pvo.attr.exp;
			GlobalObjectManager.getInstance().user.attr.exp=vo.exp;
			this.dispatch(ModuleCommand.EXP_CHAGNGE);
			var addPoint:int=vo.attr_points - GlobalObjectManager.getInstance().user.base.remain_attr_points;
			var addSkill:int=vo.skill_points - GlobalObjectManager.getInstance().user.attr.remain_skill_points;
			var msg:String="";
			if (addSkill > 0) {
				msg+="获得新的技能点数"; //+ addSkill;
			}
			if (addPoint > 0) {
				msg+="，获得属性点×" + addPoint;
			}
//			Dispatch.dispatch(ModuleCommand.BROADCAST, "恭喜你升级了!");
//			Dispatch.dispatch(ModuleCommand.BROADCAST, msg);
//			Tips.getInstance().addTipsMsg(msg);
			pvo.attr.remain_skill_points=vo.skill_points;
			pvo.base.remain_attr_points=vo.attr_points;
			this.dispatch(ModuleCommand.ROLE_ARR_CHANGE);
		}

		public function update():void {
			if (myState) {
				myState.update();
			}
		}

		public function toChangeAttackMode(mode:int):void {
			myState.toChangeAttackMode(mode);
		}

		public function updateAttackMode(vo:m_role2_pkmodemodify_toc):void {
			myState.updateAttackMode(vo);
		}

		public function showSelected(obj:Object):void {
			selectedState.reset(obj);
		}

		public function get buffBox():RoleBuffView {
			return myState._buffBox;
		}
	}
}