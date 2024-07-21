package modules.rank
{
	import com.common.GlobalObjectManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.rank.view.RankWindow;
	
	import proto.line.m_ranking_equip_join_rank_tos;
	import proto.line.m_ranking_get_rankinfo_tos;
	import proto.line.m_ranking_pet_join_rank_tos;
	import proto.line.m_ranking_role_all_rank_tos;
	
	public class RankModule extends BaseModule
	{
		public function RankModule()
		{
		}
		
		private static var _instance:RankModule;
		public static function getInstance():RankModule{
			if(!_instance){
				_instance = new RankModule();
			}
			return _instance;
		}
		
		override protected function initListeners():void{
			
			addSocketListener(SocketCommand.RANKING_CONFIG,rankId);
			addSocketListener(SocketCommand.RANKING_ROLE_LEVEL_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_FAMILY_ACTIVE_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_WORLD_PKPOINT_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_PKPOINT_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_EQUIP_JOIN_RANK,equipBack);
			addSocketListener(SocketCommand.RANKING_EQUIP_REFINING_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_EQUIP_REINFORCE_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_EQUIP_STONE_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_ALL_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_GONGXUN_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_FAMILY_GONGXUN_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_YESTERDAY_GONGXUN_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_TODAY_GONGXUN_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_RECE_FLOWERS_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_RECE_FLOWERS_TODAY_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_RECE_FLOWERS_YESTERDAY_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_GIVE_FLOWERS_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_GIVE_FLOWERS_YESTERDAY_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_GIVE_FLOWERS_TODAY_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_RECE_FLOWERS_LAST_WEEK_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_ROLE_PET_RANK,rankBack);
			addSocketListener(SocketCommand.RANKING_PET_JOIN_RANK,petBack);
			addSocketListener(SocketCommand.RANKING_HERO_FB_RANK, rankBack);
		}
		
	
		//打开面版式
		private var rankWindow:RankWindow;
		public function openRankWindow(index:int=0):void{
			if(!rankWindow){
				rankWindow = new RankWindow();
			}
			if (index != 0) {
				rankWindow.setSeleteBtn(index);
			} else {
				var curretnIndex:int = rankWindow.getCurrentIndex();
				if (curretnIndex != 0) {
					rankWindow.setSeleteBtn(curretnIndex);
				} else {
					rankWindow.setSeleteBtn(1);
				}
			}
			WindowManager.getInstance().popUpWindow(rankWindow,WindowManager.UNREMOVE);
			
		}
		
		//服务端主要推过来的信息（几个排行榜的ID）
		private function rankId(data:Object):void{
			RankWindow.everyRankId(data);
		}
		
		//请求排行榜数据
		public function requestLevelRankData(rankId:int):void{
			var vo:m_ranking_get_rankinfo_tos = new m_ranking_get_rankinfo_tos();
			vo.rank_id = rankId;
			sendSocketMessage(vo);
		}
		
		//排行数据返回
		private function rankBack(data:Object):void{
			rankWindow.handlerDataFromService(data);
		}
		
		//神兵排行的请求
		public function reqestEquipRankData(rankId:int,equipOid:int):void{
			var vo:m_ranking_equip_join_rank_tos = new m_ranking_equip_join_rank_tos();
			vo.rank_id = rankId;
			vo.goods_id = equipOid;
			this.sendSocketMessage(vo);
		}
		
		
		//神兵排行的请求返回
		public function equipBack(data:Object):void{
			rankWindow.handlerDataFromService(data);
		}
		
		//宠物排行的请求
		public function reqestPetRankData(rankId:int,petOid:int):void{
			var vo:m_ranking_pet_join_rank_tos = new m_ranking_pet_join_rank_tos();
			vo.rank_id = rankId;
			vo.pet_id = petOid;
			this.sendSocketMessage(vo);
		}
		
		//宠物排行的请求返回
		public function petBack(data:Object):void{
			rankWindow.handlerDataFromService(data);
		}
		
		//请求个人排行
		public function requestPlayerRankData(roleId:int):void{
			var vo:m_ranking_role_all_rank_tos = new m_ranking_role_all_rank_tos();
			vo.role_id = roleId;
			this.sendSocketMessage(vo);
		}
	}
}