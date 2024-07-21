package modules.friend.views.vo
{
	public class GroupVO
	{
		public var id:String; //群Id
		public var name:String; //群名称
		public var online_num:int; //在线人数
		public var total_num:int; //总人数
		public var inited:Boolean = false; //是否被初始化
		public var type:int; //群类型，see GroupType
		public function GroupVO()
		{

		}
	}
}