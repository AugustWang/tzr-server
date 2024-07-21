package com.scene.sceneUnit {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.scene.GameScene;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.scene.tile.gameAstar.Node;
	import com.utils.HtmlUtil;

	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;

	import proto.common.p_map_server_npc;
	import proto.common.p_skin;

	public class ServerNPC extends MutualAvatar {
		///////以下变量用于走路/////////
		protected var path:Array;
		protected var _speed:int;
		protected var startTime:int;
		protected var endTime:int;
		protected var startX:Number;
		protected var startY:Number;
		protected var tarX:Number;
		protected var tarY:Number;
		protected var curSpeedX:Number;
		protected var curSpeedY:Number;
		/////////////////
		private var _pvo:p_map_server_npc;
		private var nameTxt:RoleNameItem;
		private var titleTxt:RoleNameItem;
		private var lastTile:Pt;
		public var runEnd:Boolean=true;

		public function ServerNPC() {
			super();
			this.sceneType=SceneUnitType.SERVER_NPC_TYPE;
		}

		public function reset(vo:p_map_server_npc):void {
			id=vo.npc_id;
			_pvo=vo;
			speed=vo.move_speed;
			isDead=false;
			if (nameTxt == null) {
				nameTxt=new RoleNameItem();
				addChild(nameTxt);
			}
			if (titleTxt == null) {
				titleTxt=new RoleNameItem();
				addChild(titleTxt);
			}
			var skin:p_skin=new p_skin;
			if (vo.npc_type == 1) { //讨伐敌营
				skin.skinid=10026;
				titleTxt.visible=true;
				titleTxt.setHtmlText(HtmlUtil.font("讨伐敌营副本传送人", "#ffffff"));
			} else { //真人
				var serverNPCVO:Object=MonsterConfig.getServerNPCByType(vo.type_id);
				if (serverNPCVO == null) {
					throw new Error("怪物类型:" + vo.type_id + "找不到配置资料");
					return;
				}
				skin.skinid=serverNPCVO.skinid;
				titleTxt.visible=false;
			}
			nameTxt.setHtmlText(HtmlUtil.font(vo.npc_name, "#ffffff"));
			titleTxt.y=nameTxt.y - 18;
			runEnd=true;
			avatar == null ? super.initSkin(skin) : avatar.updataSkin(skin);
			lastTile=new Pt(vo.pos.tx, 0, vo.pos.ty);
			setWeak(isAlphaCell(lastTile));
			createBuff(vo.state_buffs);
			LoopManager.addToFrame(this, loop);
			SceneDataManager.setNodeWalk(vo.pos.tx, vo.pos.ty, false);
		}

		override protected function onBodyComplete(e:DataEvent):void {
			super.onBodyComplete(e);
			nameTxt.y=-int(e.data) - 30;
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

		public function set pvo(vo:p_map_server_npc):void {
			if (this.isStop)
				return;
			if (vo == null)
				return;
			if (vo.type_id == 0)
				return;
			speed=vo.move_speed;
			if (_pvo.npc_name != vo.npc_name) {
				nameTxt.setHtmlText(vo.npc_name);
			}
			_pvo=vo;
			createBuff(vo.state_buffs);
		}

		public function get pvo():p_map_server_npc {
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


		override public function die():void {
			super.die();
			SceneDataManager.setNodeWalk(index.x,index.z, true);
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				if (isDialogNPC() == false) {
					CursorManager.getInstance().setCursor(CursorName.ATTRACK);
				} else {
					CursorManager.getInstance().setCursor(CursorName.HAND);
				}
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

		override public function remove():void {
			super.remove();
			SceneDataManager.setNodeWalk(index.x,index.z, true);
		}

		public function isDialogNPC():Boolean {
			if (pvo == null || pvo.npc_type == 1) {
				return true;
			}
			return false;
		}

	}
}
