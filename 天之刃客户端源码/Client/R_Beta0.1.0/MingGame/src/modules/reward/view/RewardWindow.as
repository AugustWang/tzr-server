package modules.reward.view
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.Skin;
	import com.net.SocketCommand;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.reward.RewardModule;
	import modules.reward.view.items.RewardItemRender;
	
	import proto.common.p_goods;
	import proto.line.m_level_gift_accept_toc;
	import proto.line.m_time_gift_accept_toc;
	import proto.line.p_level_gift_info;
	import proto.line.p_time_gift_info;
	
	public class RewardWindow extends DragUIComponent
	{
		private var source:SourceLoader;
		public var getRewardBtn:Button;
		private var item_arr:Array = [];
		private var lvTxt:TextField;
		public function RewardWindow()
		{
			super();
		}
		
		public function init(s:SourceLoader):void{
			this.width = 410;
			this.height = 255;
			this.x = (1002 - this.width)/2;
			this.y = (GlobalObjectManager.GAME_HEIGHT  - this.height)/2;
			this.bgSkin = new Skin();
			
			
			this.source = s;
			//装载整个背景
			var backUI:Sprite = new Sprite();
			this.addChild(backUI);
			backUI.mouseChildren = backUI.mouseEnabled = false;
			
			//背景的头部
			var head_sprite:Sprite = this.source.getMovieClip("giftBorder") as Sprite;
			backUI.addChild(head_sprite);
			head_sprite.height = head_sprite.height - 3;
			head_sprite.mouseChildren = head_sprite.mouseEnabled = false;
			
			//关闭按钮
			var closeBtn:Button = new Button();
			this.addChild(closeBtn);
			closeBtn.x = head_sprite.width - 40;
			closeBtn.y = 40;
			closeBtn.width = closeBtn.height = 18;
			closeBtn.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
			closeBtn.addEventListener(MouseEvent.CLICK,onCloseBtnHandler);
			
			//背景的身体
			var backGround_sprite:Sprite = this.source.getMovieClip("giftContainer") as Sprite;
			backUI.addChild(backGround_sprite);
			backGround_sprite.x = 50;
			backGround_sprite.y = 38;
			backGround_sprite.mouseChildren = backGround_sprite.mouseEnabled = false;
			
			//显示等级
			lvTxt = ComponentUtil.createTextField("",114,10,null,75,30,backGround_sprite);
//			lvTxt.background = true;
//			lvTxt.backgroundColor = 0xff0000;
			
			var item_sprite:Sprite = new Sprite();
			this.addChild(item_sprite);
			item_sprite.x = 61;
			item_sprite.y = 92;
			for(var i:int=0;i<12;i++){
				var rewardItemRender:RewardItemRender = new RewardItemRender();
				item_sprite.addChild(rewardItemRender);
				item_arr.push(rewardItemRender);
			}
			
			LayoutUtil.layoutGrid(item_sprite,6,48,50);
			
			//领取奖励的按钮
			getRewardBtn = ComponentUtil.createButton("领取奖励",(410 - 70)/2,255 - 25*2,70,25,this);
			getRewardBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			
		}
		private function onCloseBtnHandler(evt:MouseEvent):void{
			WindowManager.getInstance().removeWindow(this);
		}
		private function onMouseClickHandler(evt:MouseEvent):void{
			
			if(getRewardBtn.label == "领取奖励"){
				if(rewardId != -1){
					var isFull:Boolean = PackManager.getInstance().isBagFull();
					if(!isFull){
						if(RewardModule.getInstance().isClickTimeGiftOpen){
							RewardModule.getInstance().reqeustGetTimeGift(rewardId);
						}else{
							RewardModule.getInstance().reqeustGetReward(rewardId);
						}
					}else{
						Tips.getInstance().addTipsMsg("背包空间不足，请整理背包后再领取礼包！ ");
					}
				}
			}else if(getRewardBtn.label == "稍后再来"){
				if(WindowManager.getInstance().isPopUp(this) == true){
					WindowManager.getInstance().removeWindow(this);
				}
			}
		}
		
		/**
		 * 
		 * @param data:数据
		 * @param str:标识
		 * 
		 */
		private var rewardId:int = -1;
		private var currentIndex:int;
		public var get_reward_nextLvl:int;
		private var show_gift_arr:Array = [];
		public function handlerFromService(data:Object,str:String):void{
			switch(str){
				case SocketCommand.LEVEL_GIFT_LIST:
					var gift_vo:p_level_gift_info = data as p_level_gift_info;
					rewardId = gift_vo.id;
					currentIndex = gift_vo.goods_list.length;
					get_reward_nextLvl = gift_vo.next_level;
					lvTxt.htmlText = "<font size='16' color='#000000'><b>"+gift_vo.id+"级礼包</b></font>";
					show_gift_arr = gift_vo.goods_list;
					for(var g:int=0;g<currentIndex;g++){
						RewardItemRender(item_arr[g]).data = gift_vo.goods_list[g];
					}
					break;
				case SocketCommand.LEVEL_GIFT_ACCEPT:
					var acceptVo:m_level_gift_accept_toc = data as m_level_gift_accept_toc;
					if(acceptVo == null)return;
					if(acceptVo.succ){
						rewardId = -1;
						Tips.getInstance().addTipsMsg("礼包领取成功，请到背包查看");
						WindowManager.getInstance().removeWindow(this);
						BroadcastSelf.logger("领取奖励获得：");
						
						//先把礼包放在背包中
						var giftLength:int = acceptVo.goods_list.length;
						if( giftLength > 0){
							for(var i:int=0; i<giftLength; i++){
								var gift:p_goods = acceptVo.goods_list[i];
								var baseItemVO:BaseItemVO = ItemConstant.wrapperItemVO(gift);
								PackManager.getInstance().updateGoods(baseItemVO.bagid,baseItemVO.position,baseItemVO);
								//领取礼包时，自动穿戴上
								if(gift.type == ItemConstant.TYPE_EQUIP){
									PackageModule.getInstance().useGoods(baseItemVO);
								}
								
							}
						}
						
						for(var c:int=0;c<currentIndex;c++){
							RewardItemRender(item_arr[c]).clear();
							var baseVO:BaseItemVO = ItemConstant.wrapperItemVO(p_goods(show_gift_arr[c]));
							BroadcastSelf.logger(baseVO.name+" × "+baseVO.num);
						}
						if(get_reward_nextLvl == 0){
							RewardModule.getInstance().cleanGiftIcon();
							return;
						}
					}else{
						Tips.getInstance().addTipsMsg(acceptVo.reason);
					}
					break;
				case SocketCommand.TIME_GIFT_LIST:
					var time_gift_vo:p_time_gift_info = data as p_time_gift_info;
					rewardId = time_gift_vo.id;
					currentIndex = time_gift_vo.goods_list.length;
					show_gift_arr = time_gift_vo.goods_list;
					lvTxt.htmlText = "<font size='16' color='#000000'><b>神秘礼包</b></font>";
					for(var t:int=0;t<currentIndex;t++){
						RewardItemRender(item_arr[t]).data = time_gift_vo.goods_list[t];
					}
					break;
				case SocketCommand.TIME_GIFT_ACCEPT:
					var acceptTimeGiftVo:m_time_gift_accept_toc = data as m_time_gift_accept_toc;
					if(acceptTimeGiftVo == null)return;
					if(acceptTimeGiftVo.succ){
						rewardId = -1;
						Tips.getInstance().addTipsMsg("奖励领取成功，请到背包查看！");
						WindowManager.getInstance().removeWindow(this);
						BroadcastSelf.logger("领取奖励获得：");
						
						for(var time_c:int=0;time_c<currentIndex;time_c++){
							RewardItemRender(item_arr[time_c]).clear();
							var baseTimeVO:BaseItemVO = ItemConstant.wrapperItemVO(p_goods(show_gift_arr[time_c]));
							BroadcastSelf.logger(baseTimeVO.name+" × "+baseTimeVO.num);
						}
					}else{
						Tips.getInstance().addTipsMsg(acceptTimeGiftVo.reason);
					}
					break;
			}
		}
	}
}