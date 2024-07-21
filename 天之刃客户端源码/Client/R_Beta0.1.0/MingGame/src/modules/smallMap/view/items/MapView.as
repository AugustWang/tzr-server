package modules.smallMap.view.items {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.scene.WorldManager;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUnit.Waiter;
	import com.scene.sceneUnit.YBC;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import modules.ModuleCommand;
	import modules.friend.FriendsConstants;
	import modules.friend.FriendsManager;
	import modules.scene.SceneDataManager;
	import modules.smallMap.SmallMapDataManager;
	import modules.smallMap.view.RadarView;
	
	import proto.common.p_map_role;
	import proto.common.p_role_base;

	public class MapView extends Sprite {
		private var shapeMonster:Shape; //怪物
		private var shapeNPC:Shape; //npc 圈 
		private var shapeOtherFaction:Shape; //别国
		private var shapeMyFaction:Shape; //本国
		private var shapeSNPC:Shape; //后台NPC
		private var shapePet:Shape; //宠物
		private var shapeSelf:Shape; //画自己
		private var shapeYBC:Shape; //画骠车
		private var city:CityVo;
		private var scale:Number;
		private var bmd:BitmapData;
		private var $rect:Rectangle;
		private var _firendAndEnemyInfo:Object;
		private var shape:Shape;
		private var mapBMP:Bitmap;
		private var shapeRoad:Shape;
		private var isRoadFinish:Boolean=true;
		private var roadEndPoint:Pt; //路的终点
		private var enemyIds:Array=[];
		private var friendIds:Array=[];

		public function MapView() {
			super();
			mapBMP=new Bitmap();
			this.addChild(this.mapBMP);
//			mapBMP.filters=[new BlurFilter(2, 2)];
			shapeMonster=makeShape(); //怪物
			shapeNPC=makeShape(); //npc 圈 
			shapeOtherFaction=makeShape();
			shapeMyFaction=makeShape();
			shapeSNPC=makeShape();
			shapePet=makeShape();
			shapeYBC=makeShape();
			shapeRoad=makeShape();
			shapeSelf=makeShape();
			shapeRoad.filters=[new GlowFilter(0x4c4432, 1, 2, 2,20)];
			this.mouseChildren = false;
			LoopManager.addToFrame(this, loop);
			addEventListener(MouseEvent.CLICK,mapClickHandler);
		}

		
		private function mapClickHandler(event:MouseEvent):void{
			var mx:Number=mapBMP.mouseX;
			var my:Number=mapBMP.mouseY;
			var cx:Number= mx/scale - SceneDataManager.offsetX;
			var cy:Number= my/scale - SceneDataManager.offsetY;
			var pt:Pt=TileUitls.getIndex(new Point(cx, cy));
			var runvo:RunVo = new RunVo();
			runvo.pt=pt;
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, runvo);
		}
		
		private function makeShape():Shape {
			var s:Shape=new Shape;
			this.addChild(s);
			return s;
		}

		public function changeView(map_id:int, value:BitmapData):void {
			shapeNPC.graphics.clear();
			this.bmd=value;
			mapBMP.bitmapData=value;
			scale=value.width / SceneDataManager.mapData.width;
			city=WorldManager.getCurrentCity();
			var npcArr:Array=SceneDataManager.npcs;
			for (var i:int; i < npcArr.length; i++) {
				var npc:MapElementVo=npcArr[i];
				var pt:Pt=new Pt(npc.tx, 0, npc.ty)
				var point:Point=TileUitls.getIsoIndexMidVertex(pt);
				point.x=(point.x + SceneDataManager.offsetX) * scale;
				point.y=(point.y + SceneDataManager.offsetY) * scale;
				draw(point.x, point.y, 9, 4, shapeNPC);
			}
			maxRect.width = value.width;
			maxRect.height = value.height;
			oldX=-100;
			oldY=-100;
		}
		
		private var oldX:int=-100,oldY:int=-100;
		private function loop():void {
			var hero:MyRole=SceneUnitManager.getSelf();
			if (hero && (oldX != hero.x || oldY != hero.y)) {
				centerCamera(hero.x, hero.y);
				oldX = hero.x;
				oldY = hero.y;
				updataPoints();
				var pt:Pt=SceneDataManager.getMyPostion().pt;
				RadarView(this.parent).posTxt.text="[" + pt.x + "," + pt.z + "]";
			}
		}
		
		private var maxRect:Rectangle = new Rectangle(0,0,0,0);
		private var viewRect:Rectangle = new Rectangle(0,0,136,136);
		public function centerCamera(herox:Number, heroy:Number):void {		
			var hx:Number=(herox + SceneDataManager.offsetX) * scale;
			var hy:Number=(heroy + SceneDataManager.offsetY) * scale;
			var viewX:Number,viewY:Number;
			viewX = Math.min(maxRect.width-viewRect.width,hx-viewRect.width/2);
			viewX = Math.max(0,viewX);
			
			viewY = Math.min(maxRect.height-viewRect.height,hy-viewRect.height/2);
			viewY = Math.max(0,viewY);
			
			x = -viewX+18;
			y = -viewY+2;
			viewRect.x = viewX;
			viewRect.y = viewY;
	
		}

		//把点填充到点上
		private function draw(px:Number, py:Number, bit:int, size:int, shape:Shape):void {
			var round:BitmapData=SmallMapDataManager.getBit(bit);
			var mt:Matrix=new Matrix;
			mt.tx=px - size;
			mt.ty=py - size;
			shape.graphics.beginBitmapFill(round, mt, false);
			shape.graphics.drawCircle(px, py, size);
			shape.graphics.endFill();
		}

		//如果在同一个点有层次关系到，从最上层到最下层顺序（自身、宠物、移动NPC、本国、敌国、NPC、怪物）
		//point_arr装的颜色的顺序：0.紫、1.粉红、2.红、3.深蓝、4.绿、5.黑、6浅蓝.、7.白、8.朱红、9.黄、10.橙、11.青
		public function updataPoints():void {
			if(city == null)return;
			shapeMonster.graphics.clear();
			shapeOtherFaction.graphics.clear();
			shapeMyFaction.graphics.clear();
			shapeSNPC.graphics.clear();
			shapePet.graphics.clear();
			shapeSelf.graphics.clear();
			shapeYBC.graphics.clear();
			var myBase:p_role_base=GlobalObjectManager.getInstance().user.base;
			//var rect:Rectangle;
			friendIds=FriendsManager.getInstance().getIdsByType(FriendsConstants.FRIENDS_TYPE);
			enemyIds=FriendsManager.getInstance().getIdsByType(FriendsConstants.ENEMY_TYPE);
			var point:Point;
			var px:Number,py:Number;
			for (var s:String in SceneUnitManager.unitHash) {
				var tar:IMutualUnit=SceneUnitManager.unitHash[s];
				point=TileUitls.getIsoIndexMidVertex(tar.index);
				px=(point.x + SceneDataManager.offsetX) * city.scale;
				py=(point.y + SceneDataManager.offsetY) * city.scale;
				//rect=new Rectangle(15 - this.x, 55 - this.y, 110, 110);
				if (viewRect.contains(px, py) == true) {
					if (tar is YBC) { //===采集点（浅蓝色）
//						draw(px, py, 11, 2, shapeMyFaction);
					}
					if (tar is Monster) { //===怪物(红色)
						draw(px, py, 2, 2, shapeMonster);
					}
					if (tar is ServerNPC) { //后台NPC
						draw(px, py, 9, 4, shapeSNPC);
					}
					if (tar is Role && Role(tar).pvo != null) { //====人包括敌国玩家和同国玩家
						var pvo:p_map_role=Role(tar).pvo;
						if (pvo.faction_id != myBase.faction_id) { //===敌国  黑色
							if (enemyIds.indexOf(pvo.role_id) != -1) { //仇人（大红点）
								draw(px, py, 2, 5, shapeOtherFaction);
							} else {
								draw(px, py, 5, 3, shapeOtherFaction);
							}
						} else { //===同国
							if (pvo.team_id == myBase.team_id && pvo.team_id != 0 && myBase.team_id != 0) { //队友(大绿点)
								draw(px, py, 4, 5, shapeMyFaction);
							} else if (pvo.family_id == myBase.family_id && pvo.family_id != 0 && myBase.family_id != 0) { //门派(浅蓝色)
								draw(px, py, 6, 3, shapeMyFaction);
							} else if (friendIds.indexOf(pvo.role_id) != -1) { //好友（橙色）
								draw(px, py, 10, 3, shapeMyFaction);
							} else if (enemyIds.indexOf(pvo.role_id) != -1) { //仇人（大红点）
								draw(px, py, 2, 5, shapeMyFaction);
							} else { //同国(白点)
								draw(px, py, 7, 4, shapeMyFaction);
							}
						}
					}
					if (tar is Waiter) { //===店小二(白色)
						draw(px, py, 7, 3, shapeMyFaction);
					}
					if (tar is Pet) { //===宠物

					}
					if (tar is Collection) { //===宠物
						draw(px, py, 11, 2, shapeMonster);
					}
					if (tar is MyRole) { //===宠物
						draw(px, py, 3, 5, shapeSelf);
						isRoadFinish=(roadEndPoint == null || tar.index.key == roadEndPoint.key);
						if (isRoadFinish == true) {
							shapeRoad.graphics.clear();
							roadEndPoint=null;
						}
					}
				}
			}
		}

		public function drawMyPath(path:Array):void {
			shapeRoad.graphics.clear();
			path.unshift(SceneDataManager.getMyPostion().pt); 
			shapeRoad.graphics.lineStyle(2, 0xff0000, 1, false, LineScaleMode.VERTICAL, CapsStyle.NONE, JointStyle.ROUND, 3);
			for (var i:int=0; i < path.length - 1; i++) {
				drawDashed(shapeRoad.graphics, ptToRadarPoint(path[i]), ptToRadarPoint(path[i + 1]));
			}
			roadEndPoint=path[path.length - 1];
			isRoadFinish=false;
			shapeRoad.graphics.beginFill(0x00ff00,1);
			var p:Point=ptToRadarPoint(roadEndPoint);
			shapeRoad.graphics.drawCircle(p.x, p.y,3);
		}

		//画虚线
		private function drawDashed(graphics:Graphics, p1:Point, p2:Point, length:Number=5, gap:Number=5):void {
			var max:Number=Point.distance(p1, p2);
			var l:Number=0;
			var p3:Point;
			var p4:Point;
			graphics.lineStyle(1, 0xffff00);
			while (l < max) {
				p3=Point.interpolate(p2, p1, l / max);
				l+=length;
				if (l > max)
					l=max
				p4=Point.interpolate(p2, p1, l / max);
				graphics.moveTo(p3.x, p3.y)
				graphics.lineTo(p4.x, p4.y)
				l+=gap;
			}
		}

		private function ptToRadarPoint(pt:Pt):Point {
			var scaleValue:Number=WorldManager.getCurrentCity().scale;
			var point:Point=TileUitls.getIsoIndexMidVertex(pt);
			point.x=(point.x + SceneDataManager.offsetX) * scaleValue;
			point.y=(point.y + SceneDataManager.offsetY) * scaleValue;
			return point;
		}
	}
}