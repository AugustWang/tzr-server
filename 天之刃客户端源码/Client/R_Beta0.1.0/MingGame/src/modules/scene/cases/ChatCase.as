package modules.scene.cases
{
	
	import com.scene.GameScene;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	
	import proto.line.m_bubble_msg_toc;
	
	public class ChatCase extends BaseModule
	{
		private static var _instance:ChatCase;
		private var _view:GameScene;
		
		public function ChatCase()
		{
			_view=GameScene.getInstance();
		}
		
		public static function getInstance():ChatCase
		{
			if (_instance == null)
			{
				_instance=new ChatCase;
			}
			return _instance;
		}
		
		/**
		 * 某人说话
		 * @param vo
		 *
		 */
		public function say(vo:m_bubble_msg_toc):void
		{
			var animal:MutualAvatar=SceneUnitManager.getUnit(vo.actor_id, vo.actor_type)as MutualAvatar;
			if (animal != null)
			{
				animal.say(vo.msg);
				ChatModule.getInstance().bubbleAppendMsg(vo);
			}
		}
		override protected function initListeners():void
		{
			addMessageListener(ModuleCommand.NEAR_TALK_RECEIVE,say);
		}
	}
}