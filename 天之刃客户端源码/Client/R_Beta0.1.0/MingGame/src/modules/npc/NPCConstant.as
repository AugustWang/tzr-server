package modules.npc
{
	/**
	 * 对话相关常量定义 
	 * @author Administrator
	 * 
	 */		
	public class NPCConstant
	{
		public static const MISSION_ACCEPT:int = 1; //接受任务
		public static const MISSION_NEXT:int = 2; //任务继续(做)
		public static const MISSION_FINISH:int = 3;//完成任务
		public static const MISSION_NEXT_DIALOGUE:int = 4; //任务下一个对话
		public static const CLOSE:int = 5; //关闭
	
		/**
		 * 链接图标
		 */
		public static const LINK_ICON_STYLE_ACTION:int = 0;//功能NPC
		public static const LINK_ICON_STYLE_MISSION_ACCEPT:int = 1;//任务可接
		public static const LINK_ICON_STYLE_MISSION_NEXT:int = 2;//任务可接
		public static const LINK_ICON_STYLE_MISSION_FINISH:int = 3;//任务可接
		public static const LINK_ICON_STYLE_MISSION_ANSWER:int = 4;//任务可接
		
		//NPC事件前缀
		static public const NPC_ACTION_PREFIX:String = 'NPCAction_';
		
		//npc 自动打开面板的距离
		public static const NPC_AUTO_DISTANCE:int = 6;
		
		//开封车夫
		public static const NPC_KAI_FENG_CHE_FU_ID:int = 10200100;
		
		//京城铁匠ID
		public static const NPC_JING_CHENG_TIE_JIANG_ID:Object = {'1':11100114, '2':12100114, '3':13100114};
		
		public function NPCConstant()
		{
		}
	}
}