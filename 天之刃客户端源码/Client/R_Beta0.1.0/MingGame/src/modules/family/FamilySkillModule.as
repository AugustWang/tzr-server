package modules.family
{
	import com.loaders.CommonLocator;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import flash.events.DataEvent;
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.family.views.FamilyBuffPanel;
	import modules.family.views.FamilySkillInfoPanel;
	import modules.family.views.FamilySkillLearnPanel;
	import modules.family.views.FamilySkillResearchPanel;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.skill.SkillDataManager;
	import modules.skillTree.SkillTreeModule;
	
	import proto.common.p_fml_buff;
	import proto.line.m_fmlskill_fetch_buff_toc;
	import proto.line.m_fmlskill_fetch_buff_tos;
	import proto.line.m_fmlskill_forget_toc;
	import proto.line.m_fmlskill_forget_tos;
	import proto.line.m_fmlskill_list_buff_toc;
	import proto.line.m_fmlskill_list_buff_tos;
	import proto.line.m_fmlskill_list_toc;
	import proto.line.m_fmlskill_list_tos;
	import proto.line.m_fmlskill_research_toc;
	import proto.line.m_fmlskill_research_tos;

	public class FamilySkillModule extends BaseModule
	{
		private var _reseachPanel:FamilySkillResearchPanel;
		private var _learnPanel:FamilySkillLearnPanel;
		private var _infoPanel:FamilySkillInfoPanel;
		private var _data:Dictionary;
		private var _skillResreachXML:XML
		
		public function FamilySkillModule()
		{
			initData();
		}
		
		private function initData():void{
			_data = new Dictionary();
			_skillResreachXML = CommonLocator.getXML(CommonLocator.FML_SKILL_XML);
			var xmllist:XMLList = _skillResreachXML.skill;
			for( var i:int = 0; i < xmllist.length(); i++ ){
				var key:String = xmllist[i].@id.toString();
				_data[key] = xmllist[i]
			}
		}
		
		public function getResreachData(id:int):XML{
			return _data[id.toString()]
		}
		
		private static var _instance:FamilySkillModule;
		public static function getInstance():FamilySkillModule{
			if(_instance == null)
				_instance = new FamilySkillModule();
			return _instance;
		}
		
		override protected function initListeners():void{
			addMessageListener(NPCActionType.NA_15, openResearchWindow);
			addMessageListener(NPCActionType.NA_16, openLearnWindow);
			addMessageListener(NPCActionType.NA_17, openInfoWindow);
			addMessageListener(NPCActionType.NA_18, openFMLBuffView);
			
			addSocketListener(SocketCommand.FMLSKILL_RESEARCH,onResearchBack);
			addSocketListener(SocketCommand.FMLSKILL_FORGET,onForgetBack);
			addSocketListener(SocketCommand.FMLSKILL_LIST,onListBack);
			addSocketListener(SocketCommand.FMLSKILL_LIST_BUFF,onBuffsBack);
			addSocketListener(SocketCommand.FMLSKILL_FETCH_BUFF,onFetchBuffBack);
		}
		
		private function onResearchBack(vo:m_fmlskill_research_toc):void{
			if(vo.succ){
				BroadcastSelf.logger("研究成功");
				SkillDataManager.getSkill(vo.skill.skill_id).fml_level = vo.skill.cur_level;
				if( _reseachPanel )_reseachPanel.updata();
				if( _learnPanel )_learnPanel.updata();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private function onForgetBack(vo:m_fmlskill_forget_toc):void{
			if(vo.succ){
				SkillDataManager.getSkill(vo.skill_id).fml_level = 0;
				if( _reseachPanel )_reseachPanel.updata();
				if( _learnPanel )_learnPanel.updata();
				BroadcastSelf.logger("遗忘成功");
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private function onListBack(vo:m_fmlskill_list_toc):void{
			if( _reseachPanel )_reseachPanel.removeDataLoading();
			for( var i:int = 0; i < vo.skills.length; i++ ){
				SkillDataManager.getSkill(vo.skills[i].skill_id).fml_level = vo.skills[i].cur_level;
			}
			if( _reseachPanel )_reseachPanel.updata();
			if( _learnPanel )_learnPanel.updata();
		}
		
		public function research(id:int):void{
			var vo:m_fmlskill_research_tos = new m_fmlskill_research_tos();
			vo.skill_id = id;
			sendSocketMessage(vo);
		}
		
		public function forget(id:int):void{
			var vo:m_fmlskill_forget_tos = new m_fmlskill_forget_tos();
			vo.skill_id = id;
			sendSocketMessage(vo);
		}
		
		public function getList():void{
			var vo:m_fmlskill_list_tos = new m_fmlskill_list_tos();
			sendSocketMessage(vo);
		}
		
		public function openResearchWindow(vo:NpcLinkVO=null):void{
//			if( FamilyLocator.getInstance().familyInfo.owner_role_id != GlobalObjectManager.instance.user.attr.role_id ){
//				Tips.getInstance().addTipsMsg("只有掌门才能研究门派技能！");
//				return;
//			}
			if( _reseachPanel == null ){
				_reseachPanel = new FamilySkillResearchPanel();
				_reseachPanel.addEventListener(FamilySkillResearchPanel.RESEARCH_FMLSKILL,researchHandler);
				_reseachPanel.addEventListener(FamilySkillResearchPanel.FORGET_FMLSKILL,forgetHandler);
				_reseachPanel.initView();
			}
			_reseachPanel.addDataLoading();
			WindowManager.getInstance().openDistanceWindow(_reseachPanel);
			WindowManager.getInstance().centerWindow(_reseachPanel);
			getList();
		}
		
		private function researchHandler(event:DataEvent):void{
			research( int(event.data) );
		}
		
		private function forgetHandler(event:DataEvent):void{
			forget( int(event.data) );
		}
		
		public function openLearnWindow(vo:NpcLinkVO=null):void{
			if( _learnPanel == null ){
				_learnPanel = new FamilySkillLearnPanel();
				_learnPanel.addEventListener(FamilySkillLearnPanel.LEARN_FMLSKILL,learnHandler);
				_learnPanel.addEventListener(FamilySkillLearnPanel.PERSONAL_FORGET_FMLSKILL,personalForgetHandler);
				_learnPanel.initView();
			}
			//_learnPanel.addDataLoading();
			WindowManager.getInstance().openDistanceWindow(_learnPanel);
			WindowManager.getInstance().centerWindow(_learnPanel);
			getList();
		}
		
		private function learnHandler(event:DataEvent):void{
			SkillTreeModule.getInstance().skillLearn(int(event.data));
		}
		
		private function personalForgetHandler(event:DataEvent):void{
			SkillTreeModule.getInstance().skillPersonalForget(int(event.data));
		}
		
		public function openInfoWindow(vo:NpcLinkVO=null):void{
			if( _infoPanel == null ){
				_infoPanel = new FamilySkillInfoPanel();
				_infoPanel.initView();
			}
			WindowManager.getInstance().openDistanceWindow(_infoPanel);
			WindowManager.getInstance().centerWindow(_infoPanel);
		}
		
		public function familyInfoUpdata():void{
			if(_reseachPanel && _reseachPanel.parent)_reseachPanel.updata();
			if(_learnPanel && _learnPanel.parent)_learnPanel.updata();
		}
		
		
		private var fmlBuffPanel:FamilyBuffPanel;
		private var buffsObj:Array =[];
		public function openFMLBuffView(vo:NpcLinkVO=null):void
		{
			if(!fmlBuffPanel)
			{
				fmlBuffPanel = new FamilyBuffPanel();
			}
			WindowManager.getInstance().openDistanceWindow(fmlBuffPanel);
			WindowManager.getInstance().centerWindow(fmlBuffPanel);
			getBuffList();
		}
		public function getBuffList():void
		{
			var vo:m_fmlskill_list_buff_tos = new m_fmlskill_list_buff_tos();
			sendSocketMessage(vo);
		}
		public function getFetchBuff(buffId:int):void
		{
			var vo:m_fmlskill_fetch_buff_tos = new m_fmlskill_fetch_buff_tos();
			vo.fml_buff_id = buffId;
			sendSocketMessage(vo);
		}
		
		private function onBuffsBack(vo:m_fmlskill_list_buff_toc):void
		{
			if(!vo.succ)
			{
				BroadcastSelf.logger(vo.reason);
				return;
			}
			buffsObj = [];
			for(var i:int=0;i<vo.buffs.length;i++)
			{
				var fmlbuff:p_fml_buff = vo.buffs[i] as p_fml_buff;
				var obj:Object = FamilyLocator.getInstance().getObjByIdAndLv( fmlbuff.fml_buff_id,fmlbuff.level);
				//obj.name;	obj.url ; obj.id ; obj.level ;  obj.familyLv ; obj.cost = buff.@cost; obj.desc = buff.@desc;
				buffsObj.push(obj);
			}
			
			if(fmlBuffPanel)
			{
				fmlBuffPanel.setBuffs(buffsObj);
				if(vo.is_fetched)
				{
					fmlBuffPanel.fetched(true);
				}
			}
		}
		private function onFetchBuffBack(vo:m_fmlskill_fetch_buff_toc):void
		{
			if(!vo.succ)
			{
				
				Tips.getInstance().addTipsMsg(vo.reason);
			}else{
				var id:int = vo.fml_buff_id;
				var buffname:String;
				var cost:int = 0;
				for(var i:int=0;i<buffsObj.length;i++)
				{
					var obj:Object = buffsObj[i];
					if(id == obj.id){
						buffname = obj.name;
						cost = obj.cost;
						break;
					}
				}
				if(buffname!=""&&cost!=0)
				{
					BroadcastSelf.logger(buffname+"状态领取成功，扣取"+cost+"点贡献度");
				}
				//xx状态领取成功，扣取xx点贡献度
				
				Tips.getInstance().addTipsMsg("成功领取门派技能状态");
				if(fmlBuffPanel)
				{
					fmlBuffPanel.fetched(true);
				}
			}
		}
	}
}