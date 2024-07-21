package modules.mission {

	/**
	 * 任务相关常量定义
	 * @author Administrator
	 *
	 */
	public class MissionConstant {

		static public const STATUS_ACCEPT:int=1; //标识未接任务状态
		static public const STATUS_NEXT:int=2; //已接状态
		static public const STATUS_FINISH:int=3; //可提交状态
		
		static public const FIRST_STATUS:int=0; //模型第一个状态标识符

		static public const EFFECT_ACCEPT:String = 'jieshourenwu';//接受任务
		static public const EFFECT_CAN_FINISH:String = 'ketijiaorenwu';//可以提交
		static public const EFFECT_FINISH:String = 'wanchengrenwu';//交任务效果
		
		static public const TYPE_MAIN:int=1; //主线
		static public const MISSION_TYPE_BRANCH:int=2; //支线
		static public const TYPE_CIRCLE:int=3; //循环

		static public const LISTENER_TYPE_MONSTER:int=1; //侦听器里type=1表示是怪物侦听
		static public const LISTENER_TYPE_PROP:int=2; //侦听器里type=2表示是道具侦听
		static public const LISTENER_TYPE_SHOP_BUY_PROP:int=3; //在商店购买道具
		static public const MISSION_LISTENER_TYPE_ROLE_LEVEL:int=4; //玩家升等级

		static public const NPC_DIALOGUES_TYPE_INDEX:int=0; //任务复杂对话类型索引 即复杂对话数组的哪个位置是标识该对话的类型的
		static public const NPC_DIALOGUES_CONTENT_INDEX:int=1; //任务复杂对话类型--答题数据的描述字段
		static public const NPC_DIALOGUES_ANSWER_INDEX:int=2; //任务复杂对话类型--答题数据的答案字段
		static public const NPC_DIALOGUES_QUESTIONS_INDEX:int=3; //任务复杂对话类型--答题数据的题目字段
		static public const NPC_DIALOGUES_CHOOSE_NPC_LIST_INDEX:int = 2;//选择NPC类型的第3索引为npc列表 [npcID, 描述]
		
		static public const NPC_DIALOGUES_TYPE_NORMAL:int=0; //普通字符串
		static public const NPC_DIALOGUES_TYPE_QUESTION:int=1; //答题
		static public const NPC_DIALOGUES_TYPE_CHOOSE_NPC:int=2; //选择NPC

		/**============守边任务相关配置--开始============**/
		/**
		 * 守边任务最低等级
		 */
		static public const SHOU_BIAN_MIN_LEVEL:int=1;

		/**
		 * 守边任务最高等级
		 */
		static public const SHOU_BIAN_MAX_LEVEL:int=200;

		/**
		 * 守边任务等待状态
		 */
		static public const SHOU_BIAN_STATUS_WAIT:int=1;
		/**
		 * 守边任务成功状态
		 */
		static public const SHOU_BIAN_STATUS_SUCC:int=2;
		/**
		 * 守边任务超时状态
		 */
		static public const SHOU_BIAN_STATUS_TIMEOUT:int=3;
		static public const SHOU_BIAN_TIMER_KEY:String='MISSION_SHOU_BIAN_TIMER_KEY';
		/**============守边任务相关配置--结束============**/

		/**============分组任务相关配置--开始============**/
		/**
		 * 分组任务最低等级
		 */
		static public const GROUP_MISSION_MIN_LEVEL:int=1;
		/**
		 * 分组任务最高等级
		 */
		static public const GROUP_MISSION_MAX_LEVEL:int=200;
		/**============分组任务相关配置--结束============**/

		/**============刺探任务相关配置--开始============**/
		/**
		 * 刺探任务最低等级
		 */
		static public const CI_TAN_MIN_LEVEL:int=1;
		/**
		 * 刺探任务最高等级
		 */
		static public const CI_TAN_MAX_LEVEL:int=200;
		static public const CI_TAN_STATUS_DOING:int=1;
		/**============刺探任务相关配置--结束============**/


		/**
		 * 3次对话-对话模型
		 */
		static public const MODEL_1:int=1;

		/**
		 * 2次对话-打怪模型
		 */
		static public const MODEL_2:int=2;

		/**
		 * 2次对话-打怪搜集道具模型
		 */
		static public const MODEL_3:int=3;

		/**
		 * 2次对话-道具护送
		 */
		static public const MODEL_4:int=4;

		/**
		 * 3次对话-道具护送模型(第二次给道具)
		 */
		static public const MODEL_5:int=5;

		/**
		 * 3次对话 中间状态打开商城买道具
		 */
		static public const MODEL_6:int=6;

		/**
		 * 3次对话-道具护送模型(第一只NPC给道具)
		 */
		static public const MODEL_7:int=7;

		/**
		 * 2次对话-道具搜集
		 */
		static public const MODEL_8:int=8;
		
		/**
		 * 守边
		 */
		static public const MODEL_9:int=9;
		
		/**
		 * 刺探
		 */
		static public const MODEL_10:int=10;
		
		/**
		 * 升级任务
		 */
		public static const MODEL_12:int=12;

		/**
		 * 追踪面板任务目标的缩进值
		 */
		static public const TARGET_S_STR:String = '#MTS#';
		static public const TARGET_S_REG_EXP:RegExp = /\#MTS\#/g;
		
		/**
		 * 任务追踪面板链接类型 #类型,其他参数1...
		 */
		static public const FOLLOW_LINK_TYPE_GOTO:int = 0;//直接跳转到任意点
		static public const FOLLOW_LINK_TYPE_NPC:int = 1;//NPC
		static public const FOLLOW_LINK_TYPE_MONSTER:int = 2;//怪物
		static public const FOLLOW_LINK_TYPE_COLLECT:int = 3;//采集物
		static public const FOLLOW_LINK_TYPE_SHOP_BUY_GROUP:int = 4;//商城购买东西 打开商城
		
		/**
		 * 小灰鞋的替换字符串！！很恶心的有木有有木有！！
		 */
		static public const TRANS_GO_STR:String = '#XFX#';
		static public const TRANS_GO_REG_EXP:RegExp = /(\#XFX\#)/g;
		
		/**
		 * 任务排序依据
		 */
		//状态排序加权值
		static public const STATUS_SORT_BY:Object = {'0':0, '1':20, '2':10, '3':30};
		//任务类型加权值
		static public const TYPE_SORT_BY:Object = {'0':0, '1':4, '2':3, '3':2};
		
		//剩余次数不足接任务
		static public const AUTO_STATUS_TIMES_LIMIT:int = 3;
		//正在做
		static public const AUTO_STATUS_DOING:int = 1;
		//可以做
		static public const AUTO_STATUS_WAIT_DO:int = 0;
		//自动任务时间key
		static public const AUTO_TIMER_KEY:String = 'AUTO_MISSION_TIMER_KEY';
		
		
		
		public function MissionConstant() {
		}
	}
}