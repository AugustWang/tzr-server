package com.scene.sceneUtils
{
	import com.common.GlobalObjectManager;
	import com.scene.tile.Pt;
	
	import proto.common.p_map_role;
	import proto.common.p_map_tile;
	import proto.common.p_role;
	import proto.line.m_move_keystop_toc;
	import proto.line.m_move_keystop_tos;
	import proto.line.m_move_keywalk_toc;
	import proto.line.m_move_keywalk_tos;
	import proto.line.m_move_walk_path_toc;
	import proto.line.m_move_walk_path_tos;
	
	/**
	 * 路径VO的转换类
	 * @author LXY
	 *
	 */
	public class ConvertMath
	{
		
		public function ConvertMath()
		{
		}
		
		public static function getWalkPath_tos(vo:m_move_walk_path_toc):m_move_walk_path_tos
		{
			var _vos:m_move_walk_path_tos=new m_move_walk_path_tos;
			_vos.walk_path.bpx=vo.walk_path.bpx;
			_vos.walk_path.bpy=vo.walk_path.bpy;
			_vos.walk_path.epx=vo.walk_path.epx;
			_vos.walk_path.epy=vo.walk_path.epy;
			_vos.walk_path.path=ConvertMath.walkPath_pTile(vo.walk_path.path);
			return _vos;
		}
		
		public static function getWalkPath_toc(vo:m_move_walk_path_tos):m_move_walk_path_toc
		{
			var _voc:m_move_walk_path_toc=new m_move_walk_path_toc;
			_voc.walk_path.bpx=vo.walk_path.bpx;
			_voc.walk_path.bpy=vo.walk_path.bpy;
			_voc.walk_path.epx=vo.walk_path.epx;
			_voc.walk_path.epy=vo.walk_path.epy;
			_voc.walk_path.path=ConvertMath.walkPath_pt(vo.walk_path.path);
			return _voc;
		}
		
		/**
		 * 将p_map_tile路径转为Pt路径
		 * @param arr
		 * @return
		 *
		 */
		public static function walkPath_pt(arr:Array):Array
		{
			var ptArr:Array=[];
			for (var i:int=0; i < arr.length; i++)
			{
				var pt:Pt=new Pt(arr[i].tx, 0, arr[i].ty);
				ptArr.push(pt);
			}
			return ptArr;
		}
		
		public static function walkPath_pTile(arr:Array):Array
		{
			var pTileArr:Array=[];
			for (var i:int=0; i < arr.length; i++)
			{
				var ptile:p_map_tile=new p_map_tile;
				ptile.tx=arr[i].x;
				ptile.ty=arr[i].z;
				pTileArr.push(ptile);
			}
			return pTileArr;
		}
		
		/**
		 * 把完整路径弄成拐点路径
		 * @param arr
		 * @return
		 *
		 */
		public static function sortPath(arr:Array):Array
		{
			var pt:Pt;
			var dir:int=-1;
			var sortArr:Array=[arr[0]];
			for (var i:int=1; i < arr.length; i++)
			{
				pt=arr[i - 1];
				var dir1:int=nextTileDir(pt, arr[i]);
				if (dir == -1)
				{
					dir=dir1;
					continue;
				}
				if (dir1 != dir)
				{
					sortArr.push(arr[i - 1]);
					dir=dir1;
				}
			}
			if (arr[arr.length - 1].key != sortArr[sortArr.length - 1].key)
				sortArr.push(arr[arr.length - 1]);
			return sortArr;
		}
		
		/**
		 * 把拐点路径恢复成完整路径
		 * @param arr
		 * @return
		 *
		 */
		public static function revertPath(arr:Array):Array
		{
			if (arr.length == 0)
			{
				return arr;
			}
			var pt:Pt=arr[0];
			var j:int;
			var dir:int;
			var path:Array=[arr[0]];
			var newPt:Pt;
			for (var i:int=1; i < arr.length; i++)
			{
				var npt:Pt=arr[i];
				var t1:int=npt.x - pt.x;
				var t2:int=npt.z - pt.z;
				if (t1 == 0 && t2 > 0)
				{ //往左下
					for (j=0; j <= npt.z - pt.z; j++)
					{
						newPt=new Pt(pt.x, 0, pt.z + j);
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							path.push(newPt);
					}
				}
				else if (t1 == 0 && t2 < 0)
				{ //往右上
					for (j=0; j <= pt.z - npt.z; j++)
					{
						newPt=new Pt(pt.x, 0, pt.z - j)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							
							path.push(newPt);
					}
				}
				else if (t2 == 0 && t1 > 0)
				{ //往右下
					for (j=0; j <= npt.x - pt.x; j++)
					{
						newPt=new Pt(pt.x + j, 0, pt.z)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							
							path.push(newPt);
					}
				}
				else if (t2 == 0 && t1 < 0)
				{
					//往左上
					for (j=0; j <= pt.x - npt.x; j++)
					{
						newPt=new Pt(pt.x - j, 0, pt.z)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							
							path.push(newPt);
					}
				}
				else if (t1 < 0 && t2 < 0)
				{ //往上
					for (j=0; j <= Math.abs(npt.x - pt.x); j++)
					{
						newPt=new Pt(pt.x - j, 0, pt.z - j)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							
							path.push(newPt);
					}
				}
				else if (t1 > 0 && t2 > 0)
				{ //往下
					for (j=0; j <= Math.abs(npt.x - pt.x); j++)
					{
						newPt=new Pt(pt.x + j, 0, pt.z + j)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							
							path.push(newPt);
					}
				}
				else if (t1 < 0 && t2 > 0)
				{ //往左
					for (j=0; j <= Math.abs(npt.x - pt.x); j++)
					{
						newPt=new Pt(pt.x - j, 0, pt.z + j)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							
							path.push(newPt);
					}
				}
				else if (t1 > 0 && t2 < 0)
				{ //往右
					for (j=0; j <= Math.abs(npt.x - pt.x); j++)
					{
						newPt=new Pt(pt.x + j, 0, pt.z - j)
						if (path.length == 0 || (path[path.length - 1].key != newPt.key))
							path.push(newPt);
					}
				}
				pt=npt;
			}
			return path;
		}
		
		/**
		 * 计算下一个相对于当前格的方向
		 * @param pt 当前格
		 * @param npt下一格
		 *   0
		 *  7 1
		 * 6   2
		 *  5 3
		 *   4
		 * @return
		 *
		 */
		public static function nextTileDir(pt:Pt, npt:Pt):int
		{
			var t1:int=npt.x - pt.x;
			var t2:int=npt.z - pt.z;
			switch (t1)
			{
				case-1:
					switch (t2)
					{
						case-1:
							return 0;
						case 0:
							return 7;
						case 1:
							return 6;
					}
				case 0:
					switch (t2)
					{
						case-1:
							return 1;
						case 0:
							return -1;
						case 1:
							return 5;
					}
				case 1:
					switch (t2)
					{
						case-1:
							return 2;
						case 0:
							return 3;
						case 1:
							return 4;
					}
			}
			return -1;
		}
		
		public static function getMapRole():p_map_role
		{
			var p:p_role=GlobalObjectManager.getInstance().user;
			var map:p_map_role=new p_map_role;
			map.role_id=p.base.role_id
			map.role_name=p.base.role_name;
			map.faction_id=p.base.faction_id;
			map.cur_title=p.base.cur_title;
			map.family_id=p.base.family_id;
			map.family_name=p.base.family_name;
			map.pos=p.pos.pos;
			map.hp=p.fight.hp;
			map.max_hp=p.base.max_hp;
			map.mp=p.fight.mp;
			map.max_mp=p.base.max_mp;
			map.skin=p.attr.skin;
			map.move_speed=p.base.move_speed;
			map.team_id=p.base.team_id;
			map.level=p.attr.level;
			map.pk_point=p.base.pk_points;
			map.state=p.base.status;
			map.gray_name=p.base.if_gray_name;
			map.state_buffs=p.base.buffs;
			map.show_cloth=p.attr.show_cloth;
			return map;
		}
	}
}