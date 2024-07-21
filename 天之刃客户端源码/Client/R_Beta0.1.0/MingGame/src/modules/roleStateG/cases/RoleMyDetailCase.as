package modules.roleStateG.cases
{
	import com.common.GlobalObjectManager;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	
	import flash.events.Event;
	
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.Tips;
	import modules.roleStateG.RoleStateModule;
	import modules.roleStateG.views.details.AddEnergyView;
	import modules.roleStateG.views.details.MyDetailView;
	import modules.roleStateG.views.details.RoleMyEquipView;
	import modules.roleStateG.views.details.RoleMyInfoView;
	
	import proto.common.p_role;
	import proto.common.p_title;
	import proto.line.m_role2_add_energy_toc;
	import proto.line.m_role2_add_energy_tos;
	import proto.line.m_role2_levelup_tos;
	import proto.line.m_role2_pkpoint_left_toc;
	import proto.line.m_role2_pkpoint_left_tos;
	import proto.line.m_role2_pointassign_tos;
	import proto.line.m_role2_show_cloth_tos;
	import proto.line.m_role2_show_equip_ring_tos;
	import proto.line.m_title_change_cur_title_tos;
	import proto.line.m_title_get_role_titles_toc;
	
	public class RoleMyDetailCase
	{
		private var view:MyDetailView;
		private var _addEnergyView:AddEnergyView;
		
		public function RoleMyDetailCase()
		{
		}
		
		private function initView():void
		{
			if (view == null)
			{
				view=new MyDetailView;
				view.addEventListener(RoleMyInfoView.EVENT_DO_LEVEL_UP, toRequestLevelUp);
				view.addEventListener(RoleMyEquipView.EVENT_ADD_PROPERY, toAddPropery);
				view.addEventListener(RoleMyInfoView.EVENT_CHANGE_TITLE, toChangeTitle);
				view.addEventListener(RoleMyEquipView.EVENT_SHOW_CLOTH, onShowCloth);
				view.addEventListener(RoleMyEquipView.EVENT_SHOW_EQUIP_RING, onShowEquipRing);
				view.addEventListener(WindowEvent.OPEN, toRequestPKPoing);
				view.addEventListener(RoleMyInfoView.EVENT_OPEN_ADD_ENERGY, openAddEnergy);
			}
		}
		
		//请求剩余PK值剩余时间
		private function toRequestPKPoing(e:WindowEvent):void
		{ 
			RoleStateModule.getInstance().send(new m_role2_pkpoint_left_tos);
		}
		
		public function toRequestLevelUp(e:Event):void
		{
			RoleStateModule.getInstance().send(new m_role2_levelup_tos);
		}
		
		private function toAddPropery(e:ParamEvent):void
		{
			var vo:m_role2_pointassign_tos=new m_role2_pointassign_tos();
			vo.type=e.data.type;
			vo.value=e.data.value;
			RoleStateModule.getInstance().send(vo);
		}
		
		public function updateMyTitles(vo:m_title_get_role_titles_toc):void
		{
			initView();
			view.updateMyTitles(vo);
		}
		
		public function toChangeTitle(e:ParamEvent):void
		{
			var p:p_title=e.data as p_title;
			var vo:m_title_change_cur_title_tos=new m_title_change_cur_title_tos();
			vo.id=p.id;
			RoleStateModule.getInstance().send(vo);
		}
		
		private function onShowEquipRing(e:ParamEvent):void
		{
			var vo:m_role2_show_equip_ring_tos = new m_role2_show_equip_ring_tos();
			vo.show_equip_ring = e.data as Boolean;
			RoleStateModule.getInstance().send(vo);
		}
		
		private function onShowCloth(e:ParamEvent):void
		{
			var vo:m_role2_show_cloth_tos=new m_role2_show_cloth_tos();
			vo.show_cloth=e.data as Boolean;
			RoleStateModule.getInstance().send(vo);
		}
		
		public function show(index:int=0):void
		{
			initView();
			view.seletedIndex=index;
			if (view.parent == null)
			{
				WindowManager.getInstance().popUpWindow(view);
			}
			update();
		}
		
		public function showClose():void
		{
			initView();
			WindowManager.getInstance().popUpWindow(view);
			update();
		}
		
		//新手任务的闪烁
		public function flashEquipItem(index:int):void
		{
//			TaskModule.getInstance().setGlou(view.getEquipItem(index));
		}
		
		public function flashProprety():void
		{
			view.showPopertyBorder();
		}
		
		public function update():void
		{
			initView();
			if (view != null)
			{
				view.update();
			}
		}
		public function updateMount():void{
			initView();
			if (view != null){
				view.updateMount();
			}
		}
		
		public function get theView():MyDetailView
		{
			initView();
			return view;
		}
		
		public function onPKPointLeft(vo:m_role2_pkpoint_left_toc):void
		{
			view.updatePKPointTime(vo.time_left);
		}
		
		/**
		 * 打开补充精力值面板
		 */
		
		public function openAddEnergy(e:Event=null):void
		{
			if (!_addEnergyView) {
				_addEnergyView = new AddEnergyView;
				_addEnergyView.addEventListener(AddEnergyView.EVENT_ON_ADD_ENERGY, onAddEnergy);
				_addEnergyView.x = GlobalObjectManager.GAME_WIDTH / 2;
				_addEnergyView.y = GlobalObjectManager.GAME_HEIGHT / 2;
			}
			
			WindowManager.getInstance().popUpWindow(_addEnergyView);
		}
		
		/**
		 * 请求补充精力值
		 */
		
		private function onAddEnergy(e:ParamEvent):void
		{
			var vo:m_role2_add_energy_tos = new m_role2_add_energy_tos;
			vo.gold_exchange = e.data as int;
			RoleStateModule.getInstance().send(vo);
		}
		
		/**
		 * 补充精力值返回
		 */
		
		public function onAddEnergyRtn(vo:m_role2_add_energy_toc):void
		{
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				return;
			}
			
			var pvo:p_role = GlobalObjectManager.getInstance().user;
			var energy:int = pvo.fight.energy;
			BroadcastSelf.logger("精力值增加" + (vo.energy-energy));
			Tips.getInstance().addTipsMsg("成功补充精力值");
			
			pvo.fight.energy = vo.energy;
			pvo.fight.energy_remain = vo.energy_remain;
			update();
			
			pvo.attr.gold = vo.gold;
			pvo.attr.gold_bind = vo.gold_bind;
			Dispatch.dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
			
			if (_addEnergyView)
				_addEnergyView.setData();
		}
	}
}