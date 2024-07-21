package modules.scene.cases
{
	
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Role;
	
	import modules.BaseModule;
	
	import proto.line.m_skin_change_toc;
	
	
	public class SkinCase extends BaseModule
	{
		private static const NAME:String="equip"
		private static const CHANGE:String="change";
		private static var _instance:SkinCase;
		private var _view:GameScene;
		
		public function SkinCase():void
		{
			_view=GameScene.getInstance();
		}
		
		public static function getInstance():SkinCase
		{
			if (_instance == null)
			{
				_instance=new SkinCase;
			}
			return _instance;
		}
		
		public function onChange(vo:m_skin_change_toc):void
		{
			var a:Role=SceneUnitManager.getUnit(vo.roleid)as Role;
			if (a != null)
			{
				a.changeSkin(vo.skin);
			}
		}
		override protected function initListeners():void
		{
			addSocketListener(SocketCommand.SKIN_CHANGE, onChange); //换皮肤
		}
	}
}