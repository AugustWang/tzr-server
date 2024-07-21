package com.common {
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.tile.Pt;
	import com.utils.ShareObjectUtil;
	
	import flash.display.Stage;
	import flash.geom.Point;
	
	import modules.pet.PetDataManager;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_role;
	import proto.line.m_system_error_toc;
	import proto.login.m_login_flash_tos;

	public class GlobalObjectManager {
		/**
		 * 游戏 宽 高
		 */
		public static var GAME_WIDTH:int=1000;
		public static var GAME_HEIGHT:int=545;

		public var assetsPath:String;
		public var isSocketClose:Boolean=false;
		public var isChatSocketClose:Boolean=true;
		public var isChatReconnecting:Boolean=false;
		public var isRobKingMap:Boolean;
		public var timelater:int
		public var ping:String
		public var system_error:m_system_error_toc
		public var system_buff:Array=[];
		public var dataCountLevel:int=1; //统计用的 正式服不会使用到该属性
		public var selectTarget:Object;
		public var state:Stage;

		/**
		 * 0 为普通模式 1 为 1200 * 600  2 为全屏模式
		 */
		public var screenState:int;

		public function GlobalObjectManager(sigleton:SigletonPress) {
		}

		public static function getInstance():GlobalObjectManager {
			if (_instance == null) {
				_instance=new GlobalObjectManager(new SigletonPress());
			}

			return _instance;
		}

		public function get isDead():Boolean {
			return user.base.status == RoleActState.DEAD;
		}
		
		public function get isZazen():Boolean {
			return user.base.status == RoleActState.ZAZEN;
		}
		
		public function getMapID():int {
			return user.pos.map_id;
		}
		
		public function getX():int{
			return user.pos.pos.tx;
		}
		
		public function getY():int{
			return user.pos.pos.ty;
		}

		public function getFamilyID():int {
			return user.base.family_id;
		}

		public function getTeamID():int {
			return user.base.team_id;
		}

		public function getRoleID():int {
			return user.base.role_id;
		}

		public function getRoleFactionID():int {
			return user.base.faction_id;
		}

		public function getRoleName():String {
			return user.base.role_name;
		}

		public function getGold():int {
			var gold:int=user.attr.gold + user.attr.gold_bind;
			return gold;
		}
		
		public function getSex():String{
			var sex:String="";
			switch(user.base.sex){
				case 1:
					sex = "男";
					break;
				case 2:
					sex = "女";
					break
			}
			return sex;
		}
		
		public function getLevel():int{
			return user.attr.level;
		}
		
		public function getFamilyName():String{
			return user.base.family_name;
		}

		public function addObject(name:String, value:Object, localSave:Boolean=false, errFunc:Function=null):void {
			if (localSave) {
				ShareObjectUtil.save(name, value, errFunc);
			}
		}

		public function getObject(name:String, fromLocal:Boolean=false, errFunc:Function=null):Object {

			var object:Object=ShareObjectUtil.read(name, errFunc);

			return object;
		}

		public var isAntiStealth:Boolean=false;
		public var loginData:m_login_flash_tos

		public function get isMount():Boolean {
			return user.attr.skin.mounts != 0;
		}

		public function isSameMount(mountID:int):Boolean {
			var l:int=user.attr.equips.length;
			for (var i:int=0; i < l; i++) {
				if (user.attr.equips[i].id == mountID)
					return true;
			}
			return false;
		}

		public function getMountID():int {
			var l:int=user.attr.equips.length;
			for (var i:int=0; i < l; i++) {
				if (user.attr.equips[i].loadposition == 15)
					return user.attr.equips[i].id;
			}
			return -1;
		}

		/**
		 * 攻击模式
		 */
		private var _attackMode:int=Constant.PEACE;

		public function get attackMode():int {
			return _attackMode;
		}

		public function set attackMode(value:int):void {
			_attackMode=value;
		}

		/**
		 * 被锁定的怪物id
		 */
		public var bagFull:Boolean;
		public var pickFailed:int; //捡失败的物品id
		public var location:MacroPathVo=new MacroPathVo(0, null);
		/**
		 * 玩家当前技能
		 */
		private var _currentSkill:SkillVO=new SkillVO;

		public function set currentSkill(value:SkillVO):void {
			_currentSkill=value;
		}

		public function get currentSkill():SkillVO {
			return _currentSkill;
		}

		private var _AutomaticSkill:SkillVO=new SkillVO;

		public function set AutomaticSkill(value:SkillVO):void {
			_AutomaticSkill=value;
		}

		public function get AutomaticSkill():SkillVO {
			return _AutomaticSkill;
		}

		/**
		 *玩家技能
		 */
		private var _currentSelectSkill:SkillVO;

		public function set currentSelectSkill(value:SkillVO):void {
			_currentSelectSkill=value;
		}

		public function get currentSelectSkill():SkillVO {
			return _currentSelectSkill;
		}

		//user对象暂时没有确定，暂定用object代替
		private var _user:p_role

		public function get user():p_role {
			return _user;
		}

		public function set user(value:p_role):void {
			_user=value;
		}
		public var bornPoint:Pt; //跳转地图时，先记录下下个地图的出生点

		private var _teamMembers:Array=[];

		public function set teamMembers(value:Array):void {
			_teamMembers=value;
		}

		public function get teamMembers():Array {
			return _teamMembers;
		}

		//////添加其他的共享类

		private static var _instance:GlobalObjectManager;
		public var formHandler:Function;
	}
}

class SigletonPress {
}