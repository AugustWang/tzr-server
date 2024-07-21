package modules.smallMap.vo
{
	import flash.geom.Point;
	
	import proto.common.p_map_role;
	import proto.line.p_team_role;

	/**
	 * 
	 * @author 地图元素的所有信息
	 * 
	 */	
	public class MapRoleVo
	{
		public var type:int = -1;
		public var pvo:Object

		public function MapRoleVo(){}

		public function name():String{
			if (this.pvo is p_map_role){
				return p_map_role(pvo).role_name;
			}
			return ''
		}
	}
}