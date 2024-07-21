package com.scene.sceneUnit {
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUtils.MoveSpeedMath;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.utils.HtmlUtil;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.pet.PetDataManager;
	import modules.pet.config.PetConfig;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;
	
	import proto.common.p_map_pet;
	import proto.common.p_skin;


	/**
	 * 宠物类
	 * 接收指令，然后执行相应动作
	 * @author LXY
	 *
	 */
	public class Pet extends MutualAvatar {
		protected var roleName:RoleNameItem;
		protected var petName:RoleNameItem;
		protected var petTitle:RoleNameItem;
		private var skin:p_skin;
		private var $pvo:p_map_pet;
		public var curState:int;
		/////////
		protected var masPos:Pt;
		protected var masDir:int;
		protected var startTime:int;
		protected var endTime:int;
		protected var startX:Number;
		protected var startY:Number;
		protected var tarX:Number;
		protected var tarY:Number;
		protected var curSpeedX:Number;
		protected var curSpeedY:Number;

		////////////////
		protected var noMastarCount:int;

		public function Pet() {
			super();
			sceneType=SceneUnitType.PET_TYPE;
		}

		public function reset(p:p_map_pet):void {
			id=p.pet_id;
			$pvo=p;
			isDead=false;
			var color:String=GameColors.getHtmlColorByIndex(p.color);
			if (p.color == 4) {
				color="#9B52FF";
			}
			var mas:Role=SceneUnitManager.getUnit(p.role_id) as Role;

			if (roleName == null) {
				roleName=new RoleNameItem;
				this.addChild(roleName);
			}
			if (petName == null) {
				petName=new RoleNameItem();
				this.addChild(petName);
			}
			if (petTitle == null) {
				petTitle=new RoleNameItem();
				this.addChild(petTitle);
			}
			if (mas != null) {
				masPos=new Pt(mas.index.x, 0, mas.index.z);
				masDir=mas.dir;
				if (mas.pvo && mas.pvo.faction_id != GlobalObjectManager.getInstance().user.base.faction_id) { //同国
					color="#FF00AA";
				}
				roleName.setHtmlText(HtmlUtil.font("(" + mas.pvo.role_name + "的宠物)", "#ffffff"));
				petName.setHtmlText(HtmlUtil.font(p.pet_name, color));
				petTitle.setHtmlText(HtmlUtil.font(p.title, color));
			} else {
				Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, "宠物：" + p.pet_name + "找不到主人");
				return; //找不到主人
			}
			skin=new p_skin;
			skin.skinid=PetConfig.getPetSkin(p.type_id);
			if (skin.skinid == 0) {
				throw new Error("找不到类型为：" + p.type_id + "的宠物")
				return;
			}
			if (avatar == null) {
				super.initSkin(skin)
			} else {
				avatar.updataSkin(skin);
				avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
				avatar._bodyLayer.filters=[];
			}

			curState=RoleActState.NORMAL;
			normal();
			var nowTile:Pt=TileUitls.getIndex(new Point(this.x, this.y));
			setWeak(isAlphaCell(nowTile));
			LoopManager.addToFrame(this, loop);
			glowEffect();
		}
		
		private var _glowEffect:Thing
		private function glowEffect():void{
			if(pvo.type_id == 30051009 || pvo.type_id == 30051010){
				avatar._bodyLayer.filters = [new GlowFilter(0xfbc95e,0.6,20,20,2,1)];
				if(!_glowEffect){
					_glowEffect = new Thing();
					_glowEffect.load(GameConfig.EFFECT_PET_PATH + "dlh.swf");
					_glowEffect.play(4,true);
					_glowEffect.y = -100;
					avatar._effectLayerTop.addChild(_glowEffect);
				}
			}else if(pvo.type_id == 30051019 || pvo.type_id == 30051020){
				if(!_glowEffect){
					_glowEffect = new Thing();
					_glowEffect.load(GameConfig.EFFECT_PET_PATH + "bh.swf");
					_glowEffect.play(4,true);
					//_glowEffect.y = -100;
					avatar._effectLayerBottom.addChild(_glowEffect);
				}
			}else if(pvo.type_id == 30051029 || pvo.type_id == 30051030){
				avatar._bodyLayer.filters = [new GlowFilter(0xfa99dd,0.6,20,20,2,1)];
				if(!_glowEffect){
					_glowEffect = new Thing();
					_glowEffect.load(GameConfig.EFFECT_PET_PATH + "dlh.swf");
					_glowEffect.play(4,true);
					_glowEffect.y = -100;
					avatar._effectLayerTop.addChild(_glowEffect);
				}
			}
			
		}

		override protected function onBodyComplete(e:DataEvent):void {
//			super.onBodyComplete(e);
			roleName.y=-int(e.data) - 20;
			petName.y=roleName.y - 18;
			petTitle.y=petName.y - 18;
		}

		//主要用于走路
		private function loop():void {
			if (curState == RoleActState.NORMAL) { //当前空闲，
				doNextMove();
			} else if (curState == RoleActState.RUNING) {
				exeMove();
			} else if (curState == RoleActState.FIGHT) {

			} else if (curState == RoleActState.DEAD) {

			}
		}

		private function exeMove():void {
			var nowTime:int=getTimer();
			if (nowTime >= endTime) {
				this.x=tarX;
				this.y=tarY;
				onArriveRunEnd();
			} else {
				var passTime:Number=(nowTime - startTime) / 1000;
				this.x=startX + curSpeedX * passTime;
				this.y=startY + curSpeedY * passTime;
				onMoving();
			}
		}

		private function doNextMove():void {
			var mas:Role=SceneUnitManager.getUnit(pvo.role_id) as Role;
			if (mas != null) {
				var masIndex:Pt=mas.index;
				if (masIndex.key != masPos.key || mas.dir != masDir) { //主人的位置或方向有发生变化
					curState=RoleActState.RUNING; //状态变为走路
					masPos.x=masIndex.x;
					masPos.z=masIndex.z;
					masDir=mas.dir;
					var tarPt:Pt=ScenePtMath.getPetPt(masIndex, mas.dir, 2);
					var tarPoint:Point=TileUitls.getIsoIndexMidVertex(tarPt);
					startX=this.x;
					startY=this.y;
					tarX=tarPoint.x;
					tarY=tarPoint.y;
					var dir:int=getDretion(tarX, tarY);
					startTime=getTimer();
					var distance:Number=Point.distance(new Point(startX, startY), new Point(tarX, tarY));
					var realSpeed:Number=MoveSpeedMath.getRealSpeed(mas.pvo.move_speed, dir);
					var needTime:Number=distance / realSpeed;
					curSpeedX=(tarX - startX) / needTime;
					curSpeedY=(tarY - startY) / needTime;
					endTime=int(needTime * 1000) + startTime;
					this.play(AvatarConstant.ACTION_WALK, dir, PetDataManager.getWalkSpeed(skin.skinid));
				} else {
					//主人没动(位置和方向都没变)
					onArriveRunEnd();
				}
				if (noMastarCount != 0) {
					noMastarCount=0;
				}
			} else {
				noMastarCount++;
				if (noMastarCount > 100) { //100次找不到主人
					this.remove();
				}
			}
		}

		private function onArriveRunEnd():void { //走完了或者着长期不动都一直执行
			if (curState != RoleActState.NORMAL) {
				curState=RoleActState.NORMAL;
				var mas:Role=SceneUnitManager.getUnit(pvo.role_id) as Role;
				if (mas) {
					var masIndex:Pt=mas.index;
					if (masIndex.key == masPos.key && mas.dir == masDir) { //主人的位置或方向有发生变化
						this.play(AvatarConstant.ACTION_STAND, mas.dir, PetDataManager.getStandSpeed(skin.skinid));
					}
				}
			}
		}

		override public function play($state:String, dir:int, $speed:int):void {
			super.play($state, dir, $speed);
		}

		private function onMoving():void {
			setWeak(isAlphaCell(this.index));
		}

		override public function turnDir(_dir:int=4):void {
			dir=_dir;
			var skinid:int=PetConfig.getPetSkin(pvo.type_id);
			this.play(AvatarConstant.ACTION_STAND, dir, PetDataManager.getStandSpeed(skinid));
		}


		public function set pvo(value:p_map_pet):void {
			$pvo=value;
		}

		public function get pvo():p_map_pet {
			return $pvo;
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				if (SceneCheckers.checkIsEnemy(this) == true) {
					CursorManager.getInstance().setCursor(CursorName.ATTRACK);
				}
			}
		}

		override public function mouseOut():void {
			super.mouseOut();
			CursorManager.getInstance().clearAllCursor();
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}

		override public function remove():void {
			super.remove();
			LoopManager.removeFromFrame(this);
			UnitPool.disposePet(this);
			if(_glowEffect){
				_glowEffect.stop();
				if(_glowEffect.parent){
					_glowEffect.parent.removeChild(_glowEffect);
				}
				_glowEffect = null;
			}
			$pvo=null;
		}
	}
}
