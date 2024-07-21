package modules.npc.vo
{

	/**
	 * 封装NPC对话所需要的数据列表 
	 */	
	public class NPCPannelVO
	{
		/**
		 * NPC 唯一标识符
		 */		
		public var npcId:int;
		/**
		 * NPC 名称 （可用于NPC面板做标题显示）
		 */		
		public var npcName:String;
		
		/**
		 * 功能链接 
		 */		
		public var actionLinks:Vector.<NpcLinkVO>;
		
		/**
		 * 任务链接 
		 */	
		public var missionLinks:Vector.<NpcLinkVO>;
		
		public var content:String;
		
		public function NPCPannelVO()
		{
		}
	}
}