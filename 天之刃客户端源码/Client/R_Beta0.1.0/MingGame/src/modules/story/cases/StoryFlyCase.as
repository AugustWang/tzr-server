package modules.story.cases {
	import com.gs.TweenLite;
	import com.managers.LayerManager;
	import com.net.connection.Connection;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;
	
	import modules.scene.SceneDataManager;
	
	import proto.common.p_skin;
	import proto.line.m_map_transfer_tos;

	public class StoryFlyCase {
		private var flyAvatar:MutualAvatar;
		private var _targetPt:Pt;
		private var _completeFunc:Function;
		private var _dir:int;

		public function StoryFlyCase() {
		}

		public function init():void {

		}

		public function execute($targetPt:Pt,completeFunc:Function=null):void {
			_targetPt = $targetPt;
			_completeFunc = completeFunc;
			var $target:Point=TileUitls.getIsoIndexMidVertex(new Pt($targetPt.x, 0, $targetPt.z));
			var $source:Point=new Point(SceneUnitManager.getSelf().x, SceneUnitManager.getSelf().y);
			var $sourcePt:Pt=SceneUnitManager.getSelf().index;
			LayerManager.main.mouseEnabled = false;
			LayerManager.main.mouseChildren = false;
			SceneUnitManager.getSelf().visible=false; //隐藏自己
			flyAvatar=new MutualAvatar();
			var p:p_skin=new p_skin();
			p.skinid=10018;
			flyAvatar.id=999999;
			flyAvatar.sceneType=SceneUnitType.NPC_TYPE;
			flyAvatar.initSkin(p);
			flyAvatar.x = $source.x;
			flyAvatar.y = $source.y;
			flyAvatar.boby.y=60;
			var _y:int=$target.y - $source.y;
			var _x:int=$target.x - $source.x;
			GameScene.getInstance().addUnit(flyAvatar, $sourcePt.x, $sourcePt.z); //添加到舞台
			_dir = flyAvatar.getDretion($target.x,$target.y)
			flyAvatar.play(AvatarConstant.ACTION_WALK, _dir, 3);
			TweenLite.to(flyAvatar.boby,2,{y:0,onComplete:onFlyStart,onCompleteParams:[$target,$source]});
		}
		
		public function onFlyStart($target:Point,$source:Point):void{
			flyAvatar.play(AvatarConstant.ACTION_WALK, _dir, 2);
			var l:int=Point.distance($source,$target);
			var time:int=Math.max(2,l / 180);
			TweenLite.to(flyAvatar, time, {x: $target.x, y: $target.y, onUpdate: onUpdate, onComplete: onFlyDone});
		}
		
		public function onFlyDone():void{
			flyAvatar.play(AvatarConstant.ACTION_WALK, _dir, 3);
			TweenLite.to(flyAvatar.boby,2,{y:60,onComplete:onComplete});
		}

		public function onUpdate():void {
			GameScene.getInstance().centerCamera(flyAvatar.x, flyAvatar.y); //控制摄像头位置
			GameScene.getInstance().map.loadPieceForFly(flyAvatar.x, flyAvatar.y);
		}

		public function onComplete():void {
			SceneUnitManager.getSelf().visible=true;
			GameScene.getInstance().removeUnit(999999, SceneUnitType.NPC_TYPE);
			var vo:m_map_transfer_tos=new m_map_transfer_tos();
			vo.mapid=SceneDataManager.mapID;
			vo.tx=_targetPt.x;
			vo.ty=_targetPt.z;
			vo.change_type = 3;//免费
			Connection.getInstance().sendMessage(vo);
			LoopManager.setTimeout(function unlock():void{
				LayerManager.main.mouseEnabled = true;
				LayerManager.main.mouseChildren = true;
			},500);
			if(_completeFunc!=null){
				_completeFunc.call();
			}
		}
	}
}