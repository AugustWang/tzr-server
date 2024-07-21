package com.scene.sceneUnit {
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.gs.Linear;
	import com.gs.TweenMax;
	import com.managers.Dispatch;
	import com.scene.GameScene;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.scene.tile.gameAstar.Node;
	import com.utils.HtmlUtil;

	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;

	import modules.ModuleCommand;
	import modules.scene.SceneDataManager;
	import modules.scene.cases.MyRoleControler;

	import proto.common.p_map_ybc;
	import proto.common.p_skin;

	/**
	 * 动物类，所有人，怪，宠物的基类
	 * @author LXY
	 *
	 */
	public class YBC extends Animal {
		protected var $pvo:p_map_ybc;
		protected var nameTxt:RoleNameItem;

		public function YBC() {
			super();
			this.sceneType=SceneUnitType.YBC_TYPE;
		}

		public function reset(vo:p_map_ybc):void {
			id=vo.ybc_id;
			speed=vo.move_speed;
			$pvo=vo;
			if (nameTxt == null) {
				nameTxt=new RoleNameItem();
				addChild(nameTxt);
			}
			var color:String;
			if (vo.create_type == 1) {
				color=GameColors.getHtmlColorByIndex(vo.color);
			} else if (vo.group_type == 2) {
				if (vo.create_type == 1) {
					color=GameColors.getHtmlColorByIndex(1);
				} else if (vo.create_type == 2) {
					color=GameColors.getHtmlColorByIndex(3);
				}
			}
			nameTxt.setHtmlText(HtmlUtil.font(vo.name, color));
			var skin:p_skin=new p_skin;
			//group_type,1是g个人，2，门派，3,组队
			if (vo.group_type == 1) {
				skin.skinid=20010;
				skin.weapon=20011;
			} else if (vo.group_type == 2) {
				skin.skinid=20000;
			} else {
				skin.skinid=20000;
			}
			if (avatar) {
				avatar._bodyLayer.filters=[];
				avatar.addEventListener(Avatar.BODY_COMPLETE, onBodyComplete);
				avatar.updataSkin(skin);
			} else {
				super.initSkin(skin);
			}
			this.isDead=false;
			this.enabled=true;
			curState=RoleActState.NORMAL;
			normal();
			lastTile=new Pt(vo.pos.tx, 0, vo.pos.ty);
			if (vo.group_type == 1) {
				var martix:Array=GameColors.color(vo.color);
				var cf:ColorMatrixFilter=new ColorMatrixFilter(martix);
				avatar.addWeaponEffect([cf]);
			}
			LoopManager.addToFrame(this, loop);
			SceneDataManager.setNodeWalk(vo.pos.tx, vo.pos.ty, false);
		}

		override protected function onBodyComplete(e:DataEvent):void {
			//super.onBodyComplete(e);
			nameTxt.y=-int(e.data) - 20;
		}

		public function set pvo(value:p_map_ybc):void {
			$pvo=value;
		}

		public function get pvo():p_map_ybc {
			return $pvo;
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}

		override protected function changeCell(curPt:Pt):void {
			SceneDataManager.setNodeWalk(lastTile.x,lastTile.z, true); //上一格
			SceneDataManager.setNodeWalk(curPt.x,curPt.z, false);
			super.changeCell(curPt);
		}

		override public function die():void {
			super.die();
			SceneDataManager.setNodeWalk(index.x,index.z, true);
		}

		override public function remove():void {
			if ((pvo.group_type == 1 && pvo.creator_id == GlobalObjectManager.getInstance().user.base.role_id) || (pvo.group_type == 2 && pvo.group_id == GlobalObjectManager.getInstance().user.base.family_id)) {
				Dispatch.dispatch(ModuleCommand.YBC_CLEAR); //我的镖车,清除小地图上的点
			}
			super.remove();
			UnitPool.disposeYBC(this);
			$pvo=null;
			SceneDataManager.setNodeWalk(index.x,index.z, true);
		}
	}
}