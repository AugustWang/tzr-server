package com.scene.sceneUnit {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.scene.sceneData.NPCVo;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.SceneUnitType;
	
	import modules.heroFB.HeroFBModule;
	import modules.mission.MissionDataManager;
	import modules.mission.vo.MissionVO;
	import modules.npc.NPCConstant;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;

	public class NPC extends MutualThing {
		public var pvo:NPCVo;
		private var _nameTxt:RoleNameItem;
		private var _jobTxt:RoleNameItem;
		private var _inited:Boolean;
		private var _sign:Thing;

		public function NPC(vo:NPCVo):void {
			super();
			addShadow();
			id=vo.id;
			sceneType=SceneUnitType.NPC_TYPE;
			pvo=vo;
		}

		public function startUp():void {
			if (this._inited == false) {
				this._inited=true;
				init(GameConfig.ROOT_URL + "com/npcs/" + pvo.skinId + ".swf");
			}
		}

		override public function init(skinURL:String):void {
			super.init(skinURL);
			filterNPC();
			this._nameTxt=new RoleNameItem(pvo.name);
			this._nameTxt.y=-this.height - 20;
			this._nameTxt.textColor=0xffff00;
			this._jobTxt=new RoleNameItem(pvo.job);
			this._jobTxt.textColor=0xffff00;
			this._jobTxt.y=_nameTxt.y - 18;
			this.updateSign();
			addChild(this._nameTxt);
			addChild(this._jobTxt);
		}
		
		private function filterNPC():void{
			if(pvo){
				_thing.play(8,true);
			}
		}
		
		public function set seeable(value:Boolean):void{
			this._seeable = value;
			if(this._seeable == true){
				this.updateSign();
			}
		}
		
		/**
		 * 标记是否需要更新头像标记
		 */
		public function set needUpdateMissionSign(value:Boolean):void{
			this._needUpdateMissionSign = value;
			if(this._seeable == true){
				this.updateSign();
			}
		}
		
		private var _missionStatus:int = 0;
		private var _needUpdateMissionSign:Boolean = true;
		private var _seeable:Boolean = false;
		
		
		public function removeSign(status:int=0):void{
			if (_sign != null) {
				if (_sign.parent) {
					_sign.parent.removeChild(_sign);
				}
				
				_sign.unload();
				_sign=null;
			}
			this._missionStatus = status;
			this._needUpdateMissionSign = true;
		}
		
		/**
		 * 更新标记
		 */
		private function updateSign():void{
			if(this._inited == false || this._needUpdateMissionSign == false || this._seeable == false){
				return;
			}
			
			var npcMissionIDList:Array = MissionDataManager.getInstance().getNpcMissionIDListSorted(this.pvo.id);
			
			var oldMissionStatus:int = this._missionStatus;
			if(npcMissionIDList && npcMissionIDList[0]){
				var missionID:int = npcMissionIDList[0];
				var missionVO:MissionVO = MissionDataManager.getInstance().getNpcMissionList(this.pvo.id)[missionID];
				this._missionStatus = missionVO.currentStatus;
			}else{
				this._missionStatus = 0;
			}
			
			if(oldMissionStatus == this._missionStatus){
				return;
			}
			
			this.removeSign(this._missionStatus);
			
			this._needUpdateMissionSign = false;
			
			switch (this._missionStatus) {
				
				case NPCConstant.MISSION_ACCEPT:
					_sign=new Thing;
					addChild(_sign);
					
					_sign.load(this.getMissionSignPath('tanhao'));
					_sign.gotoAndStop(0);
					addChild(_sign);
					_sign.y=-150;
					break;
				
				case NPCConstant.MISSION_FINISH:
					_sign=new Thing;
					addChild(_sign);
					
					_sign.load(this.getMissionSignPath('wenhao'));
					_sign.gotoAndStop(0);
					addChild(_sign);
					_sign.y=-150;
					break;
				
				case NPCConstant.MISSION_NEXT:
					_sign=new Thing;
					addChild(_sign);
					
					_sign.load(this.getMissionSignPath('talk'));
					_sign.gotoAndStop(2);
					addChild(_sign);
					_sign.y=-150;
					break;
					
				default:
					break;
			}
		}

		/**
		 * 获取任务标记的路径字符串
		 */
		private function getMissionSignPath(sign:String):String {
			return GameConfig.ROOT_URL+ 'com/ui/other/npc_'+sign+'.swf';
		}
		
		
		override protected function onLoadComplete(e:ThingsEvent):void {
			super.onLoadComplete(e);
			_nameTxt.y=-int(e.data) - 20;
			_jobTxt.y=_nameTxt.y - 18;
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false &&
				HeroFBModule.isOpenHeroFBPanel == false) {
				
				CursorManager.getInstance().setCursor(CursorName.TALK);
			}
		}

		override public function mouseOut():void {
			super.mouseOut();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().clearAllCursor();
			}
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}


	}
}