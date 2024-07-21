package com.scene.sceneUnit {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.effect.Tween;
	import com.globals.GameConfig;
	import com.managers.MusicManager;
	import com.scene.GameScene;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.scene.tile.gameAstar.Node;
	import com.utils.HtmlUtil;
	
	import flash.events.DataEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.playerGuide.PlayerGuideModule;
	import modules.playerGuide.TipsView;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;
	
	import proto.common.p_map_monster;
	import proto.common.p_skin;

	/**
	 * 动物类，所有人，怪，宠物的基类
	 * @author LXY
	 *
	 */
	public class Monster extends MutualAvatar {
		protected var _pvo:p_map_monster;
		protected var path:Array;
		///////以下变量用于走路/////////
		protected var _speed:int;
		protected var startTime:int;
		protected var endTime:int;
		protected var startX:Number;
		protected var startY:Number;
		protected var tarX:Number;
		protected var tarY:Number;
		protected var curSpeedX:Number;
		protected var curSpeedY:Number;
		//////
		protected var nameTxt:RoleNameItem;
		protected var titleTxt:RoleNameItem;
		protected var lastTile:Pt;
		protected var tipView:TipsView;
		public var runEnd:Boolean=true;

		public function Monster() {
			super();
			sceneType=SceneUnitType.MONSTER_TYPE;
		}

		public function reset(vo:p_map_monster):void {
			id=vo.monsterid;
			_pvo=vo;
			speed=vo.move_speed;
			isDead=false;
			path=[];
			var point:Point=TileUitls.getIsoIndexMidVertex(new Pt(vo.pos.tx, 0, vo.pos.ty));
			this.x=point.x;
			this.y=point.y;
			startX=0;
			startY=0;
			tarX=0;
			tarY=0;
			runEnd=true;
			var mt:MonsterType=MonsterConfig.hash[vo.typeid];
			if (mt == null) {
				throw new Error("怪物类型:" + vo.typeid + "找不到配置资料");
				return;
			}
			var skin:p_skin=new p_skin;
			skin.skinid=mt.skinid;
			var monsterType:MonsterType=(MonsterConfig.hash[vo.typeid] as MonsterType);
			if (nameTxt == null) {
				nameTxt=new RoleNameItem();
				addChild(nameTxt);
			}
			if (titleTxt == null) {
				titleTxt=new RoleNameItem();
				addChild(titleTxt);
			}
			var color:String=monsterType.rarityHtmlColor;
			nameTxt.setHtmlText(HtmlUtil.font(monsterType.monstername + "（" + monsterType.level + "级）", color));
			titleTxt.setHtmlText(HtmlUtil.font(monsterType.rarityName, color));
			monsterType.rarityName ? titleTxt.visible=true : titleTxt.visible=false;
			titleTxt.y=nameTxt.y - 18;
			if (avatar) {
				avatar.reset();
				avatar._bodyLayer.filters=[];
				avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
				avatar.updataSkin(skin);
			} else {
				super.initSkin(skin);
			}
			avatar.play(AvatarConstant.ACTION_STAND,0,ThingFrameFrequency.STAND,true);
			lastTile=new Pt(vo.pos.tx, 0, vo.pos.ty);
			setWeak(isAlphaCell(lastTile));
			createBuff(vo.state_buffs);
			LoopManager.addToFrame(this, loop);
			SceneDataManager.setNodeWalk(vo.pos.tx, vo.pos.ty, false);
			clearTipView();
		}
		
		override protected function onBodyComplete(e:DataEvent):void {
//			super.onBodyComplete(e);
			nameTxt.y=-int(e.data) - 20;
			titleTxt.y=nameTxt.y - 18;
		}

		private function loop():void {
			if (runEnd == true) { //不需要走路的时候，直接返回
				return;
			}
			var nowTime:int=getTimer();
			var passTime:Number=nowTime - startTime;
			this.x=startX + curSpeedX * passTime;
			this.y=startY + curSpeedY * passTime;
			onMoving();
			if (nowTime >= endTime) {
				this.x=tarX;
				this.y=tarY;
				doNextMove();
			}
		}

		protected function doNextMove():void {
			if (path != null && path.length > 0) {
				runEnd=false;
				var tarPoint:Point=TileUitls.getIsoIndexMidVertex(path.shift());
				var dis:Number=Point.distance(new Point(this.x, this.y), tarPoint);
				startX=this.x;
				startY=this.y;
				tarX=tarPoint.x;
				tarY=tarPoint.y;
				var _dir:int=getDretion(tarX, tarY);
				dir=_dir;
				startTime=getTimer();
				curSpeedX=(tarX - startX) / _speed; //怪物的这个speed跟人不一样，是指移到目的地的时间
				curSpeedY=(tarY - startY) / _speed;
				endTime=_speed + startTime;
				this.play(AvatarConstant.ACTION_WALK, dir, ThingFrameFrequency.RUN);
			} else {
				onArriveRunEnd();
			}
		}

		protected function onArriveRunEnd():void {
			runEnd=true;
			path=null;
			normal();
		}

		public function set pvo(vo:p_map_monster):void {
			if (this.isStop)
				return;
			if (vo == null)
				return;
			if (vo.typeid == 0)
				return;
			speed=vo.move_speed
			if (_pvo.monster_name != vo.monster_name) {
				nameTxt.setHtmlText(vo.monster_name);
			}
			_pvo=vo;
			speed=vo.move_speed;
			createBuff(vo.state_buffs);
		}

		public function get pvo():p_map_monster {
			return _pvo;
		}

		public function set speed(value:int):void {
			_speed=value;
			pvo.move_speed=_speed;
		}

		public function run(arr:Array):void {
			if (isDead == false) {
				path=arr;
				doNextMove();
			}
		}


		protected function onMoving():void {
			if (isStop)
				return;
			if (lastTile && lastTile.key != index.key) { //是否到达一个新的格子
				changeCell();
			}
		}

		/**
		 * 走到另外一个格子
		 *
		 */
		protected function changeCell():void {
			SceneDataManager.setNodeWalk(lastTile.x,lastTile.z, true); //上一格
			lastTile=index;
			SceneDataManager.setNodeWalk(lastTile.x,lastTile.z, false); //现在这格
			setWeak(isAlphaCell(lastTile)); //透明
		}

		/**
		 * 设置角色方向
		 * @param dx 角色面向的点的x坐标
		 * @param dy 角色面向的点的y坐标
		 *
		 */
		protected function setDretion(dx:Number, dy:Number):void {
			dir=getDretion(dx, dy);
		}

		override public function attack(attackType:String, _dir:int):void {
			runEnd=true;
			super.attack(attackType, _dir);
		}

		/**
		 * 远程攻击
		 * @param dir 方向
		 * @param skill 技能id
		 *
		 */
		protected function attackArrow(dir:int):void {
			if (isDead) {
				return;
			}

			dir=dir;
			this.play(AvatarConstant.ACTION_ATTACK_ARROW, dir, ThingFrameFrequency.ATTACK);
		}

		/**
		 * 角色换装
		 * @param garment 衣装id
		 *
		 */
		protected function changeSkin(vo:p_skin):void {
			avatar.updataSkin(vo);
		}
		
		//恶心
		public function addTipView(str:String):void{
			if(tipView == null){
				tipView = new TipsView();
			}
			var p:Point = avatar.getHurtPoint();
			tipView.x = 100;;
			tipView.y = -80;
			tipView.show(str,TipsView.LEFT);
			addChild(tipView);
		}
		
		//恶心
		private function clearTipView():void{
			if(tipView){
				tipView.remove();
				tipView = null;
			}
		}

		override public function say(words:String=null):void {
			if(words == null)
			{
				var monsterType:MonsterType=(MonsterConfig.hash[pvo.typeid] as MonsterType);
				if (monsterType.say != '') {
					var index:int=monsterType.say.split(",")[int(Math.random() * monsterType.say.split(",").length)]
					super.say(MonsterConfig.getSayById(index));
				}
			}
			else
			{
				super.say(words);
			}
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().setCursor(CursorName.ATTRACK);
			}
		}

		override public function mouseOut():void {
			if (isDead == false) {
				if (avatar != null) {
					if (this.avatar.filters != null || this.avatar.filters.length > 0) {
						this.avatar.filters=null;
					}
					this.avatar.cleanFilter();
					this.avatar._bodyLayer.filters = _filter;
				}
				if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
					CursorManager.getInstance().clearAllCursor();
				}
			}
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
			clearTipView();
		}

		override public function die():void {
			//super.die();
			playDeathEffect();
			//SceneDataManager.setNodeWalk(index.x,index.z, true);
			MusicManager.playSound(MusicManager.DIE);
		}
		
		protected function playDeathEffect():void{
			hitBack();
		}
		
		private function hitBack():void{
			var endX:int = GameScene.getInstance().hero.index.x,endZ:int=GameScene.getInstance().hero.index.z;
			var roleDir:int = GameScene.getInstance().hero.dir;
			var distance:int = 3;
			if(roleDir == 4){
				endZ += distance;
				endX += distance;
			}else if(roleDir == 5){
				endZ += distance;
			}else if(roleDir == 6){
				endX -= (distance-1);
				endZ += (distance-1);
			}else if(roleDir == 7){
				endX -= distance;
			}else if(roleDir == 0){
				endZ -= distance;
				endX -= distance;
			}else if(roleDir == 1){
				endZ -= distance;
			}else if(roleDir == 2){
				endX += (distance-1);
				endZ -= (distance-1);
			}else if(roleDir == 3){
				endX += distance;
			}
			var p:Point = TileUitls.getIsoIndexMidVertex(new Pt(endX,0,endZ));
			Tween.to(this,3,{x:p.x,y:p.y,onComplete:onHitBackComplete});
		}
		
		private function onHitBackComplete():void{
			var deathEffect:Effect = Effect.getEffect();
			deathEffect.show(GameConfig.OTHER_PATH+"/death.swf",x,y,GameScene.getInstance().highEffLayer,2);
			Tween.to(this.boby,10,{scaleX:0,scaleY:0,alpha:0,onComplete:playComplete});
		}
		
		private function playComplete():void{
			remove();
			this.boby.scaleX = this.boby.scaleY = this.boby.alpha = 1;
		}
		
		override public function remove():void {
			super.remove();
			LoopManager.removeFromFrame(this);
			UnitPool.disposeMonster(this);
			//SceneDataManager.setNodeWalk(index.x,index.z, true);
		}
	}
}