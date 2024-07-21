package modules.system.views
{
	import com.common.FilterCommon;
	import com.ming.ui.controls.CheckBox;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.system.SystemConfig;
	import modules.system.SystemModule;
	
	public class QualityView extends Sprite
	{
		private var privateChatCk:CheckBox; //开启私聊频道：不勾选，则收不到私聊频道信息
		private var nationChatCk:CheckBox;//开启国家频道：不勾选，则收不到国家频道信息
		private var familyChatCk:CheckBox;//开启门派频道：不勾选，则收不到门派频道信息
		private var worldChatCk:CheckBox;//开启综合频道：不勾选，则收不到综合频道信息
		private var teamChatCk:CheckBox;//开启队伍频道：不勾选，则收不到队伍频道信息
		private var centerBroadcastCk:CheckBox;//开启中央广播：不勾选，则收不到中央广播信息，如战神、国王登陆信息、送花广播
		
		private var acceptFriendrequestCk:CheckBox;//是否自动接受好友请求
		private var openEffectCk:CheckBox;//开启技能效过
		private var showClothingCk:CheckBox; //是否显示衣服
		private var byFindCk:CheckBox; //被查看时提示
		private var showDropGoodsNameCk:CheckBox; //显示掉落物名称
		private var showEquipCompareCk:CheckBox; //显示装备对比
		
		private var roleInfoCk:CheckBox; //玩家称号
		private var familyCk:CheckBox; //玩家名字
		private var factionNameCk:CheckBox; //玩家官职
		
		private var chkFormat:TextFormat;
		public function QualityView()
		{
			chkFormat = Style.textFormat;
			chkFormat.color = 0xa0ecef;
			var boldtf:TextFormat = Style.textFormat;
			boldtf.bold = true;
			boldtf.color = 0xffff00;
			var title:TextField = ComponentUtil.createTextField("聊天设置",8,10,boldtf,NaN,NaN,this);
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			worldChatCk = ComponentUtil.createCheckBox("开启综合频道",10,30,this,null,wrapperCheckBox);
			nationChatCk = ComponentUtil.createCheckBox("开启国家频道",140,30,this,null,wrapperCheckBox);
			familyChatCk = ComponentUtil.createCheckBox("开启门派频道",10,55,this,null,wrapperCheckBox);
			teamChatCk = ComponentUtil.createCheckBox("开启队伍频道",140,55,this,null,wrapperCheckBox);
			privateChatCk = ComponentUtil.createCheckBox("开启私聊频道",10,80,this,null,wrapperCheckBox);
			centerBroadcastCk = ComponentUtil.createCheckBox("开启中央广播",140,80,this,null,wrapperCheckBox);
			
			title = ComponentUtil.createTextField("其它设置",8,120,boldtf,NaN,NaN,this);
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			acceptFriendrequestCk = ComponentUtil.createCheckBox("接受好友请求",10,145,this,null,wrapperCheckBox);
			openEffectCk = ComponentUtil.createCheckBox("开启所有特效",140,145,this,null,wrapperCheckBox);
			showClothingCk = ComponentUtil.createCheckBox("显示人物服装",10,170,this,null,wrapperCheckBox);
			byFindCk = ComponentUtil.createCheckBox("被观察时提示",140,170,this,null,wrapperCheckBox);
			showDropGoodsNameCk = ComponentUtil.createCheckBox("显示掉落物名称",10,195,this,null,wrapperCheckBox);
			showEquipCompareCk = ComponentUtil.createCheckBox("显示装备对比",140,195,this,null,wrapperCheckBox);
			
			title = ComponentUtil.createTextField("角色显示",8,235,boldtf,NaN,NaN,this);
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			roleInfoCk = ComponentUtil.createCheckBox("显示场景角色信息",10,255,this,null,wrapperCheckBox);
			roleInfoCk.addEventListener(Event.CHANGE,onInfoChanged);
			
			familyCk = ComponentUtil.createCheckBox("显示玩家门派",10,280,this,null,wrapperCheckBox);
			factionNameCk = ComponentUtil.createCheckBox("显示玩家官职",140,280,this,null,wrapperCheckBox);
		}
		
		private function onInfoChanged(event:Event):void{
			if(!roleInfoCk.selected){
				familyCk.selected = false;
				factionNameCk.selected = false;
			}
			familyCk.enable = factionNameCk.enable = roleInfoCk.selected;
		}
		
		private function wrapperCheckBox(chk:CheckBox):void{
			chk.textFormat = chkFormat;
			chk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			chk.width = 120;
		}
		
		public function init():void{
			privateChatCk.selected = SystemConfig.privateChat;
			nationChatCk.selected = SystemConfig.nationChat;
			familyChatCk.selected = SystemConfig.familyChat;
			worldChatCk.selected = SystemConfig.worldChat;
			teamChatCk.selected = SystemConfig.teamChat;
			centerBroadcastCk.selected = SystemConfig.centerBroadcast;
	
			acceptFriendrequestCk.selected = SystemConfig.acceptFriendrequest;
			openEffectCk.selected = SystemConfig.openEffect;
			showClothingCk.selected = SystemConfig.showClothing;
			byFindCk.selected = SystemConfig.byFind;
			showDropGoodsNameCk.selected = SystemConfig.showDropGoodsName;
			showEquipCompareCk.selected = SystemConfig.showEquipCompare;
			
			familyCk.selected = SystemConfig.showFmaily;
			factionNameCk.selected = SystemConfig.showFactionName;
			roleInfoCk.selected = SystemConfig.showRoleInfo;
		}
				
		public function save():void{
			 if(privateChatCk.selected != SystemConfig.privateChat){
				 SystemModule.getInstance().log("私聊频道",privateChatCk.selected);
			 }
			 if(nationChatCk.selected != SystemConfig.nationChat){
				 SystemModule.getInstance().log("国家频道",nationChatCk.selected);
			 }
			 if(familyChatCk.selected != SystemConfig.familyChat){
				 SystemModule.getInstance().log("门派频道",familyChatCk.selected);
			 }
			 if(worldChatCk.selected != SystemConfig.worldChat){
				 SystemModule.getInstance().log("综合频道",worldChatCk.selected);
			 }
			 if(teamChatCk.selected != SystemConfig.teamChat){
				 SystemModule.getInstance().log("队伍频道",teamChatCk.selected);
			 }
			 SystemConfig.privateChat = privateChatCk.selected
			 SystemConfig.nationChat = nationChatCk.selected;
			 SystemConfig.familyChat = familyChatCk.selected;
			 SystemConfig.worldChat = worldChatCk.selected;
			 SystemConfig.teamChat = teamChatCk.selected;
			 SystemConfig.centerBroadcast = centerBroadcastCk.selected;
			 
			 SystemConfig.acceptFriendrequest = acceptFriendrequestCk.selected;
			 SystemConfig.openEffect = openEffectCk.selected;
			 SystemConfig.showClothing = showClothingCk.selected;
			 SystemConfig.byFind = byFindCk.selected;
			 SystemConfig.showDropGoodsName = showDropGoodsNameCk.selected;
			 SystemConfig.showEquipCompare = showEquipCompareCk.selected;
			 
			 SystemConfig.showRoleInfo = roleInfoCk.selected;
			 SystemConfig.showFmaily = familyCk.selected;
			 SystemConfig.showFactionName = factionNameCk.selected;
		}
	}
}