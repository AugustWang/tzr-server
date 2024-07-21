package modules.deal {
	import com.common.GlobalObjectManager;
	import com.loaders.CommonLocator;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.deal.views.NpcDealPanel;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.PursuePanel;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.line.m_exchange_npc_deal_toc;
	import proto.line.m_exchange_npc_deal_tos;
	import proto.line.m_family_collect_get_prize_toc;
	import proto.line.m_family_collect_get_role_info_toc;
	import proto.line.m_family_collect_get_role_info_tos;
	
	

    /**
     * NPC兑换功能处理
     * @author caochuncheng2002@gmail.com
     * 
     */
	public class NpcDealModule extends BaseModule {
		public function NpcDealModule() {
			
		}
        private static var _instance:NpcDealModule;
        public static function getInstance():NpcDealModule{
            if(_instance == null)
                _instance = new NpcDealModule();
            return _instance;
        }
        override protected function initListeners():void{
            this.addMessageListener(NPCActionType.NA_13,openNpcDealPanel);//兑换物品
            this.addMessageListener(ModuleCommand.EXCHANGE_NPC_DEAL,doExchangeNpcDealTos);//兑换操作
            
            this.addSocketListener(SocketCommand.EXCHANGE_NPC_DEAL,doExchangeNpcDealToc);
			this.addSocketListener(SocketCommand.FAMILY_COLLECT_GET_ROLE_INFO,updateInfo);
        }
        private var npcDealPanel:NpcDealPanel;
        private var curNpcObj:Object;
        /**
         * 打开NPC兑换面版
         * @param npcLinkVO
         * 
         */        
        private function openNpcDealPanel(npcLinkVO:NpcLinkVO):void{
            var npcObj:Object = npcLinkVO.data;
            this.curNpcObj = npcObj;
            if(this.npcDealPanel == null){
                this.npcDealPanel = new NpcDealPanel();
            }
            if(!WindowManager.getInstance().isPopUp(this.npcDealPanel)){
                WindowManager.getInstance().openDistanceWindow(this.npcDealPanel);
                WindowManager.getInstance().centerWindow(this.npcDealPanel);
            }
        }

		public function doExchangeNpcDealTos(dealItemObj:Object):void {
			var vo:m_exchange_npc_deal_tos = new m_exchange_npc_deal_tos;
            vo.deal_id = dealItemObj.id;
			vo.sub_id=dealItemObj.num;
			
            this.sendSocketMessage(vo);
		}
		
        /**
         * NPC 兑换功能 
         * @param vo
         * 
         */		
        private function doExchangeNpcDealToc(vo:m_exchange_npc_deal_toc):void{
            if(vo.succ==false){
                Tips.getInstance().addTipsMsg(vo.reason);
            }else{
                Tips.getInstance().addTipsMsg("兑换成功");
				this.npcDealPanel.refviewBottom();
            }
        }

        
        /**
         * 查找兑换对象
         * @return 
         * 
         */        
        public function findDealObj(dealId:int):Object{
            if (npcDealXml == null || npcDealXml == [] || npcDealXml.length == 0) {
                initNpcDealXml();
            }
            for each(var npcDealObj:Object in npcDealXml){
                if(npcDealObj.id == dealId){
                    return npcDealObj;
                }
            }
            return null;
        }
		/**
		 * 获得背包物品
		 * */
		public function getPackItemById(id:int):int{
			var goodNumber:int = PackManager.getInstance().getGoodsNumByTypeId(id);
			
			return goodNumber>0?goodNumber:0;
		}
        /**
         * 获得兑换组名称
         * @return 
         * 
         */  
		
        public function findDealGroupArr():Array{
            if (npcDealXml == null || npcDealXml == [] || npcDealXml.length == 0) {
                initNpcDealXml();
            }
            var tempArr:Array = [];
            for each(var npcDealObj:Object in npcDealXml){
                if(npcDealObj.show_type == 1)
				{
                    var obj:Object = {};
                    obj.name = npcDealObj.name;
                    obj.id = npcDealObj.id;
					obj.refgoodsid = npcDealObj.refgoodsid;
                    tempArr.push(obj);
             	}
            }
            return tempArr;
        }
        
		/**
		 * NPC 兑换配置数据
         * id
		 * name
		 * seq
		 * showType
		 * dealItemArr.id
		 * dealItemArr.seq
		 * dealItemArr.show_type
		 * dealItemArr.gold:不绑定元宝
		 * dealItemArr.bind_gold:绑定元宝
		 * dealItemArr.silver:绑定银子
		 * dealItemArr.bind_silver:不绑定银子
		 * dealItemArr.exp:奖励人物经验
		 * dealItemArr.family_money:门派资金
		 * dealItemArr.family_contribution:门派贡献度
		 * dealItemArr.family_active_points:门派繁荣度
         * dealItemArr.description
         * dealItemArr.needItemArr.{id,type,number,bind,color,quality}
         * dealItemArr.awardItemArr.{id,type,number,bind,color,quality}
		 */
		private var npcDealXml:Array = [];
        /**
         * 初始化分析兑换配置
         */        
        private function initNpcDealXml():void {
            var xml:XML = CommonLocator.getXML(CommonLocator.DEAL);
            var dealObj:Object = null;
            for each (var deal:XML in xml.deal) {
                dealObj = {};
                dealObj.id = deal.@id;
                dealObj.name = deal.@name;
                dealObj.seq = deal.@seq;
                dealObj.show_type = deal.@show_type;
				dealObj.refgoodsid = deal.@refgoodsid;
                var dealItemArr:Array = [];
                for each(var deal_item:XML in deal.deal_item){
                    var dealItemObj:Object = {};
                    dealItemObj.id = deal_item.@id;
					dealItemObj.dealType=deal_item.@dealType;//增加项目
					dealItemObj.limitNum=deal_item.@limitNum;
                    dealItemObj.seq = deal_item.@seq;
                    dealItemObj.show_type = deal_item.@show_type;
                    dealItemObj.gold = deal_item.@gold;
                    dealItemObj.bind_gold = deal_item.@bind_gold;
                    dealItemObj.silver = deal_item.@silver;
                    dealItemObj.bind_silver = deal_item.@bind_silver;
                    dealItemObj.exp = deal_item.@exp;
                    dealItemObj.family_money = deal_item.@family_money;
                    dealItemObj.family_contribution = deal_item.@family_contribution;
                    dealItemObj.family_active_points = deal_item.@family_active_points;
                    dealItemObj.description = "";
                    if(deal_item.child("description").length() > 0){
                        dealItemObj.description = XML(deal_item.description).text();
                    }
                    var needItemArr:Array = [];
                    if(deal_item.child("need_items").length() > 0){
                        for each(var need_items:XML in deal_item.need_items){
                            var needItemObj:Object = {};
                            needItemObj.id = need_items.@id;
							needItemObj.name=need_items.@name;//增加
                            needItemObj.type = need_items.@type;
                            needItemObj.number = need_items.@number;
							needItemObj.unit=need_items.@unit;//增加
                            needItemObj.bind = need_items.@bind;
                            needItemObj.color = need_items.@color;
                            needItemObj.quality = need_items.@quality;
                            needItemArr.push(needItemObj);
                        }
                    }//end need_items
                    dealItemObj.needItemArr = needItemArr;
                    var awardItemArr:Array = [];
                    if(deal_item.child("award_items").length() > 0){
                        for each(var award_items:XML in deal_item.award_items){
                            var awardItemObj:Object = {};
                            awardItemObj.id = award_items.@id;
							awardItemObj.name=award_items.@name;//增加
                            awardItemObj.type = award_items.@type;
                            awardItemObj.number = award_items.@number;
							awardItemObj.unit=award_items.@unit;//增加
                            awardItemObj.bind = award_items.@bind;
                            awardItemObj.color = award_items.@color;
                           awardItemObj.quality = award_items.@quality;
                            awardItemArr.push(awardItemObj);
                        }
                    }//end award_items
                    dealItemObj.awardItemArr = awardItemArr;
                   // if(dealItemObj.show_type == 1){
                        dealItemArr.push(dealItemObj);  
                    //}
                }//end deal_item
                dealItemArr.sortOn("id",Array.NUMERIC);
                dealObj.dealItemArr = dealItemArr;
               // if(dealObj.show_type == 1){
                    npcDealXml.push(dealObj);
                //}
            }//end deal
            npcDealXml.sortOn("id",Array.NUMERIC);
        }

		private var callback:Function=null;
		private var sparam:*=null;
			
		private function updateInfo(vo:m_family_collect_get_role_info_toc):void{
			if(vo.succ==false){
				Tips.getInstance().addTipsMsg(vo.reason);
			}else
			{
				if(sparam!=null)
					callback.call(null,vo,sparam);
				else
					callback.call(null,vo);
			}
			callback = null;
			sparam = null;
		}
		
		public function getattrvaluebyID(flag:int,fun:Function,param:*=null):void
		{
			callback = fun;
			sparam = param;
			var role_id:int= GlobalObjectManager.getInstance().user.attr.role_id;
			var vo:m_family_collect_get_role_info_tos=new m_family_collect_get_role_info_tos();
			vo.type_id=flag;
			vo.role_id=role_id;
			this.sendSocketMessage(vo);			
		}

	}
}