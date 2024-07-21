package com.scene.sceneUnit {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.scene.GameScene;
	import com.scene.sceneKit.RoleNames;
	import com.scene.sceneKit.TrainingLight;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.scene.tile.gameAstar.Node;
	
	import flash.events.DataEvent;
	import flash.geom.Point;
	
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	
	import proto.common.p_map_role;
	
	public class Role extends Animal implements IRole {
		private var nowSlice:Point;
		private var names:RoleNames;
		private var training:TrainingLight;
		private var board:StallBoard;
		private var $pvo:p_map_role;
		
		public function Role() {
			super();
			sceneType=SceneUnitType.ROLE_TYPE;
		}
		
		public function reset(vo:p_map_role):void {
			this.isDead=vo.state == RoleActState.DEAD;
			curState=vo.state;
			id=vo.role_id;
			speed=vo.move_speed; // == 0 ? 160 : p.move_speed;
			$pvo=vo;
			if (names == null) {
				names=new RoleNames($pvo);
				addChild(names);
			}
			names.setColor(0xffffff);
			if (avatar) {
				avatar._bodyLayer.filters=[];
				avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
				initAvatar();
				avatar.updataSkin($pvo.skin);
			} else {
				super.initSkin($pvo.skin);
			}
			avatar.isNude=!$pvo.show_cloth;
			hideAvatar=false;
			curState=vo.state;
			//			normal();
			lastTile=new Pt($pvo.pos.tx, 0, $pvo.pos.ty);
			doNameJob();
			createBuff($pvo.state_buffs);
			lastTile=TileUitls.getIndex(new Point(this.x, this.y));
			setWeak(isAlphaCell(lastTile));
			LoopManager.addToFrame(this, loop);
			SceneDataManager.setNodeWalk(vo.pos.tx, vo.pos.ty, false);
			checkEquipRing();
			checkMountRing();
		}
		
		override protected function initAvatar():void{
			avatar.isPerson = true;
			avatar.category = $pvo.category;
			avatar.sex = $pvo.sex;
		}
		
		override protected function onBodyComplete(e:DataEvent):void {
			//super.onBodyComplete(e);
			if (names)
				names.y=-int(e.data) - 25;
		}
		
		//管理名字显示和颜色,此函数由子类继承实现
		public function doNameJob():void {
			names.reset(pvo);
		}
		
		public function set pvo(vo:p_map_role):void {
			if ($pvo.state != RoleActState.TRAINING && vo.state == RoleActState.TRAINING) {
				doTraining(true);
			}
			if ($pvo.state == RoleActState.TRAINING && vo.state != RoleActState.TRAINING) {
				doTraining(false);
			}
			
			$pvo=vo;
			speed=$pvo.move_speed;
			createBuff($pvo.state_buffs);
			avatar.isNude=!$pvo.show_cloth;
			avatar.updataSkin($pvo.skin);
			names.reset($pvo);
			doNameJob();
			checkEquipRing();
			checkMountRing();
			checkCollectState();
		}
		
		private var _collectState:Thing
		
		protected function checkCollectState():void {
			if (pvo.state == RoleActState.COLLECTING) {
				if (!_collectState) {
					_collectState=new Thing();
					_collectState.load(GameConfig.MOUSE_ICON_PATH + "shouji.swf");
					_collectState.gotoAndStop(0);
					addChild(_collectState);
					_collectState.y=-150;
				}
			} else {
				if (_collectState) {
					_collectState.unload();
					_collectState=null;
				}
			}
		}
		
		public function showCloth(value:Boolean):void {
			if (value == true) {
				if ($pvo && $pvo.show_cloth == true) {
					avatar.isNude=false;
				}
			} else {
				avatar.isNude=true;
			}
		}
		
		
		override public function play($state:String, $dir:int, $speed:int):void {
			super.play($state, $dir, $speed);
			if ($state == AvatarConstant.ACTION_ATTACK || $state == AvatarConstant.ACTION_ATTACK_ARROW || $state == AvatarConstant.
				ACTION_ATTACK_CASTING) {
				runEnd=true;
			}
			
			if (_equipRing) {
				if ($state == AvatarConstant.ACTION_SIT) {
					_equipRing.y=50;
				} else {
					_equipRing.y=0;
				}
			}
		}
		
		public function get pvo():p_map_role {
			return $pvo;
		}
		
		public function doTraining(value:Boolean):void {
			if (value == true) {
				curState=RoleActState.TRAINING;
				
				if (!training) {
					training=new TrainingLight;
				}
				addChildAt(training, 0);
			} else {
				curState=RoleActState.NORMAL;
				
				if (training)
					training.remove();
			}
			sitDown(value);
		}
		
		public function doStall(stall:Boolean, stallName:String=""):void {
			if (stall == true) {
				curState=RoleActState.STALL;
				if (board == null) {
					board=new StallBoard(stallName);
					board.y=-10;
				}
				if (this.contains(board) == false) {
					addChild(board);
				}
			} else {
				curState=RoleActState.NORMAL;
				if (board != null && this.contains(board) == true) {
					removeChild(board);
				}
			}
			sitDown(stall);
		}
		
		public function doHook(value:Boolean):void {
			if (value == true) {
				curState=RoleActState.ON_HOOK;
				if (training == null) {
					training=new TrainingLight();
				}
				addChildAt(training, 0);
			} else {
				curState=RoleActState.NORMAL;
				if (training != null) {
					training.remove();
				}
			}
			sitDown(value);
		}
		
		private var effect:Effect;
		
		public function expresion(expresionId:int):void {
			//大表情
			if (effect && effect.parent) {
				effect.parent.removeChild(effect);
			}
			effect=new Effect();
			effect.show(GameConfig.FACE_PATH + expresionId + '.swf', 0, names.y - names.height - 10, this, 8, 0, true, 9000);
		}
		
		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false && SceneCheckers.checkIsEnemy(this)) {
				CursorManager.getInstance().setCursor(CursorName.ATTRACK);
			}
		}
		
		override public function mouseOut():void {
			super.mouseOut();
			CursorManager.getInstance().clearAllCursor();
		}
		
		override protected function changeCell(curPt:Pt):void {
			SceneDataManager.setNodeWalk(lastTile.x,lastTile.z, true);
			SceneDataManager.setNodeWalk(curPt.x,curPt.z, false);
			super.changeCell(curPt);
		}
		
		override public function die():void {
			super.die();
			SceneDataManager.setNodeWalk(index.x,index.z, true);
		}
		
		override public function remove():void {
			super.remove();
			UnitPool.disposeRole(this);
			$pvo=null;
			SceneDataManager.setNodeWalk(index.x,index.z, true);
		}
		
		public function checkEquipRing():void {
			if (pvo.show_equip_ring && pvo.equip_ring_color != 0) {
				showEquipRing(pvo.equip_ring_color);
			} else {
				hideEquipRing();
			}
		}
		
		private var _equipRing:Thing;
		public function showEquipRing(value:int):void {
			if (_equipRing) {
				var url:String;
				switch (value) {
					case 1:
						url=GameConfig.OTHER_PATH + 'zhuangbei_zise.swf';
						break;
					case 2:
						url=GameConfig.OTHER_PATH + 'zhuangbei_chengse.swf';
						break;
					case 3:
						url=GameConfig.OTHER_PATH + 'zhuangbei_jinse.swf';
						break;
				}
				if (url != _equipRing.path) {
					hideEquipRing();
				} else {
					return;
				}
			}
			_equipRing=new Thing();
			switch (value) {
				case 1:
					_equipRing.load(GameConfig.OTHER_PATH + 'zhuangbei_zise.swf');
					break;
				case 2:
					_equipRing.load(GameConfig.OTHER_PATH + 'zhuangbei_chengse.swf');
					break;
				case 3:
					_equipRing.load(GameConfig.OTHER_PATH + 'zhuangbei_jinse.swf');
					break;
			}
			_equipRing.play(8, true);
			addChild(_equipRing);
			if (avatar.selectState == AvatarConstant.ACTION_SIT) {
				_equipRing.y+=50;
			}
		}
		
		public function hideEquipRing():void {
			if (_equipRing) {
				_equipRing.stop();
				_equipRing.unload();
				_equipRing=null;
			}
		}
		
		public function checkMountRing():void {
			if (pvo.skin.mounts != 0) {
				showMountRing(pvo.mount_color);
			} else {
				hideMountRing();
			}
		}
		
		private var _mountRing:Thing;
		public function showMountRing(value:int):void{
			if (_mountRing) {
				var url:String;
				switch (value) {
					case 4:
						url=GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Zi.swf';
						break;
					case 5:
						url=GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Cheng.swf';
						break;
				}
				if (url != _mountRing.path) {
					hideMountRing();
				} else {
					return;
				}
			}
			_mountRing=new Thing();
			switch (value) {
				case 4:
					_mountRing.load(GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Zi.swf');
					break;
				case 5:
					_mountRing.load(GameConfig.ROOT_URL + 'com/ui/effect/mount/mount_Cheng.swf');
					break;
			}
			_mountRing.play(8, true);
			avatar._effectLayerBottom.addChild(_mountRing);
		}
		
		public function hideMountRing():void{
			if(_mountRing){
				_mountRing.stop();
				_mountRing.unload();
				_mountRing=null;
			}
		}
		
		override public function normal():void {
			super.normal();
			// 移除打坐光环
			if (training) {
				training.remove();
			}
			
			if (board && board.parent) {
				board.parent.removeChild(board);
			}
		}
		
		override protected function playSitEffect():void{
			super.playSitEffect();
			names.y = names.y - 30;
		}
		
		override protected function removeSitEffect():void{
			super.removeSitEffect();
			names.y = names.y + 30;
		}
	}
}