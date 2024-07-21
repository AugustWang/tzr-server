package modules.warOfCity
{
	import com.engine.core.controls.system.modelProxy.IMessage;
	import com.engine.core.controls.system.modelProxy.MessageConstant;
	import com.engine.core.view.world.scene.SceneHappensAction;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.IModelView;
	import modules.ModuleCommand;
	import modules.npc.NPCActionType;
	import modules.warOfCity.cases.FamilyWarCase;
	
	import proto.line.m_warofcity_agree_enter_toc;
	import proto.line.m_warofcity_apply_toc;
	import proto.line.m_warofcity_collect_toc;
	import proto.line.m_warofcity_panel_manage_toc;
	import proto.line.m_warofcity_panel_toc;
	
	public class FamilyWarOfCityModule extends BaseModule
	{
		public static var _instance:FamilyWarOfCityModule;
		private var myCase:FamilyWarCase;
		private var inited:Boolean;
		
		public function FamilyWarOfCityModule()
		{
			if (_instance != null)
			{
				throw new Error("FamilyWarOfCityModule只能存在一个实例。");
			}
		}
		
		public static function getInstance():FamilyWarOfCityModule
		{
			if (_instance == null)
			{
				_instance=new FamilyWarOfCityModule();
			}
			return _instance;
		}
		
		private function initView():void
		{
			if (inited == false)
			{
				myCase=new FamilyWarCase(this.model);
				inited=true;
			}
		}
		
		override protected function initListeners():void
		{
			addSocketListener(SocketCommand.WAROFCITY_AGREE_ENTER, myCase.onAgreeCollect);
//			addSocketListener(SocketCommand.WAROFCITY_APPLY, myCase.onApply);
//			addSocketListener(SocketCommand.WAROFCITY_BREAK, myCase.
		}
		
		private function moduleToModule(m:IMessage):void
		{
			switch (m.name)
			{
				case NPCActionType.CITY_SING_UP:
					myCase.toOpenSignView();
					break;
				case NPCActionType.CITY_ENTER:
					myCase.onEnterMap();
					break;
				case NPCActionType.CITY_SCEACH:
					myCase.toOpenOccupyView();
					break;
				case SceneHappensAction.MAP_ROLE_ENTER + "":
					break;
			}
		}
		
		private function serverToModule(m:IMessage):void
		{
			switch (m.name)
			{
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_PANEL: //报名列表
					myCase.onRequestSignDetail(m.data as m_warofcity_panel_toc);
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_PANEL_MANAGE: //本图归属
					myCase.onRequestOccupy(m.data as m_warofcity_panel_manage_toc);
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_GET_REWARD: //领取奖励
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_APPLY: //报名
					myCase.onSignUp(m.data as m_warofcity_apply_toc);
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_COLLECT: //征集令
					myCase.onCollect(m.data as m_warofcity_collect_toc);
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_AGREE_ENTER: //同意进入
					myCase.onAgreeCollect(m.data as m_warofcity_agree_enter_toc);
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_HOLD: //占领
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_HOLDING: //占领进度中
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_HOLD_SUCC: //占领成功
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_BREAK: //占领中断
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_END: //战斗结束
					break;
				case WarOfCityMap_S.WAROFCITY + "_" + WarOfCityMap_S.WAROFCITY_GET_MARK: //获取积分
					break;
				default:
					break;
			}
		}
	}
}