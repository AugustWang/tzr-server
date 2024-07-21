package modules.gift {
	import com.common.GlobalObjectManager;
	import com.gs.TweenMax;
	import com.managers.LayerManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mission.MissionFBModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_goods;
	import proto.line.m_gift_item_award_toc;
	import proto.line.m_gift_item_award_tos;
	import proto.line.m_gift_item_query_toc;
	import proto.line.m_gift_item_query_tos;

    /**
     * 礼包模块
     * @author caochuncheng
     * 
     */
	public class GiftModule extends BaseModule {
		public function GiftModule() {
            super();
		}
        private static var instance:GiftModule;
        
        public static function getInstance():GiftModule {
            if (!instance) {
                instance = new GiftModule();
            }
            return instance;
        }
		
		
		
        /**
         * 事件处理
         */
        override protected function initListeners():void {
			//暂时屏蔽礼包功能
//            this.addMessageListener(ModuleCommand.ENTER_GAME,onEnterGame);
//			this.addMessageListener(ModuleCommand.CHANGE_MAP,onChangeMap);
//            this.addMessageListener(ModuleCommand.STAGE_RESIZE,onStageResize);
//            this.addMessageListener(ModuleCommand.GIFT_ITEM_AWARD,doGiftItemAwardTos);//领取奖励
//            this.addMessageListener(ModuleCommand.ROLE_LEVEL_UP,onRoleLevelUp);// 玩家等级变化
//            this.addMessageListener(ModuleCommand.GIFT_ITEM_TIP_SHOW,onGiftItemTipShow);//领取提示
//            this.addMessageListener(ModuleCommand.GIFT_ITEM_TIP_CLOSE,onGiftItemTipClose);//领取提示
//            
//            
//            this.addSocketListener(SocketCommand.GIFT_ITEM_QUERY,doGiftItemQueryToc);//道具奖励查询
//            this.addSocketListener(SocketCommand.GIFT_ITEM_AWARD,doGiftItemAwardToc);//领取道具奖励
        }

		/**
		 * 切换地图的处理 
		 */		
		private function onChangeMap( mapId:int ):void {

			if ( MissionFBModule.getInstance().isMapMisssionFB( mapId ) && this.itemGiftPanel ) {
				this.itemGiftPanel.visible = false;
			} else {
				if ( this.itemGiftPanel ) {
					this.itemGiftPanel.visible = true;
				}
			}
		}
		
		private var isChangeRoleLevel:Boolean = false;
        /**
         * 玩家升级事件处理 
         */        
        private function onRoleLevelUp():void{
            if(!isChangeRoleLevel && GlobalObjectManager.getInstance().user.attr.level >= 3){
                var vo:m_gift_item_query_tos = new m_gift_item_query_tos;
                this.sendSocketMessage(vo);
				isChangeRoleLevel = true;
            }
            if(this.itemGiftPanel && this.curAwardRoleLevel != -1
                && GlobalObjectManager.getInstance().user.attr.level >= this.curAwardRoleLevel){
                var px:int = int(GlobalObjectManager.GAME_WIDTH >> 1) - int(this.itemGiftPanel.width >> 1);
                var py:int = int(GlobalObjectManager.GAME_HEIGHT >> 1) - int(this.itemGiftPanel.height >> 1);
                TweenMax.to(this.itemGiftPanel,2,{x:px,y:py,onComplete:onCompleteMove});
            }
            
        }
        private function onCompleteMove():void{
            if(this.itemGiftPanel && this.curAwardRoleLevel != -1
                && GlobalObjectManager.getInstance().user.attr.level < this.curAwardRoleLevel){
                this.itemGiftPanel.x = GlobalObjectManager.GAME_WIDTH - 250;
                this.itemGiftPanel.y = 104;
            }
        }
        /**
         * 进入游戏查询道具奖励
         * 
         */		
        private function onEnterGame():void {
			if (GlobalObjectManager.getInstance().user.attr.level >= 3) {
				var vo:m_gift_item_query_tos = new m_gift_item_query_tos;
				this.sendSocketMessage(vo);
			}
		}
        private function onStageResize(obj:Object):void{
            var px:int = int(GlobalObjectManager.GAME_WIDTH >> 1);
            var py:int = int(GlobalObjectManager.GAME_HEIGHT >> 1);
            if(itemGiftPanel != null){
                if(this.curAwardRoleLevel != -1
                    && GlobalObjectManager.getInstance().user.attr.level >= this.curAwardRoleLevel){
                    this.itemGiftPanel.x = px - int(this.itemGiftPanel.width >> 1);
                    this.itemGiftPanel.y = py - int(this.itemGiftPanel.height >> 1);
                }else{
                    this.itemGiftPanel.x = obj.width - 250;
                }
            }
            if(itemGiftTip != null){
				this.itemGiftTip.x = px - int(this.itemGiftTip.width >> 1);
				this.itemGiftTip.y = py - int(this.itemGiftTip.height >> 1);
                
            }
        }
        private function doGiftItemAwardTos(baseItemVo:BaseItemVO):void{
            var vo:m_gift_item_award_tos = new m_gift_item_award_tos;
            this.sendSocketMessage(vo);
        }
        private var itemGiftPanel:ItemGiftPanel;
        private var curAwardRoleLevel:int = -1;
        /**
         * 道具奖励查询返回结果 
         * @param vo
         * 
         */        
        private function doGiftItemQueryToc(vo:m_gift_item_query_toc):void{
            if(vo.succ && vo.cur_goods != null && vo.cur_goods.length > 0){
                this.curAwardRoleLevel = vo.award_role_level;
                if(itemGiftPanel == null){
                    itemGiftPanel = new ItemGiftPanel();
                    LayerManager.uiLayer.addChild(this.itemGiftPanel);
                }
                var obj:Object = {goods:vo.cur_goods[0] as p_goods,role_level:vo.award_role_level};
                this.itemGiftPanel.giftGoods = obj;
                if (GlobalObjectManager.getInstance().user.attr.level >= vo.award_role_level){
                    this.itemGiftPanel.x = int(GlobalObjectManager.GAME_WIDTH >> 1) - int(this.itemGiftPanel.width >> 1);
                    this.itemGiftPanel.y = int(GlobalObjectManager.GAME_HEIGHT >> 1) - int(this.itemGiftPanel.height >> 1);
                }else{
                    this.itemGiftPanel.x = GlobalObjectManager.GAME_WIDTH - 250;
                    this.itemGiftPanel.y = 104;
                }
            }
        }
        private var itemGiftTip:ItemGiftTip;
        private function onGiftItemTipShow(obj:Object):void{
            if(itemGiftTip == null){
                itemGiftTip = new ItemGiftTip();
            }
            if(!LayerManager.uiLayer.contains(this.itemGiftTip)){
                LayerManager.uiLayer.addChild(this.itemGiftTip);
                itemGiftTip.tipData = obj;
                this.itemGiftTip.x = int(GlobalObjectManager.GAME_WIDTH >> 1) - int(this.itemGiftTip.width >> 1);
                this.itemGiftTip.y = int(GlobalObjectManager.GAME_HEIGHT >> 1) - int(this.itemGiftTip.height >> 1);
            }
        }
        private function onGiftItemTipClose():void{
            if(itemGiftTip != null && LayerManager.uiLayer.contains(this.itemGiftTip)){
                LayerManager.uiLayer.removeChild(this.itemGiftTip);
            }
        }
        /**
         * 道具奖励领取返回结果 
         * @param vo
         * 
         */
        private function doGiftItemAwardToc(vo:m_gift_item_award_toc):void{
            if(vo.succ && vo.next_goods && vo.next_goods.length > 0){
                this.curAwardRoleLevel = vo.award_role_level;
                if(itemGiftPanel == null){
                    itemGiftPanel = new ItemGiftPanel();
                    LayerManager.uiLayer.addChild(this.itemGiftPanel);
                }
                
                var obj:Object = {goods:vo.next_goods[0] as p_goods,role_level:vo.award_role_level};
                this.itemGiftPanel.giftGoods = obj;
                if (GlobalObjectManager.getInstance().user.attr.level >= vo.award_role_level){
                    this.itemGiftPanel.x = int(GlobalObjectManager.GAME_WIDTH >> 1);
                    this.itemGiftPanel.y = int(GlobalObjectManager.GAME_HEIGHT >> 1);
                }else{
                    this.itemGiftPanel.x = GlobalObjectManager.GAME_WIDTH - 250;
                    this.itemGiftPanel.y = 104;
                }
                if(itemGiftTip != null && itemGiftTip.parent != null){
                    itemGiftTip.parent.removeChild(itemGiftTip);
                }
                //领取的装备是马
                if(vo.award_goods != null && vo.award_goods.length > 0 
                    && p_goods(vo.award_goods[0]).type == 3 ){
                    var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(p_goods(vo.award_goods[0]));
                    if(baseItemVo.kind == ItemConstant.KIND_EQUIP_MOUNT){
                        PackageModule.getInstance().useMount(EquipVO(baseItemVo));
                    }
                    if(p_goods(vo.award_goods[0]).level == 10){
                        PackageModule.getInstance().useGoods(EquipVO(baseItemVo));
                    }
                }
            }else if(vo.succ && (vo.next_goods == null || vo.next_goods.length == 0)){
                //玩家已经没有奖励可以领取了
                if(itemGiftPanel != null && itemGiftPanel.parent != null){
                    itemGiftPanel.parent.removeChild(itemGiftPanel);
                }
                if(itemGiftTip != null && itemGiftTip.parent != null){
                    itemGiftTip.parent.removeChild(itemGiftTip);
                }
                this.curAwardRoleLevel = -1;
                
                itemGiftPanel = null;
                itemGiftTip = null;
                //领取的装备是马
                if(vo.award_goods != null && vo.award_goods.length > 0 
                    && p_goods(vo.award_goods[0]).type == 3 ){
                    var baseItemVo2:BaseItemVO = ItemConstant.wrapperItemVO(p_goods(vo.award_goods[0]));
                    if(baseItemVo2.kind == ItemConstant.KIND_EQUIP_MOUNT){
                        PackageModule.getInstance().useMount(EquipVO(baseItemVo2));
                    }
                    if(p_goods(vo.award_goods[0]).level == 10){
                        PackageModule.getInstance().useGoods(EquipVO(baseItemVo));
                    }
                }
            }else{
                Tips.getInstance().addTipsMsg(vo.reason);
            }
        }
	}
}