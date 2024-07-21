package com.scene.sceneData
{

	import com.common.GlobalObjectManager;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;
	
	import proto.common.p_map_role;
	import proto.line.p_team_role;


	public class MapRoleVo
	{
//		1	人
//      2   怪物
//      3   宠物
//		4        移动NPC
		public var type:int;
		public var pos:Point;
		public var pvo:Object

		public function MapRoleVo()
		{
		}

		public function name():String
		{
			if (this.pvo is p_map_role)
			{
				return p_map_role(pvo).role_name;
			}
			return ''
		}

		public function temeToMap(vo:p_team_role):void
		{
			type=SceneUnitType.ROLE_TYPE;
			pos=TileUitls.getIsoIndexMidVertex(new Pt(vo.tx, 0, vo.ty));
			pvo=new p_map_role;
			pvo.role_id=vo.role_id;
			pvo.role_name=vo.role_name;
			pvo.team_id=GlobalObjectManager.getInstance().user.base.team_id;
			pvo.faction_id=GlobalObjectManager.getInstance().user.base.faction_id;
		}
	}
}