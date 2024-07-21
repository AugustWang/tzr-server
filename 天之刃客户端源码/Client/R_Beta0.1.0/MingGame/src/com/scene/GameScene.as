package com.scene {
	import com.common.GlobalObjectManager;
	import com.common.cursor.BaseCursor;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.managers.Dispatch;
	import com.scene.sceneData.BinaryMath;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneKit.MouseIcon;
	import com.scene.sceneKit.RoleImageTitle;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.RoadManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Planting;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.effect.SceneEffect;
	import com.scene.sceneUnit.map.Map;
	import com.scene.sceneUtils.HitTester;
	import com.scene.sceneUtils.RoadCounter;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.sceneUtils.Slice;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	import com.scene.tile.gameAstar.MCAstar;
	import com.scene.tile.gameAstar.MapGrid;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastView;
	import modules.heroFB.HeroFBModule;
	import modules.roleStateG.RoleStateDateManager;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.FightCase;
	import modules.scene.cases.MoveCase;
	import modules.skill.SkillModule;

	public class GameScene extends Sprite {
		public var mapGrid:MapGrid;
		public var astar:MCAstar;
		private static var _instance:GameScene;
		public var map:Map;
		private var tileTestLayer:Sprite;
		public var lowEffLayer:Sprite;
		public var midLayer:Sprite;
		public var highEffLayer:Sprite;
		public var topLayer:Sprite;
		public var signLayer:Sprite;
		public var hero:MyRole;
		public var heroXED:Number=0;
		public var heroYED:Number=0;
		private var mouseUnit:IMutualUnit;
		private var roadCounter:RoadCounter;
		private var mapClickAbled:Boolean=true; //鼠标是否可以点击走路
		private var mouseIcon:MouseIcon=MouseIcon.instance; //走路终点标志
		private var mapClickKey:int;
		private var enterFrameNum:int;
		private var isRollOver:Boolean = false;
		
		public function GameScene() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		}

		public static function getInstance():GameScene {
			if (_instance == null) {
				_instance=new GameScene;
			}
			return _instance;
		}

		public function reset(bgPath:String):void {
			var mapVO:MapDataVo=SceneDataManager.mapData;
			if (map == null) {
				map=new Map;
				if (map.parent == null) {
					this.parent.addChildAt(map, 0);
				}
			}
			if (tileTestLayer == null) {
				tileTestLayer=new Sprite;
				addChild(tileTestLayer);
			}
			if (signLayer == null) {
				signLayer=new Sprite;
				addChild(signLayer);
			}
			if (lowEffLayer == null) {
				lowEffLayer=new Sprite;
				addChild(lowEffLayer);
			}
			if (midLayer == null) {
				midLayer=new Sprite;
				addChild(midLayer);
			}
			if (highEffLayer == null) {
				highEffLayer=new Sprite;
				addChild(highEffLayer)
			}
			if (topLayer == null) {
				topLayer=new Sprite;
				addChild(topLayer);
			}

			var ox:int=mapVO.offsetX;
			var oy:int=mapVO.offsetY;
			signLayer.x=tileTestLayer.x=tileTestLayer.x=lowEffLayer.x=midLayer.x=highEffLayer.x=topLayer.x=ox;
			signLayer.y=tileTestLayer.y=tileTestLayer.y=lowEffLayer.y=midLayer.y=highEffLayer.y=topLayer.y=oy;
			map.createBlur(bgPath);
			mapGrid=new MapGrid(mapVO);
			astar=new MCAstar(mapGrid);
			tileTestLayer.addChild(mouseIcon);
			LoopManager.addToFrame(this, onSceneEnterFrame);
			if (GlobalObjectManager.getInstance().bornPoint) {
				var p:Point=TileUitls.getIsoIndexMidVertex(GlobalObjectManager.getInstance().bornPoint);
				centerCamera(p.x, p.y);
			}
//			reSetTile(mapVO);
		}

		override public function set x(value:Number):void {
			super.x=value;
			if (map)
				map.x=value;
		}

		override public function set y(value:Number):void {
			super.y=value;
			if (map)
				map.y=value;
		}


		private function onAddedStage(e:Event):void {
			roadCounter=new RoadCounter;
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
			this.parent.addEventListener(MouseEvent.MOUSE_DOWN, onSceneMouseDown);
			this.parent.addEventListener(MouseEvent.MOUSE_UP, onSceneMouseUp);
			addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			addEventListener(MouseEvent.ROLL_OUT,onRollOut);
//			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown); 不明真相 暂时无视
		}
		
		private function onRollOver(event:MouseEvent):void{
			isRollOver = true;
		}
		
		private function onRollOut(event:MouseEvent):void{
			isRollOver = false;
			if (mouseUnit != null) {
				mouseUnit.mouseOut();
				mouseUnit=null;
			}
			if (SceneModule.isLookInfo == false && SceneModule.isFollowFoot == false && mouseIcon.isRoading == false) {
				CursorManager.getInstance().clearAllCursor();
			}
		}
		
		/**
		 * 自动寻路
		 *
		 */
		public function autoRoad():void {
			roadCounter.updataTimes();
			//按住鼠标时的寻路
			if (hero != null && roadCounter.time >= 1000) {
				mouseIcon.freezing(true, this.midLayer.mouseX, this.midLayer.mouseY);
				if (mapClickAbled) { //这个不再设置成false了，控制防止连续点走路，改在MYROLE里面的underControl来控制
					var mousePt:Pt=TileUitls.getIndex(new Point(mouseIcon.x, mouseIcon.y));
					var dir:int=ScenePtMath.getDretion(hero.index, mousePt);
					var tarPt:Pt=ScenePtMath.getDirDisPt(hero.index, dir, 10);
					hero.runToPoint(tarPt);
					LoopManager.clearTimeout(mapClickKey);
					mapClickKey=LoopManager.setTimeout(function setClickAbled():void {
							mapClickAbled=true;
						}, 600);
				}
			}
		}

//		private function onStageMouseDown(e:MouseEvent):void {
//			if (e.target == stage) {
//				onClickMap();
//			}
//		}

		private function onSceneMouseDown(e:MouseEvent):void {
			if ((mouseUnit == null || mouseUnit.sceneType == SceneUnitType.TRAP_TYPE) && HeroFBModule.isOpenHeroFBPanel == false) {
				onClickMap();
			} else if (mouseUnit != null && HeroFBModule.isOpenHeroFBPanel == false) {
				mouseUnit.mouseDown();
			}
			if (SceneModule.isLookInfo == true) {
				SceneModule.getInstance().toLookInfo();
			}
			if (SceneModule.isFollowFoot == true) {
				SceneModule.getInstance().toFollow();
			}
		}

		public function onClickMap():void {
			RoadManager.clear();
			if (hero) {
				if (CursorManager.getInstance().currentCursor == CursorName.SELECT_TARGET) {
					SkillModule.getInstance().skillToTarget(hero); //选择技能后就去打
					return;
				}
				switch (hero.pvo.state) {
					case RoleActState.STALL:
						Dispatch.dispatch(ModuleCommand.SELETED_STALL, hero.pvo.role_id);
						return;
					case RoleActState.TRAINING:
						Dispatch.dispatch(ModuleCommand.OPEN_TRAIN);
						return;
				}
				var dragTime:int=roadCounter.time;
				roadCounter.reset();
				var tarPt:Pt=TileUitls.getIndex(new Point(this.midLayer.mouseX, this.midLayer.mouseY));
				hero.runToPoint(tarPt);
				hero.showAutoRun(false);
				if (mapClickAbled) { //这个不再设置成false了，控制防止连续点走路，改在MYROLE里面的underControl来控制
					mapClickAbled=false;
					LoopManager.clearTimeout(mapClickKey);
					mapClickKey=LoopManager.setTimeout(function setClickAbled():void {
							mapClickAbled=true;
						}, 600);
				} else { //不能点时
					if (SceneModule.isAutoHit == true) { //取消自动打怪
						SceneModule.getInstance().toAutoHitMonster();
					}
				}
				mouseIcon.reset(new Point(this.midLayer.mouseX, this.midLayer.mouseY));
				MoveCase.getInstance().follow_id=-1;
			}
		}

		private function onSceneMouseUp(e:MouseEvent):void {
			roadCounter.enabled=false;
		}
	
		public function clearRoadCounter():void{
			roadCounter.enabled=false;
		}

		private function onSceneEnterFrame():void {
			enterFrameNum++;
			if (enterFrameNum % 2 == 0) {
				doTargetMouse();
			}
			if (enterFrameNum % 20 == 0) {
				if (LoopManager.realRate > 24) {
					resetDepth();
				}
			}
			if (enterFrameNum >= 60)
				enterFrameNum=0;
		}

		private function doTargetMouse():void {
			if(isRollOver == false)return;
			var arr:Array=this.stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
			for (var i:int=arr.length - 1; i >= 0; i--) {
				var child:DisplayObject=arr[i];
				if (this.parent.contains(child) == false) { //鼠标在面板上或在鼠标样式上
					if ((child is TextField || child is Shape || child is Bitmap) && HitTester.checkIsTypeClass(child, [BaseCursor, MouseIcon, BroadcastView, SceneEffect, RoleImageTitle]) == false) {
						if (mouseUnit != null) {
							mouseUnit.mouseOut();
							mouseUnit=null;
						}
						return;
					}
				}
				var tar:IMutualUnit=HitTester.checkMutualUnit(child, [RoleImageTitle]);
				if (tar == null)
					continue;
				if (HitTester.hitTest(tar, new Point(midLayer.mouseX, midLayer.mouseY)) == true) {

					if (mouseUnit == tar) {
						return;
					} else {
						if (mouseUnit != null)
							mouseUnit.mouseOut();
						mouseUnit=tar;
						mouseUnit.mouseOver();
					}
					return;
				}
			}
			if (mouseUnit != null) {
				mouseUnit.mouseOut();
				mouseUnit=null;
			}
			if (SceneModule.isLookInfo == true && CursorManager.getInstance().currentCursor != CursorName.MAGNIFIER) {
				CursorManager.getInstance().setCursor(CursorName.MAGNIFIER);
				return;
			}
			if (SceneModule.isFollowFoot == true && CursorManager.getInstance().currentCursor != CursorName.FOLLOW) {
				CursorManager.getInstance().setCursor(CursorName.FOLLOW);
				return;
			}
			if (mouseUnit == null && SceneModule.isLookInfo == false && SceneModule.isFollowFoot == false && mouseIcon.isRoading == false) {
				CursorManager.getInstance().clearAllCursor();
			}
		}


		public function addUnit(unit:IMutualUnit, tx:int, ty:int, dir:int=4):void {
			var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(tx, 0, ty));
			unit.x=p.x;
			unit.y=p.y;
			if (unit is MutualAvatar) { //如果是动物就初始化方向
				(unit as MutualAvatar).turnDir(dir);
			}
			if (unit is Role) {
				MutualAvatar(unit).hideAvatar=SceneModule.isHideRole;
			}
			if (unit is Planting) {
				this.tileTestLayer.addChild(unit as DisplayObject);
			} else {
				midLayer.addChild(unit as DisplayObject);
			}
			SceneUnitManager.addUnit(unit);
			if (unit is MyRole) {
				hero=unit as MyRole;
				centerCamera(hero.x, hero.y);
				Map.centerHero=true;
				Map.heroMoving=true;
			}
		}

		public function removeUnit(id:int, type:int=SceneUnitType.ROLE_TYPE):void {
			var dic:Dictionary=SceneUnitManager.unitHash;
			var unit:IMutualUnit=SceneUnitManager.removeUnit(id, type);
			if (unit != null) {
				//清除追击目标
				if (unit.unitKey == FightCase.getInstance().attackTargetKey) {
					FightCase.getInstance().attackTargetKey=""
				}
				if (RoleStateDateManager.seletedUnit && RoleStateDateManager.seletedUnit.key == unit.unitKey) { //清除被选头像
					Dispatch.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {see: false});
				}
				unit.remove();
			}
		}


		private function reSetTile(vo:MapDataVo):void {
			tileTestLayer.graphics.clear();
			var arr:Array;
			var cell:int;
			var color:uint;
			var colorLine:uint;
			var p:Point;
			for (var x:int=0; x < vo.tiles.length; x++) {
				arr=vo.tiles[x];
				for (var z:int=0; z < arr.length; z++) {
					cell=vo.tiles[x][z];
					if (BinaryMath.isExist(cell)) {
						color=BinaryMath.isRun(cell) ? 0xffff00 : 0xff0000;
							//					cell.draw(tileTestLayer.graphics, 0x000000, true, color);
//						p=TileUitls.getIsoIndexMidVertex(new Pt(x, 0, z));
//						tileTestLayer.graphics.lineStyle(1, 0x000000);
//						tileTestLayer.graphics.beginFill(color, 0.3);
//						tileTestLayer.graphics.moveTo(p.x, p.y - 22);
//						tileTestLayer.graphics.lineTo(p.x + 44, p.y);
//						tileTestLayer.graphics.lineTo(p.x, p.y + 22);
//						tileTestLayer.graphics.lineTo(p.x - 44, p.y);
//						tileTestLayer.graphics.lineTo(p.x, p.y - 22);
//						tileTestLayer.graphics.endFill();
					}
				}
			}
			drawSlice();
		}

		private function drawSlice():void {
			var w:int=Math.ceil(SceneDataManager.mapData.width / Slice.width);
			var h:int=Math.ceil(SceneDataManager.mapData.width / Slice.height);
			for (var i:int=0; i < w; i++) {
				for (var j:int=0; j < h; j++) {
					tileTestLayer.graphics.lineStyle(1, 0xffff00)
					tileTestLayer.graphics.drawRect(i * Slice.width - SceneDataManager.mapData.offsetX, j * Slice.height - SceneDataManager.mapData.offsetY, Slice.width, Slice.height);
				}
			}
		}


		public function centerCamera(herox:Number, heroy:Number):void {
			movableCamera(herox,heroy);
//			if (heroXED != herox || heroYED != heroy) {
//				heroXED=herox;
//				heroYED=heroy;
//				herox+=SceneDataManager.mapData.offsetX;
//				heroy+=SceneDataManager.mapData.offsetY;
//				var w:int=GlobalObjectManager.GAME_WIDTH;
//				var h:int=GlobalObjectManager.GAME_HEIGHT;
//				var halfW:Number=w >> 1; //* 0.5;
//				var halfH:Number=h >> 1; //* 0.5;
//				var mapWidth:int=SceneDataManager.mapData.width;
//				var mapHeight:int=SceneDataManager.mapData.height;
//				if (herox >= halfW && herox <= mapWidth - halfW) {
//					this.x=halfW - herox;
//				} else if (herox < halfW) {
//					this.x=0;
//				} else if (herox > mapWidth - halfW) {
//					this.x=w - mapWidth;
//				}
//
//				if (heroy >= halfH && heroy <= mapHeight - halfH) {
//					this.y=halfH - heroy;
//				} else if (heroy < halfH) {
//					this.y=0;
//				} else if (heroy > mapHeight - halfH) {
//					this.y=h - mapHeight;
//				}
//				if (GlobalObjectManager.GAME_WIDTH > mapWidth && this.x != 0) {
//					this.x=0;
//				}
//				if (GlobalObjectManager.GAME_HEIGHT > mapHeight && this.y != 0) {
//					this.y=0;
//				}
//			}
		}

		private var movableRect:Rectangle=new Rectangle(0, 0, 150, 150);
		private var viewRect:Rectangle=new Rectangle(0, 0, 0, 0);

		private function movableCamera(herox:Number, heroy:Number):void {
			viewRect.width=GlobalObjectManager.GAME_WIDTH;
			viewRect.height=GlobalObjectManager.GAME_HEIGHT;
			viewRect.x=Math.abs(map.x);
			viewRect.y=Math.abs(map.y);
			movableRect.x=viewRect.x + (viewRect.width - movableRect.width >> 1);
			movableRect.y=viewRect.y + (viewRect.height - movableRect.height >> 1);
			var focusX:int=herox + SceneDataManager.mapData.offsetX;
			var focusY:int=heroy + SceneDataManager.mapData.offsetY;
			var leftoutX:Number=focusX - movableRect.x;
			if (leftoutX < 0) {
				viewRect.x=viewRect.x + leftoutX;
			}
			var rightoutX:Number=focusX - (movableRect.x + movableRect.width);
			if (rightoutX > 0) {
				viewRect.x=viewRect.x + rightoutX;
			}
			var topoutY:Number=focusY - movableRect.y;
			if (topoutY < 0) {
				viewRect.y=viewRect.y + topoutY;
			}
			var bottomoutY:Number=focusY - (movableRect.y + movableRect.height);
			if (bottomoutY > 0) {
				viewRect.y=viewRect.y + bottomoutY;
			}
			viewRect.x=Math.max(viewRect.x, 0);
			viewRect.x=Math.min(viewRect.x, SceneDataManager.mapData.width - viewRect.width);
			viewRect.y=Math.max(viewRect.y, 0);
			viewRect.y=Math.min(viewRect.y, SceneDataManager.mapData.height - viewRect.height);
			x=-viewRect.x;
			y=-viewRect.y;
		}

		public function getViewRect():Rectangle{
			return viewRect;
		}

		/**
		 * 深度排序
		 *
		 */
		protected function resetDepth():void {
			if (midLayer == null || midLayer.numChildren < 2) {
				return;
			}
			var arrForSort:Array=new Array(midLayer.numChildren);
			var t:int=getTimer();
			var l:int=arrForSort.length;
			for (var k:int=0; k < l; k++) {
				arrForSort[k]=midLayer.getChildAt(k);
			}
			//trace("数组组织时间:"+(getTimer()-t));
			arrForSort.sortOn(["y", "onlyKey"]);
			l=arrForSort.length;
			for (var i:int=0; i < l; i++) {
				if (this.midLayer.getChildIndex(arrForSort[i]) != i)
					midLayer.setChildIndex(arrForSort[i], i);
			}
		}


		public function clear():void {
			LoopManager.removeFromFrame(this);
			Map.centerHero=false;
			Map.heroMoving=false;
			if (hero) {
				hero.normal();
				hero=null;
			}
			if (map) {
				map.clear();
			}
			while (lowEffLayer && lowEffLayer.numChildren > 0) {
				lowEffLayer.removeChildAt(0);
			}
			while (midLayer && midLayer.numChildren > 0) {
				midLayer.removeChildAt(0);
			}
			while (highEffLayer && highEffLayer.numChildren > 0) {
				highEffLayer.removeChildAt(0);
			}
			while (topLayer && topLayer.numChildren > 0) {
				topLayer.removeChildAt(0);
			}
			while (tileTestLayer && tileTestLayer.numChildren > 0) {
				tileTestLayer.removeChildAt(0);
			}
			while (signLayer && signLayer.numChildren > 0) {
				signLayer.removeChildAt(0);
			}
			SceneUnitManager.clear();
		}

		public function addSign(arr:Array):void {
			for (var i:int=0; i < arr.length; i++) {
				var obj:DisplayObject=arr[i];
				signLayer.addChild(obj);
			}
		}

		public function clearSign():void {
			while (signLayer.numChildren > 0) {
				signLayer.removeChildAt(0);
			}
		}

		//添加景色
		public function addProspect(arr:Array):void {
			for (var i:int=0; i < arr.length; i++) {
				var obj:DisplayObject=arr[i];
				obj.x-=SceneDataManager.offsetX;
				obj.y-=SceneDataManager.offsetY;
				tileTestLayer.addChild(obj);
			}
		}
	}
}