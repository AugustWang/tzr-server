package com.scene.sceneUnit {
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUtils.MoveSpeedMath;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.scene.cases.MyRoleControler;
	
	import proto.common.p_skin;
	
	/**
	 *
	 * @author LXY
	 *
	 */
	public class Animal extends MutualAvatar {
		private var _curState:int;
		public var speed:Number;
		protected var path:Array;
		protected var lastTile:Pt;
		protected var tarPt:Pt;
		protected var runEnd:Boolean=true;
		///////以下变量用于走路/////////
		protected var startTime:int;
		protected var endTime:int;
		protected var startX:Number;
		protected var startY:Number;
		protected var tarX:Number;
		protected var tarY:Number;
		protected var curSpeedX:Number;
		protected var curSpeedY:Number;
		
		//////////以上///////////////
		public function Animal() {
			super();
		}
		
		public function set curState(value:int):void {
			if (_curState != value) {
				_curState=value;
				onCurStateChange();
			}
		}
		
		public function get curState():int {
			return _curState;
		}
		
		protected function onCurStateChange():void {

		}
		
		protected function loop():void {
			if(sitPlaying){
				moveAvatar();
			}
			switch (curState) {
				case RoleActState.NORMAL:
					return;
				case RoleActState.RUNING:
					exeMove();
					return;
				case RoleActState.FIGHT:
					return;
				case RoleActState.DEAD:
					return;
				case RoleActState.EXCHANGE:
					return;
				case RoleActState.ZAZEN:
					return;
				case RoleActState.STALL:
					return;
				case RoleActState.TRAINING:
					return;
				case RoleActState.COLLECTING:
					return;
				case RoleActState.ON_HOOK:
					return;
				default:
					return;
			}
		}
		
		private var step:int = -1;
		private function moveAvatar():void{
			boby.y += step;
			if(boby.y <= -30){
				step = 1;
			}else if(boby.y >= 0){
				step = -1;
			}
		}
		
		protected function exeMove():void {
			var nowTime:int=getTimer();
			var passTime:Number=(nowTime - startTime) / 1000;
			var temx:Number=this.x;
			var temy:Number=this.y;
			this.x=startX + curSpeedX * passTime;
			this.y=startY + curSpeedY * passTime;
			if (nowTime >= endTime) {
				this.x=tarX;
				this.y=tarY;
				if (path != null && path.length > 0) { //还有路没走完就继续走
					doNextMove();
				} else { //走完了路
					onArriveRunEnd();
				}
			}
			onMoving();
		}
		
		protected function doNextMove():void {
			if (path != null && path.length > 0) {
				curState=RoleActState.RUNING;
				tarPt=path.shift();
				var tarPoint:Point=TileUitls.getIsoIndexMidVertex(tarPt);
				startX=this.x;
				startY=this.y;
				tarX=tarPoint.x;
				tarY=tarPoint.y;
				var _dir:int=getDretion(tarX, tarY);
				dir=_dir;
				startTime=getTimer();
				var distance:Number=Point.distance(new Point(startX, startY), new Point(tarX, tarY));
				var realSpeed:Number=MoveSpeedMath.getRealSpeed(speed, dir);
				var needTime:Number=99999;
				if (realSpeed != 0) {
					needTime=distance / realSpeed;
				}
				curSpeedX=(tarX - startX) / needTime;
				curSpeedY=(tarY - startY) / needTime;
				endTime=int(needTime * 1000) + startTime;
				this.play(AvatarConstant.ACTION_WALK, dir, ThingFrameFrequency.RUN);
			}
		}
		
		protected function onArriveRunEnd():void {
			curState=RoleActState.NORMAL;
			normal();
		}
		
		/**
		 * 按照路径跑路
		 * @param vo
		 *
		 */
		public function run(path:Array):void {
			if (isDead == false) {
				this.path=path;
				doNextMove();
			}
		}
		
		protected function onMoving():void {
			var curPt:Pt=this.index;
			if (lastTile && lastTile.key != curPt.key) { //是否到达一个新的格子
				changeCell(curPt);
			}
		}
		
		
		/**
		 * 走到另外一个格子
		 *
		 */
		protected function changeCell(curPt:Pt):void {
			lastTile=index;
			setWeak(isAlphaCell(curPt));
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
		
		
		/**
		 * 角色换装
		 * @param garment 衣装id
		 *
		 */
		public function changeSkin(vo:p_skin):void {
			skinData=vo;
			avatar.updataSkin(vo);
		}
		
		
		override public function die():void {
			isDead=true;
			runEnd=true;
			curState=RoleActState.DEAD;
			LoopManager.setTimeout(delayDie, 800);
		}
		
		public function delayDie():void {
			this.play(AvatarConstant.ACTION_DIE, dir, ThingFrameFrequency.STAND);
			//			var mat:Array=[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]
			//			var cm:ColorMatrixFilter=new ColorMatrixFilter(mat);
			//			if (avatar != null)
			//				avatar._bodyLayer.filters=[cm];
		}
		
		/**
		 * 坐下，站立
		 * @param b，true坐，false站
		 *
		 */
		public function sitDown(b:Boolean):void {
			if (isDead) {
				return;
			}
			if (b) {
				play(AvatarConstant.ACTION_SIT, dir, ThingFrameFrequency.SIT);
			} else {
				if (avatar != null && avatar.selectState == AvatarConstant.ACTION_SIT) {
					play(AvatarConstant.ACTION_STAND, dir, ThingFrameFrequency.STAND);
				}
			}
		}
		
		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}
		
		override public function remove():void {
			super.remove();
			LoopManager.removeFromFrame(this);
		}
	}
}