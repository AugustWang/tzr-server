package modules.chat.vo
{
	public class TitlesVo
	{
		/*<!--type 场景角色头顶的，用不用图片，假设0不用图片，　1是用图片的-->
	<!--chatType 是否显示在聊天频道，0表示不显示，1表示显示-->
	<!--color 称号的色值-->
	<!--url 场景图片路径，留空表示没有-->	
	<!--mark 分别对应不同的符号 1表示“★” 2表示“❤”-->   */
		//<title id="100001" name="沧州王" type="0" chatType="1" color="FFFF00" url="" mark="1" />
		public var name:String;
		public var id:int;
		public var type:int;
		public var chatType:int;
		public var color:String ;
		public var url:String;
		public  var mark:int; // String 
		public function TitlesVo()
		{
			
		}
	}
}