package com.net
{
	public class SocketCommand
	{	


		//LOGIN
		public static const LOGIN_FLASH:String = "LOGIN_FLASH";
		public static const LOGIN_PHP:String = "LOGIN_PHP";

		//ROLE
		public static const ROLE_ADD:String = "ROLE_ADD";
		public static const ROLE_CHOSE:String = "ROLE_CHOSE";
		public static const ROLE_DEL:String = "ROLE_DEL";
		public static const ROLE_LIST:String = "ROLE_LIST";
		public static const ROLE_ENTER:String = "ROLE_ENTER";

		//ROLE2
		public static const ROLE2_ATTR_CHANGE:String = "ROLE2_ATTR_CHANGE";
		public static const ROLE2_LEVELUP:String = "ROLE2_LEVELUP";
		public static const ROLE2_LEVELUP_OTHER:String = "ROLE2_LEVELUP_OTHER";
		public static const ROLE2_NEWBUFFS:String = "ROLE2_NEWBUFFS";
		public static const ROLE2_DEAD:String = "ROLE2_DEAD";
		public static const ROLE2_DEAD_OTHER:String = "ROLE2_DEAD_OTHER";
		public static const ROLE2_RELIVE:String = "ROLE2_RELIVE";
		public static const ROLE2_ATTR_RELOAD:String = "ROLE2_ATTR_RELOAD";
		public static const ROLE2_POINTASSIGN:String = "ROLE2_POINTASSIGN";
		public static const ROLE2_GETROLEATTR:String = "ROLE2_GETROLEATTR";
		public static const ROLE2_GETROLEMAPINFO:String = "ROLE2_GETROLEMAPINFO";
		public static const ROLE2_GETSKILLINFO:String = "ROLE2_GETSKILLINFO";
		public static const ROLE2_SKILLASSIGN:String = "ROLE2_SKILLASSIGN";
		public static const ROLE2_SKILLLEARN:String = "ROLE2_SKILLLEARN";
		public static const ROLE2_PKMODEMODIFY:String = "ROLE2_PKMODEMODIFY";
		public static const ROLE2_ZAZEN:String = "ROLE2_ZAZEN";
		public static const ROLE2_FIVE_ELE_ATTR:String = "ROLE2_FIVE_ELE_ATTR";
		public static const ROLE2_GRAY_NAME:String = "ROLE2_GRAY_NAME";
		public static const ROLE2_BASE_RELOAD:String = "ROLE2_BASE_RELOAD";
		public static const ROLE2_RELOAD:String = "ROLE2_RELOAD";
		public static const ROLE2_SHOW_CLOTH:String = "ROLE2_SHOW_CLOTH";
		public static const ROLE2_PKPOINT_LEFT:String = "ROLE2_PKPOINT_LEFT";
		public static const ROLE2_UNBUND_CHANGE:String = "ROLE2_UNBUND_CHANGE";
		public static const ROLE2_EXP_FULL:String = "ROLE2_EXP_FULL";
		public static const ROLE2_RELY_MAIN:String = "ROLE2_RELY_MAIN";
		public static const ROLE2_HAIR:String = "ROLE2_HAIR";
		public static const ROLE2_SEX:String = "ROLE2_SEX";
		public static const ROLE2_EVENT:String = "ROLE2_EVENT";
		public static const ROLE2_ON_HOOK_BEGIN:String = "ROLE2_ON_HOOK_BEGIN";
		public static const ROLE2_ON_HOOK_END:String = "ROLE2_ON_HOOK_END";
		public static const ROLE2_ON_HOOK_STATUS:String = "ROLE2_ON_HOOK_STATUS";
		public static const ROLE2_HEAD:String = "ROLE2_HEAD";
		public static const ROLE2_SHOW_EQUIP_RING:String = "ROLE2_SHOW_EQUIP_RING";
		public static const ROLE2_SYSTEM_BUFF:String = "ROLE2_SYSTEM_BUFF";
		public static const ROLE2_REMOVE_SKIN_BUFF:String = "ROLE2_REMOVE_SKIN_BUFF";
		public static const ROLE2_ADD_ENERGY:String = "ROLE2_ADD_ENERGY";
		public static const ROLE2_ONLINE_BROADCAST:String = "ROLE2_ONLINE_BROADCAST";
		public static const ROLE2_QUERY_FACTION_ONLINE_RANK:String = "ROLE2_QUERY_FACTION_ONLINE_RANK";

		//MAP
		public static const MAP_ENTER:String = "MAP_ENTER";
		public static const MAP_QUIT:String = "MAP_QUIT";
		public static const MAP_DROPTHING_ENTER:String = "MAP_DROPTHING_ENTER";
		public static const MAP_DROPTHING_QUIT:String = "MAP_DROPTHING_QUIT";
		public static const MAP_DROPTHING_PICK:String = "MAP_DROPTHING_PICK";
		public static const MAP_UPDATE_ACTOR_MAPINFO:String = "MAP_UPDATE_ACTOR_MAPINFO";
		public static const MAP_CHANGE_MAP:String = "MAP_CHANGE_MAP";
		public static const MAP_CHANGE_POS:String = "MAP_CHANGE_POS";
		public static const MAP_SLICE_ENTER:String = "MAP_SLICE_ENTER";
		public static const MAP_TRANSFER:String = "MAP_TRANSFER";
		public static const MAP_ROLE_KILLED:String = "MAP_ROLE_KILLED";

		//AUTH
		public static const AUTH_KEY:String = "AUTH_KEY";
		public static const AUTH_CHAT_KEY:String = "AUTH_CHAT_KEY";

		//FIGHT
		public static const FIGHT_ATTACK:String = "FIGHT_ATTACK";
		public static const FIGHT_BUFF_EFFECT:String = "FIGHT_BUFF_EFFECT";

		//MOVE
		public static const MOVE_WALK_PATH:String = "MOVE_WALK_PATH";
		public static const MOVE_WALK:String = "MOVE_WALK";
		public static const MOVE_KEYWALK:String = "MOVE_KEYWALK";
		public static const MOVE_KEYSTOP:String = "MOVE_KEYSTOP";
		public static const MOVE_SYNC:String = "MOVE_SYNC";

		//EQUIP
		public static const EQUIP_SWAP:String = "EQUIP_SWAP";
		public static const EQUIP_LOAD:String = "EQUIP_LOAD";
		public static const EQUIP_UNLOAD:String = "EQUIP_UNLOAD";
		public static const EQUIP_LOADED_LIST:String = "EQUIP_LOADED_LIST";
		public static const EQUIP_ENDURANCE_CHANGE:String = "EQUIP_ENDURANCE_CHANGE";
		public static const EQUIP_FIX:String = "EQUIP_FIX";
		public static const EQUIP_MOUNTUP:String = "EQUIP_MOUNTUP";
		public static const EQUIP_MOUNTDOWN:String = "EQUIP_MOUNTDOWN";
		public static const EQUIP_MOUNT_CHANGECOLOR:String = "EQUIP_MOUNT_CHANGECOLOR";
		public static const EQUIP_MOUNT_RENEWAL:String = "EQUIP_MOUNT_RENEWAL";

		//FRIEND
		public static const FRIEND_REQUEST:String = "FRIEND_REQUEST";
		public static const FRIEND_ACCEPT:String = "FRIEND_ACCEPT";
		public static const FRIEND_DELETE:String = "FRIEND_DELETE";
		public static const FRIEND_ONLINE:String = "FRIEND_ONLINE";
		public static const FRIEND_OFFLINE:String = "FRIEND_OFFLINE";
		public static const FRIEND_BLACK:String = "FRIEND_BLACK";
		public static const FRIEND_LIST:String = "FRIEND_LIST";
		public static const FRIEND_INFO:String = "FRIEND_INFO";
		public static const FRIEND_MODIFY:String = "FRIEND_MODIFY";
		public static const FRIEND_OFFLINE_REQUEST:String = "FRIEND_OFFLINE_REQUEST";
		public static const FRIEND_REFUSE:String = "FRIEND_REFUSE";
		public static const FRIEND_ENEMY:String = "FRIEND_ENEMY";
		public static const FRIEND_CHANGE_RELATIVE:String = "FRIEND_CHANGE_RELATIVE";
		public static const FRIEND_ADD_FRIENDLY:String = "FRIEND_ADD_FRIENDLY";
		public static const FRIEND_CREATE_FAMILY:String = "FRIEND_CREATE_FAMILY";
		public static const FRIEND_UPGRADE:String = "FRIEND_UPGRADE";
		public static const FRIEND_GET_INFO:String = "FRIEND_GET_INFO";
		public static const FRIEND_UPDATE_FAMILY:String = "FRIEND_UPDATE_FAMILY";
		public static const FRIEND_RECOMMEND:String = "FRIEND_RECOMMEND";
		public static const FRIEND_CONGRATULATION:String = "FRIEND_CONGRATULATION";
		public static const FRIEND_ADVERTISE:String = "FRIEND_ADVERTISE";
		public static const FRIEND_BOTTLE:String = "FRIEND_BOTTLE";

		//ITEM
		public static const ITEM_USE:String = "ITEM_USE";
		public static const ITEM_NEW_EXTEND_BAG:String = "ITEM_NEW_EXTEND_BAG";
		public static const ITEM_SHRINK_BAG:String = "ITEM_SHRINK_BAG";
		public static const ITEM_TRACE:String = "ITEM_TRACE";
		public static const ITEM_BATCH_SELL:String = "ITEM_BATCH_SELL";
		public static const ITEM_USE_SPECIAL:String = "ITEM_USE_SPECIAL";

		//STONE
		public static const STONE_LOAD:String = "STONE_LOAD";

		//SHOP
		public static const SHOP_BUY:String = "SHOP_BUY";
		public static const SHOP_SHOPS:String = "SHOP_SHOPS";
		public static const SHOP_ALL_GOODS:String = "SHOP_ALL_GOODS";
		public static const SHOP_SEARCH:String = "SHOP_SEARCH";
		public static const SHOP_NPC:String = "SHOP_NPC";
		public static const SHOP_SALE:String = "SHOP_SALE";
		public static const SHOP_ITEM:String = "SHOP_ITEM";
		public static const SHOP_BUY_BACK:String = "SHOP_BUY_BACK";

		//MISSION
		public static const MISSION_LIST:String = "MISSION_LIST";
		public static const MISSION_DO:String = "MISSION_DO";
		public static const MISSION_CANCEL:String = "MISSION_CANCEL";
		public static const MISSION_UPDATE:String = "MISSION_UPDATE";
		public static const MISSION_LISTENER:String = "MISSION_LISTENER";
		public static const MISSION_LIST_AUTO:String = "MISSION_LIST_AUTO";
		public static const MISSION_DO_AUTO:String = "MISSION_DO_AUTO";
		public static const MISSION_CANCEL_AUTO:String = "MISSION_CANCEL_AUTO";

		//SKIN
		public static const SKIN_CHANGE:String = "SKIN_CHANGE";

		//TEAM
		public static const TEAM_INVITE:String = "TEAM_INVITE";
		public static const TEAM_ACCEPT:String = "TEAM_ACCEPT";
		public static const TEAM_REFUSE:String = "TEAM_REFUSE";
		public static const TEAM_LEAVE:String = "TEAM_LEAVE";
		public static const TEAM_KICK:String = "TEAM_KICK";
		public static const TEAM_OFFLINE:String = "TEAM_OFFLINE";
		public static const TEAM_CHANGE_LEADER:String = "TEAM_CHANGE_LEADER";
		public static const TEAM_DISBAND:String = "TEAM_DISBAND";
		public static const TEAM_PICK:String = "TEAM_PICK";
		public static const TEAM_AUTO_DISBAND:String = "TEAM_AUTO_DISBAND";
		public static const TEAM_AUTO_LIST:String = "TEAM_AUTO_LIST";
		public static const TEAM_MEMBER_INVITE:String = "TEAM_MEMBER_INVITE";
		public static const TEAM_MEMBER_RECOMMEND:String = "TEAM_MEMBER_RECOMMEND";
		public static const TEAM_APPLY:String = "TEAM_APPLY";
		public static const TEAM_QUERY:String = "TEAM_QUERY";
		public static const TEAM_CREATE:String = "TEAM_CREATE";

		//MONSTER
		public static const MONSTER_ENTER:String = "MONSTER_ENTER";
		public static const MONSTER_QUIT:String = "MONSTER_QUIT";
		public static const MONSTER_DEAD:String = "MONSTER_DEAD";
		public static const MONSTER_ATTR_CHANGE:String = "MONSTER_ATTR_CHANGE";
		public static const MONSTER_WALK_PATH:String = "MONSTER_WALK_PATH";
		public static const MONSTER_WALK:String = "MONSTER_WALK";
		public static const MONSTER_SUMMON:String = "MONSTER_SUMMON";
		public static const MONSTER_TALK:String = "MONSTER_TALK";
		public static const MONSTER_QUERY:String = "MONSTER_QUERY";

		//CONFIG
		public static const CONFIG_GETSKILLS:String = "CONFIG_GETSKILLS";
		public static const CONFIG_GETBUFFS:String = "CONFIG_GETBUFFS";

		//GOODS
		public static const GOODS_INFO:String = "GOODS_INFO";
		public static const GOODS_SWAP:String = "GOODS_SWAP";
		public static const GOODS_INBAG_LIST:String = "GOODS_INBAG_LIST";
		public static const GOODS_DESTROY:String = "GOODS_DESTROY";
		public static const GOODS_DIVIDE:String = "GOODS_DIVIDE";
		public static const GOODS_UPDATE:String = "GOODS_UPDATE";
		public static const GOODS_TIDY:String = "GOODS_TIDY";
		public static const GOODS_SHOW_GOODS:String = "GOODS_SHOW_GOODS";

		//LETTER
		public static const LETTER_P2P_SEND:String = "LETTER_P2P_SEND";
		public static const LETTER_CLAN_SEND:String = "LETTER_CLAN_SEND";
		public static const LETTER_BATCH_SEND:String = "LETTER_BATCH_SEND";
		public static const LETTER_GET:String = "LETTER_GET";
		public static const LETTER_GET_SEND:String = "LETTER_GET_SEND";
		public static const LETTER_GET_RECEIVE:String = "LETTER_GET_RECEIVE";
		public static const LETTER_OPEN:String = "LETTER_OPEN";
		public static const LETTER_DELETE:String = "LETTER_DELETE";
		public static const LETTER_STATE_CHANGE:String = "LETTER_STATE_CHANGE";
		public static const LETTER_ACCEPT_GOODS:String = "LETTER_ACCEPT_GOODS";
		public static const LETTER_SEND:String = "LETTER_SEND";
		public static const LETTER_FAMILY_SEND:String = "LETTER_FAMILY_SEND";

		//EXCHANGE
		public static const EXCHANGE_REQUEST:String = "EXCHANGE_REQUEST";
		public static const EXCHANGE_AGREE:String = "EXCHANGE_AGREE";
		public static const EXCHANGE_REFUSE:String = "EXCHANGE_REFUSE";
		public static const EXCHANGE_CONFIRM:String = "EXCHANGE_CONFIRM";
		public static const EXCHANGE_LOCK:String = "EXCHANGE_LOCK";
		public static const EXCHANGE_CANCEL:String = "EXCHANGE_CANCEL";
		public static const EXCHANGE_NPC_DEAL:String = "EXCHANGE_NPC_DEAL";
		public static const EXCHANGE_EQUIP_INFO:String = "EXCHANGE_EQUIP_INFO";

		//STALL
		public static const STALL_REQUEST:String = "STALL_REQUEST";
		public static const STALL_DETAIL:String = "STALL_DETAIL";
		public static const STALL_LIST:String = "STALL_LIST";
		public static const STALL_BUY:String = "STALL_BUY";
		public static const STALL_CHAT:String = "STALL_CHAT";
		public static const STALL_FINISH:String = "STALL_FINISH";
		public static const STALL_EMPLOY:String = "STALL_EMPLOY";
		public static const STALL_OPEN:String = "STALL_OPEN";
		public static const STALL_SEARCH:String = "STALL_SEARCH";
		public static const STALL_PUTIN:String = "STALL_PUTIN";
		public static const STALL_GETOUT:String = "STALL_GETOUT";
		public static const STALL_GETALL:String = "STALL_GETALL";
		public static const STALL_EXTRACTMONEY:String = "STALL_EXTRACTMONEY";
		public static const STALL_MOVE:String = "STALL_MOVE";
		public static const STALL_STATE:String = "STALL_STATE";

		//REFINING
		public static const REFINING_REINFORCE_EQUIP:String = "REFINING_REINFORCE_EQUIP";
		public static const REFINING_COMPOSE:String = "REFINING_COMPOSE";
		public static const REFINING_PUNCH:String = "REFINING_PUNCH";
		public static const REFINING_INLAY:String = "REFINING_INLAY";
		public static const REFINING_UNLOAD:String = "REFINING_UNLOAD";
		public static const REFINING_INBAG_LIST:String = "REFINING_INBAG_LIST";
		public static const REFINING_INFO:String = "REFINING_INFO";
		public static const REFINING_1DESTROY:String = "REFINING_1DESTROY";
		public static const REFINING_SWAP:String = "REFINING_SWAP";
		public static const REFINING_DIVIDE:String = "REFINING_DIVIDE";
		public static const REFINING_DESTROY:String = "REFINING_DESTROY";
		public static const REFINING_EQUIP_BIND:String = "REFINING_EQUIP_BIND";
		public static const REFINING_FORGING:String = "REFINING_FORGING";
		public static const REFINING_FIRING:String = "REFINING_FIRING";
		public static const REFINING_BOX:String = "REFINING_BOX";

		//MESSAGE
		public static const MESSAGE_ERROR:String = "MESSAGE_ERROR";

		//BANK
		public static const BANK_INIT:String = "BANK_INIT";
		public static const BANK_SELL_REQUEST:String = "BANK_SELL_REQUEST";
		public static const BANK_BUY_REQUEST:String = "BANK_BUY_REQUEST";
		public static const BANK_SELL:String = "BANK_SELL";
		public static const BANK_BUY:String = "BANK_BUY";
		public static const BANK_UNDO:String = "BANK_UNDO";
		public static const BANK_ADD_SILVER:String = "BANK_ADD_SILVER";
		public static const BANK_ADD_GOLD:String = "BANK_ADD_GOLD";

		//DEPOT
		public static const DEPOT_GET_GOODS:String = "DEPOT_GET_GOODS";
		public static const DEPOT_DREDGE:String = "DEPOT_DREDGE";
		public static const DEPOT_DESTROY:String = "DEPOT_DESTROY";
		public static const DEPOT_SWAP:String = "DEPOT_SWAP";
		public static const DEPOT_DRAG:String = "DEPOT_DRAG";
		public static const DEPOT_TAKE:String = "DEPOT_TAKE";
		public static const DEPOT_DIVIDE:String = "DEPOT_DIVIDE";
		public static const DEPOT_TIDY:String = "DEPOT_TIDY";

		//SKILL
		public static const SKILL_LEARN:String = "SKILL_LEARN";
		public static const SKILL_RESET:String = "SKILL_RESET";
		public static const SKILL_GETSKILLS:String = "SKILL_GETSKILLS";
		public static const SKILL_USE_TIME:String = "SKILL_USE_TIME";
		public static const SKILL_PERSONAL_FORGET:String = "SKILL_PERSONAL_FORGET";

		//BROADCAST
		public static const BROADCAST_GENERAL:String = "BROADCAST_GENERAL";
		public static const BROADCAST_COUNTDOWN:String = "BROADCAST_COUNTDOWN";
		public static const BROADCAST_CYCLE:String = "BROADCAST_CYCLE";
		public static const BROADCAST_ADMIN:String = "BROADCAST_ADMIN";
		public static const BC_MSG_TYPE_OPERATE:String = "BC_MSG_TYPE_OPERATE";
		public static const BC_MSG_TYPE_SYSTEM:String = "BC_MSG_TYPE_SYSTEM";
		public static const BC_MSG_TYPE_COUNTDOWN:String = "BC_MSG_TYPE_COUNTDOWN";
		public static const BC_MSG_TYPE_ALL:String = "BC_MSG_TYPE_ALL";
		public static const BC_MSG_TYPE_CENTER:String = "BC_MSG_TYPE_CENTER";
		public static const BC_MSG_TYPE_CHAT:String = "BC_MSG_TYPE_CHAT";
		public static const BC_MSG_TYPE_POP:String = "BC_MSG_TYPE_POP";
		public static const BC_MSG_SUB_TYPE:String = "BC_MSG_SUB_TYPE";
		public static const BC_MSG_TYPE_COUNTDOWN_DUNGEON:String = "BC_MSG_TYPE_COUNTDOWN_DUNGEON";
		public static const BC_MSG_TYPE_COUNTDOWN_TASK:String = "BC_MSG_TYPE_COUNTDOWN_TASK";
		public static const BC_MSG_TYPE_CHAT_WORLD:String = "BC_MSG_TYPE_CHAT_WORLD";
		public static const BC_MSG_TYPE_CHAT_COUNTRY:String = "BC_MSG_TYPE_CHAT_COUNTRY";
		public static const BC_MSG_TYPE_CHAT_FAMILY:String = "BC_MSG_TYPE_CHAT_FAMILY";
		public static const BC_MSG_TYPE_CHAT_TEAM:String = "BC_MSG_TYPE_CHAT_TEAM";
		public static const BROADCAST_LABA:String = "BROADCAST_LABA";
		public static const BC_MSG_TYPE_ROLL:String = "BC_MSG_TYPE_ROLL";

		//YBC
		public static const YBC_ENTER:String = "YBC_ENTER";
		public static const YBC_QUIT:String = "YBC_QUIT";
		public static const YBC_DEAD:String = "YBC_DEAD";
		public static const YBC_ATTR_CHANGE:String = "YBC_ATTR_CHANGE";
		public static const YBC_WALK:String = "YBC_WALK";
		public static const YBC_INFO:String = "YBC_INFO";
		public static const YBC_POS:String = "YBC_POS";
		public static const YBC_NOTIFY_POS:String = "YBC_NOTIFY_POS";
		public static const YBC_FARAWAY:String = "YBC_FARAWAY";
		public static const YBC_SPEED:String = "YBC_SPEED";

		//FAMILY
		public static const FAMILY_CREATE:String = "FAMILY_CREATE";
		public static const FAMILY_REQUEST:String = "FAMILY_REQUEST";
		public static const FAMILY_INVITE:String = "FAMILY_INVITE";
		public static const FAMILY_AGREE:String = "FAMILY_AGREE";
		public static const FAMILY_REFUSE:String = "FAMILY_REFUSE";
		public static const FAMILY_AGREE_F:String = "FAMILY_AGREE_F";
		public static const FAMILY_REFUSE_F:String = "FAMILY_REFUSE_F";
		public static const FAMILY_FIRE:String = "FAMILY_FIRE";
		public static const FAMILY_UNSET_SECOND_OWNER:String = "FAMILY_UNSET_SECOND_OWNER";
		public static const FAMILY_UPDATE_PUB_NOTICE:String = "FAMILY_UPDATE_PUB_NOTICE";
		public static const FAMILY_UPDATE_PRI_NOTICE:String = "FAMILY_UPDATE_PRI_NOTICE";
		public static const FAMILY_LEAVE:String = "FAMILY_LEAVE";
		public static const FAMILY_DISMISS:String = "FAMILY_DISMISS";
		public static const FAMILY_LIST:String = "FAMILY_LIST";
		public static const FAMILY_SET_TITLE:String = "FAMILY_SET_TITLE";
		public static const FAMILY_SET_OWNER:String = "FAMILY_SET_OWNER";
		public static const FAMILY_SET_SECOND_OWNER:String = "FAMILY_SET_SECOND_OWNER";
		public static const FAMILY_SELF:String = "FAMILY_SELF";
		public static const FAMILY_MEMBER_JOIN:String = "FAMILY_MEMBER_JOIN";
		public static const FAMILY_PANEL:String = "FAMILY_PANEL";
		public static const FAMILY_ENTER_MAP:String = "FAMILY_ENTER_MAP";
		public static const FAMILY_LEAVE_MAP:String = "FAMILY_LEAVE_MAP";
		public static const FAMILY_CALL_COMMONBOSS:String = "FAMILY_CALL_COMMONBOSS";
		public static const FAMILY_ENTER_BOSS_MAP:String = "FAMILY_ENTER_BOSS_MAP";
		public static const FAMILY_LEAVE_BOSS_MAP:String = "FAMILY_LEAVE_BOSS_MAP";
		public static const FAMILY_CALL_UPLEVELBOSS:String = "FAMILY_CALL_UPLEVELBOSS";
		public static const FAMILY_CANCEL_INVITE:String = "FAMILY_CANCEL_INVITE";
		public static const FAMILY_ROLE_ONLINE:String = "FAMILY_ROLE_ONLINE";
		public static const FAMILY_ROLE_OFFLINE:String = "FAMILY_ROLE_OFFLINE";
		public static const FAMILY_CAN_INVITE:String = "FAMILY_CAN_INVITE";
		public static const FAMILY_CANCEL_TITLE:String = "FAMILY_CANCEL_TITLE";
		public static const FAMILY_ENABLE_MAP:String = "FAMILY_ENABLE_MAP";
		public static const FAMILY_UPLEVEL:String = "FAMILY_UPLEVEL";
		public static const FAMILY_ACTIVE_POINTS:String = "FAMILY_ACTIVE_POINTS";
		public static const FAMILY_DOWNLEVEL:String = "FAMILY_DOWNLEVEL";
		public static const FAMILY_MONEY:String = "FAMILY_MONEY";
		public static const FAMILY_SEARCH:String = "FAMILY_SEARCH";
		public static const FAMILY_CALLMEMBER:String = "FAMILY_CALLMEMBER";
		public static const FAMILY_MEMBER_ENTER_MAP:String = "FAMILY_MEMBER_ENTER_MAP";
		public static const FAMILY_MAINTAINFAIL:String = "FAMILY_MAINTAINFAIL";
		public static const FAMILY_MEMBERUPLEVEL:String = "FAMILY_MEMBERUPLEVEL";
		public static const FAMILY_MEMBERGATHER:String = "FAMILY_MEMBERGATHER";
		public static const FAMILY_YBC_AGREE_PUBLISH:String = "FAMILY_YBC_AGREE_PUBLISH";
		public static const FAMILY_YBC_COMMIT:String = "FAMILY_YBC_COMMIT";
		public static const FAMILY_YBC_CALL_HELP:String = "FAMILY_YBC_CALL_HELP";
		public static const FAMILY_YBC_ACCEPT_HELP:String = "FAMILY_YBC_ACCEPT_HELP";
		public static const FAMILY_YBC_COLLECT:String = "FAMILY_YBC_COLLECT";
		public static const FAMILY_YBC_ACCEPT_COLLECT:String = "FAMILY_YBC_ACCEPT_COLLECT";
		public static const FAMILY_YBC_LIST:String = "FAMILY_YBC_LIST";
		public static const FAMILY_YBC_KICK:String = "FAMILY_YBC_KICK";
		public static const FAMILY_YBC_ADD_HP:String = "FAMILY_YBC_ADD_HP";
		public static const FAMILY_YBC_PUBLISH:String = "FAMILY_YBC_PUBLISH";
		public static const FAMILY_YBC_ALERT:String = "FAMILY_YBC_ALERT";
		public static const FAMILY_YBC_STATUS:String = "FAMILY_YBC_STATUS";
		public static const FAMILY_GATHERREQUEST:String = "FAMILY_GATHERREQUEST";
		public static const FAMILY_DETAIL:String = "FAMILY_DETAIL";
		public static const FAMILY_YBC_SURE:String = "FAMILY_YBC_SURE";
		public static const FAMILY_YBC_GIVEUP:String = "FAMILY_YBC_GIVEUP";
		public static const FAMILY_YBC_JOIN:String = "FAMILY_YBC_JOIN";
		public static const FAMILY_YBC_INVITE:String = "FAMILY_YBC_INVITE";
		public static const FAMILY_MAP_CLOSED:String = "FAMILY_MAP_CLOSED";
		public static const FAMILY_DEL_REQUEST:String = "FAMILY_DEL_REQUEST";
		public static const FAMILY_INFO_CHANGE:String = "FAMILY_INFO_CHANGE";
		public static const FAMILY_COMBINE_PANEL:String = "FAMILY_COMBINE_PANEL";
		public static const FAMILY_COMBINE_REQUEST:String = "FAMILY_COMBINE_REQUEST";
		public static const FAMILY_COMBINE:String = "FAMILY_COMBINE";
		public static const FAMILY_SET_BONFIRE_START_TIME:String = "FAMILY_SET_BONFIRE_START_TIME";
		public static const FAMILY_ACTIVESTATE:String = "FAMILY_ACTIVESTATE";
		public static const FAMILY_SET_INTERIOR_MANAGER:String = "FAMILY_SET_INTERIOR_MANAGER";
		public static const FAMILY_LEFTRIGHT_PROTECTOR:String = "FAMILY_LEFTRIGHT_PROTECTOR";
		public static const FAMILY_UNSET_INTERIOR_MANAGER:String = "FAMILY_UNSET_INTERIOR_MANAGER";
		public static const FAMILY_NOTIFY_ONLINE:String = "FAMILY_NOTIFY_ONLINE";
		public static const FAMILY_GET_DONATE_INFO:String = "FAMILY_GET_DONATE_INFO";
		public static const FAMILY_DONATE:String = "FAMILY_DONATE";

		//SHORTCUT
		public static const SHORTCUT_INIT:String = "SHORTCUT_INIT";
		public static const SHORTCUT_UPDATE:String = "SHORTCUT_UPDATE";

		//BUBBLE
		public static const BUBBLE_SEND:String = "BUBBLE_SEND";
		public static const BUBBLE_MSG:String = "BUBBLE_MSG";

		//EQUIP_BUILD
		public static const EQUIP_BUILD_LIST:String = "EQUIP_BUILD_LIST";
		public static const EQUIP_BUILD_BUILD:String = "EQUIP_BUILD_BUILD";
		public static const EQUIP_BUILD_GOODS:String = "EQUIP_BUILD_GOODS";
		public static const EQUIP_BUILD_QUALITY_GOODS:String = "EQUIP_BUILD_QUALITY_GOODS";
		public static const EQUIP_BUILD_QUALITY:String = "EQUIP_BUILD_QUALITY";
		public static const EQUIP_BUILD_SIGNATURE:String = "EQUIP_BUILD_SIGNATURE";
		public static const EQUIP_BUILD_UPGRADE_GOODS:String = "EQUIP_BUILD_UPGRADE_GOODS";
		public static const EQUIP_BUILD_UPGRADE:String = "EQUIP_BUILD_UPGRADE";
		public static const EQUIP_BUILD_DECOMPOSE:String = "EQUIP_BUILD_DECOMPOSE";
		public static const EQUIP_BUILD_UPGRADE_LINK:String = "EQUIP_BUILD_UPGRADE_LINK";
		public static const EQUIP_BUILD_FIVEELE_GOODS:String = "EQUIP_BUILD_FIVEELE_GOODS";
		public static const EQUIP_BUILD_FIVEELE:String = "EQUIP_BUILD_FIVEELE";

		//DRIVER
		public static const DRIVER_GO:String = "DRIVER_GO";

		//SYSTEM
		public static const SYSTEM_FCM:String = "SYSTEM_FCM";
		public static const SYSTEM_CONFIG:String = "SYSTEM_CONFIG";
		public static const SYSTEM_CONFIG_CHANGE:String = "SYSTEM_CONFIG_CHANGE";
		public static const SYSTEM_HEARTBEAT:String = "SYSTEM_HEARTBEAT";
		public static const SYSTEM_SET_FCM:String = "SYSTEM_SET_FCM";
		public static const SYSTEM_ERROR:String = "SYSTEM_ERROR";
		public static const SYSTEM_NEED_FCM:String = "SYSTEM_NEED_FCM";
		public static const SYSTEM_MESSAGE:String = "SYSTEM_MESSAGE";
		public static const SYSTEM_PK_NOT_AGREE:String = "SYSTEM_PK_NOT_AGREE";

		//EDUCATE
		public static const EDUCATE_REPLY_INVITE_APPRENTICE:String = "EDUCATE_REPLY_INVITE_APPRENTICE";
		public static const EDUCATE_REPLY_INVITE_ADMISSIONS:String = "EDUCATE_REPLY_INVITE_ADMISSIONS";
		public static const EDUCATE_SWORN_MENTORING:String = "EDUCATE_SWORN_MENTORING";
		public static const EDUCATE_FILTER_STUDENT:String = "EDUCATE_FILTER_STUDENT";
		public static const EDUCATE_FILTER_TEACHER:String = "EDUCATE_FILTER_TEACHER";
		public static const EDUCATE_EXPEL:String = "EDUCATE_EXPEL";
		public static const EDUCATE_DROPOUT:String = "EDUCATE_DROPOUT";
		public static const EDUCATE_GET_CLAN_INFO:String = "EDUCATE_GET_CLAN_INFO";
		public static const EDUCATE_GET_INFO:String = "EDUCATE_GET_INFO";
		public static const EDUCATE_MORAL_VALUE_TO_EXP:String = "EDUCATE_MORAL_VALUE_TO_EXP";
		public static const EDUCATE_UPGRADE:String = "EDUCATE_UPGRADE";
		public static const EDUCATE_INVITE_APPRENTICE:String = "EDUCATE_INVITE_APPRENTICE";
		public static const EDUCATE_INVITE_ADMISSIONS:String = "EDUCATE_INVITE_ADMISSIONS";
		public static const EDUCATE_GET_STUDENTS_INFO:String = "EDUCATE_GET_STUDENTS_INFO";
		public static const EDUCATE_INVITE_APPRENTICE_RESULT:String = "EDUCATE_INVITE_APPRENTICE_RESULT";
		public static const EDUCATE_INVITE_ADMISSIONS_RESULT:String = "EDUCATE_INVITE_ADMISSIONS_RESULT";
		public static const EDUCATE_TEACHER_ONLINE:String = "EDUCATE_TEACHER_ONLINE";
		public static const EDUCATE_STUDENT_ONLINE:String = "EDUCATE_STUDENT_ONLINE";
		public static const EDUCATE_MORAL_VALUE_TO_PKPOINT:String = "EDUCATE_MORAL_VALUE_TO_PKPOINT";
		public static const EDUCATE_GET_EXPEL_MORAL_VALUE:String = "EDUCATE_GET_EXPEL_MORAL_VALUE";
		public static const EDUCATE_GET_DROPOUT_MORAL_VALUE:String = "EDUCATE_GET_DROPOUT_MORAL_VALUE";
		public static const EDUCATE_TIP_CAPTAIN:String = "EDUCATE_TIP_CAPTAIN";
		public static const EDUCATE_CALL_HELPER:String = "EDUCATE_CALL_HELPER";
		public static const EDUCATE_AGREE_HELP:String = "EDUCATE_AGREE_HELP";
		public static const EDUCATE_GET_RELATE_PEOPLE:String = "EDUCATE_GET_RELATE_PEOPLE";
		public static const EDUCATE_TRANSFER:String = "EDUCATE_TRANSFER";
		public static const EDUCATE_RELEASE:String = "EDUCATE_RELEASE";

		//GM
		public static const GM_COMPLAINT:String = "GM_COMPLAINT";
		public static const GM_SCORE:String = "GM_SCORE";

		//RANKING
		public static const RANKING_CONFIG:String = "RANKING_CONFIG";
		public static const RANKING_GET_RANKINFO:String = "RANKING_GET_RANKINFO";
		public static const RANKING_ROLE_LEVEL_RANK:String = "RANKING_ROLE_LEVEL_RANK";
		public static const RANKING_FAMILY_ACTIVE_RANK:String = "RANKING_FAMILY_ACTIVE_RANK";
		public static const RANKING_EQUIP_REFINING_RANK:String = "RANKING_EQUIP_REFINING_RANK";
		public static const RANKING_EQUIP_REINFORCE_RANK:String = "RANKING_EQUIP_REINFORCE_RANK";
		public static const RANKING_EQUIP_STONE_RANK:String = "RANKING_EQUIP_STONE_RANK";
		public static const RANKING_ROLE_WORLD_PKPOINT_RANK:String = "RANKING_ROLE_WORLD_PKPOINT_RANK";
		public static const RANKING_ROLE_PKPOINT_RANK:String = "RANKING_ROLE_PKPOINT_RANK";
		public static const RANKING_EQUIP_JOIN_RANK:String = "RANKING_EQUIP_JOIN_RANK";
		public static const RANKING_ROLE_ALL_RANK:String = "RANKING_ROLE_ALL_RANK";
		public static const RANKING_ROLE_GONGXUN_RANK:String = "RANKING_ROLE_GONGXUN_RANK";
		public static const RANKING_FAMILY_GONGXUN_RANK:String = "RANKING_FAMILY_GONGXUN_RANK";
		public static const RANKING_ROLE_TODAY_GONGXUN_RANK:String = "RANKING_ROLE_TODAY_GONGXUN_RANK";
		public static const RANKING_ROLE_YESTERDAY_GONGXUN_RANK:String = "RANKING_ROLE_YESTERDAY_GONGXUN_RANK";
		public static const RANKING_ROLE_GIVE_FLOWERS_RANK:String = "RANKING_ROLE_GIVE_FLOWERS_RANK";
		public static const RANKING_ROLE_GIVE_FLOWERS_TODAY_RANK:String = "RANKING_ROLE_GIVE_FLOWERS_TODAY_RANK";
		public static const RANKING_ROLE_GIVE_FLOWERS_YESTERDAY_RANK:String = "RANKING_ROLE_GIVE_FLOWERS_YESTERDAY_RANK";
		public static const RANKING_ROLE_RECE_FLOWERS_RANK:String = "RANKING_ROLE_RECE_FLOWERS_RANK";
		public static const RANKING_ROLE_RECE_FLOWERS_TODAY_RANK:String = "RANKING_ROLE_RECE_FLOWERS_TODAY_RANK";
		public static const RANKING_ROLE_RECE_FLOWERS_YESTERDAY_RANK:String = "RANKING_ROLE_RECE_FLOWERS_YESTERDAY_RANK";
		public static const RANKING_ROLE_RECE_FLOWERS_LAST_WEEK_RANK:String = "RANKING_ROLE_RECE_FLOWERS_LAST_WEEK_RANK";
		public static const RANKING_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK:String = "RANKING_ROLE_GIVE_FLOWERS_LAST_WEEK_RANK";
		public static const RANKING_ROLE_RECE_FLOWERS_THIS_WEEK_RANK:String = "RANKING_ROLE_RECE_FLOWERS_THIS_WEEK_RANK";
		public static const RANKING_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK:String = "RANKING_ROLE_GIVE_FLOWERS_THIS_WEEK_RANK";
		public static const RANKING_ROLE_PET_RANK:String = "RANKING_ROLE_PET_RANK";
		public static const RANKING_PET_JOIN_RANK:String = "RANKING_PET_JOIN_RANK";
		public static const RANKING_HERO_FB_RANK:String = "RANKING_HERO_FB_RANK";
		public static const RANKING_GET_RANK:String = "RANKING_GET_RANK";

		//WAROFKING
		public static const WAROFKING_HOLD:String = "WAROFKING_HOLD";
		public static const WAROFKING_GETMARKS:String = "WAROFKING_GETMARKS";
		public static const WAROFKING_APPLY:String = "WAROFKING_APPLY";
		public static const WAROFKING_COLLECT:String = "WAROFKING_COLLECT";
		public static const WAROFKING_AGREE_ENTER:String = "WAROFKING_AGREE_ENTER";
		public static const WAROFKING_BREAK:String = "WAROFKING_BREAK";
		public static const WAROFKING_HOLDING:String = "WAROFKING_HOLDING";
		public static const WAROFKING_END:String = "WAROFKING_END";
		public static const WAROFKING_SAFETIME:String = "WAROFKING_SAFETIME";
		public static const WAROFKING_ENTER:String = "WAROFKING_ENTER";

		//TRAININGCAMP
		public static const TRAININGCAMP_EXCHANGE:String = "TRAININGCAMP_EXCHANGE";
		public static const TRAININGCAMP_START:String = "TRAININGCAMP_START";
		public static const TRAININGCAMP_STOP:String = "TRAININGCAMP_STOP";
		public static const TRAININGCAMP_STATE:String = "TRAININGCAMP_STATE";
		public static const TRAININGCAMP_REMAIN_POINT:String = "TRAININGCAMP_REMAIN_POINT";

		//TITLE
		public static const TITLE_GET_ROLE_TITLES:String = "TITLE_GET_ROLE_TITLES";
		public static const TITLE_CHANGE_CUR_TITLE:String = "TITLE_CHANGE_CUR_TITLE";

		//WAROFFACTION
		public static const WAROFFACTION_WARINFO:String = "WAROFFACTION_WARINFO";
		public static const WAROFFACTION_DECLARE:String = "WAROFFACTION_DECLARE";
		public static const WAROFFACTION_BUY_GUARDER:String = "WAROFFACTION_BUY_GUARDER";
		public static const WAROFFACTION_CONVENE:String = "WAROFFACTION_CONVENE";
		public static const WAROFFACTION_TRANSFER:String = "WAROFFACTION_TRANSFER";
		public static const WAROFFACTION_TOWER_DESTROYED:String = "WAROFFACTION_TOWER_DESTROYED";
		public static const WAROFFACTION_GENERAL_KILLED:String = "WAROFFACTION_GENERAL_KILLED";
		public static const WAROFFACTION_FLAG_DESTROYED:String = "WAROFFACTION_FLAG_DESTROYED";
		public static const WAROFFACTION_COLLECT:String = "WAROFFACTION_COLLECT";
		public static const WAROFFACTION_AGREE_COLLECT:String = "WAROFFACTION_AGREE_COLLECT";
		public static const WAROFFACTION_STATUS:String = "WAROFFACTION_STATUS";
		public static const WAROFFACTION_GATHER_FACTIONIST:String = "WAROFFACTION_GATHER_FACTIONIST";
		public static const WAROFFACTION_GATHER_CONFIRM:String = "WAROFFACTION_GATHER_CONFIRM";
		public static const WAROFFACTION_RECORD:String = "WAROFFACTION_RECORD";
		public static const WAROFFACTION_COUNT_DOWN:String = "WAROFFACTION_COUNT_DOWN";
		public static const WAROFFACTION_RANK:String = "WAROFFACTION_RANK";

		//OFFICE
		public static const OFFICE_APPOINT:String = "OFFICE_APPOINT";
		public static const OFFICE_DISAPPOINT:String = "OFFICE_DISAPPOINT";
		public static const OFFICE_AGREE_APPOINT:String = "OFFICE_AGREE_APPOINT";
		public static const OFFICE_REFUSE_APPOINT:String = "OFFICE_REFUSE_APPOINT";
		public static const OFFICE_CANCEL_APPOINT:String = "OFFICE_CANCEL_APPOINT";
		public static const OFFICE_LAUNCH_COLLECTION:String = "OFFICE_LAUNCH_COLLECTION";
		public static const OFFICE_DONATE:String = "OFFICE_DONATE";
		public static const OFFICE_PANEL:String = "OFFICE_PANEL";
		public static const OFFICE_SET_NOTICE:String = "OFFICE_SET_NOTICE";
		public static const OFFICE_EQUIP_PANEL:String = "OFFICE_EQUIP_PANEL";
		public static const OFFICE_TAKE_EQUIP:String = "OFFICE_TAKE_EQUIP";

		//WAROFCITY
		public static const WAROFCITY_APPLY:String = "WAROFCITY_APPLY";
		public static const WAROFCITY_COLLECT:String = "WAROFCITY_COLLECT";
		public static const WAROFCITY_GET_MARK:String = "WAROFCITY_GET_MARK";
		public static const WAROFCITY_HOLD:String = "WAROFCITY_HOLD";
		public static const WAROFCITY_END:String = "WAROFCITY_END";
		public static const WAROFCITY_GET_SAFETIME:String = "WAROFCITY_GET_SAFETIME";
		public static const WAROFCITY_AGREE_ENTER:String = "WAROFCITY_AGREE_ENTER";
		public static const WAROFCITY_BREAK:String = "WAROFCITY_BREAK";
		public static const WAROFCITY_HOLD_SUCC:String = "WAROFCITY_HOLD_SUCC";
		public static const WAROFCITY_PANEL:String = "WAROFCITY_PANEL";
		public static const WAROFCITY_PANEL_MANAGE:String = "WAROFCITY_PANEL_MANAGE";
		public static const WAROFCITY_GET_REWARD:String = "WAROFCITY_GET_REWARD";

		//ACHIEVEMENT
		public static const ACHIEVEMENT_NOTICE:String = "ACHIEVEMENT_NOTICE";
		public static const ACHIEVEMENT_AWARD:String = "ACHIEVEMENT_AWARD";
		public static const ACHIEVEMENT_QUERY:String = "ACHIEVEMENT_QUERY";

		//SERVER_NPC
		public static const SERVER_NPC_ENTER:String = "SERVER_NPC_ENTER";
		public static const SERVER_NPC_QUIT:String = "SERVER_NPC_QUIT";
		public static const SERVER_NPC_DEAD:String = "SERVER_NPC_DEAD";
		public static const SERVER_NPC_ATTR_CHANGE:String = "SERVER_NPC_ATTR_CHANGE";
		public static const SERVER_NPC_WALK_PATH:String = "SERVER_NPC_WALK_PATH";
		public static const SERVER_NPC_WALK:String = "SERVER_NPC_WALK";

		//VIE_WORLD_FB
		public static const VIE_WORLD_FB_ENTER:String = "VIE_WORLD_FB_ENTER";
		public static const VIE_WORLD_FB_QUIT:String = "VIE_WORLD_FB_QUIT";

		//COLLECT
		public static const COLLECT_GET_GRAFTS_INFO:String = "COLLECT_GET_GRAFTS_INFO";
		public static const COLLECT_GRAFTS:String = "COLLECT_GRAFTS";
		public static const COLLECT_REMOVE_GRAFTS:String = "COLLECT_REMOVE_GRAFTS";
		public static const COLLECT_STOP:String = "COLLECT_STOP";
		public static const COLLECT_UPDATA_GRAFTS:String = "COLLECT_UPDATA_GRAFTS";

		//PERSONYBC
		public static const PERSONYBC_PUBLIC:String = "PERSONYBC_PUBLIC";
		public static const PERSONYBC_CANCEL:String = "PERSONYBC_CANCEL";
		public static const PERSONYBC_COMMIT:String = "PERSONYBC_COMMIT";
		public static const PERSONYBC_INFO:String = "PERSONYBC_INFO";
		public static const PERSONYBC_COLOR_CHANGE:String = "PERSONYBC_COLOR_CHANGE";
		public static const PERSONYBC_TIMER:String = "PERSONYBC_TIMER";
		public static const PERSONYBC_POS:String = "PERSONYBC_POS";
		public static const PERSONYBC_FACTION:String = "PERSONYBC_FACTION";
		public static const PERSONYBC_FACTION_NOTICE:String = "PERSONYBC_FACTION_NOTICE";
		public static const PERSONYBC_SOS:String = "PERSONYBC_SOS";
		public static const PERSONYBC_AUTO:String = "PERSONYBC_AUTO";
		public static const PERSONYBC_SET_AUTO:String = "PERSONYBC_SET_AUTO";
		public static const PERSONYBC_AUTO_REFRESH_COLOR:String = "PERSONYBC_AUTO_REFRESH_COLOR";

		//EQUIPONEKEY
		public static const EQUIPONEKEY_LIST:String = "EQUIPONEKEY_LIST";
		public static const EQUIPONEKEY_INFO:String = "EQUIPONEKEY_INFO";
		public static const EQUIPONEKEY_SAVE:String = "EQUIPONEKEY_SAVE";
		public static const EQUIPONEKEY_LOAD:String = "EQUIPONEKEY_LOAD";

		//ACTIVITY
		public static const ACTIVITY_TODAY:String = "ACTIVITY_TODAY";
		public static const ACTIVITY_BENEFIT_LIST:String = "ACTIVITY_BENEFIT_LIST";
		public static const ACTIVITY_BENEFIT_REWARD:String = "ACTIVITY_BENEFIT_REWARD";
		public static const ACTIVITY_BENEFIT_BUY:String = "ACTIVITY_BENEFIT_BUY";
		public static const ACTIVITY_GETGIFT:String = "ACTIVITY_GETGIFT";
		public static const ACTIVITY_PAY_GIFT_INFO:String = "ACTIVITY_PAY_GIFT_INFO";
		public static const ACTIVITY_BOSS_GROUP:String = "ACTIVITY_BOSS_GROUP";

		//NEWCOMER
		public static const NEWCOMER_ACTIVATE_CODE:String = "NEWCOMER_ACTIVATE_CODE";

		//TRADING
		public static const TRADING_SHOP:String = "TRADING_SHOP";
		public static const TRADING_BUY:String = "TRADING_BUY";
		public static const TRADING_SALE:String = "TRADING_SALE";
		public static const TRADING_GET:String = "TRADING_GET";
		public static const TRADING_RETURN:String = "TRADING_RETURN";
		public static const TRADING_EXCHANGE:String = "TRADING_EXCHANGE";
		public static const TRADING_STATUS:String = "TRADING_STATUS";

		//FLOWERS
		public static const FLOWERS_GET_ACCEPT_LIST:String = "FLOWERS_GET_ACCEPT_LIST";
		public static const FLOWERS_UPDATE_ACCEPT:String = "FLOWERS_UPDATE_ACCEPT";
		public static const FLOWERS_ACCEPT:String = "FLOWERS_ACCEPT";
		public static const FLOWERS_GIVE:String = "FLOWERS_GIVE";
		public static const FLOWERS_GIVE_WORLD_BROADCAST:String = "FLOWERS_GIVE_WORLD_BROADCAST";
		public static const FLOWERS_GIVE_FACTION_BROADCAST:String = "FLOWERS_GIVE_FACTION_BROADCAST";
		public static const FLOWERS_GIVE_MAP_BROADCAST:String = "FLOWERS_GIVE_MAP_BROADCAST";
		public static const FLOWERS_GET_RECEVER_INFO:String = "FLOWERS_GET_RECEVER_INFO";

		//PLANT
		public static const PLANT_FAMILY_FARM:String = "PLANT_FAMILY_FARM";
		public static const PLANT_UPDATE_FARM:String = "PLANT_UPDATE_FARM";
		public static const PLANT_ASSART:String = "PLANT_ASSART";
		public static const PLANT_SOW:String = "PLANT_SOW";
		public static const PLANT_FERTILIZE:String = "PLANT_FERTILIZE";
		public static const PLANT_LIST_LOG:String = "PLANT_LIST_LOG";
		public static const PLANT_CLEAR_LOG:String = "PLANT_CLEAR_LOG";
		public static const PLANT_HARVEST:String = "PLANT_HARVEST";
		public static const PLANT_SHOW_SKILL:String = "PLANT_SHOW_SKILL";
		public static const PLANT_UPGRADE_SKILL:String = "PLANT_UPGRADE_SKILL";
		public static const PLANT_LIST_SEEDS:String = "PLANT_LIST_SEEDS";

		//COUNTRY_TREASURE
		public static const COUNTRY_TREASURE_ENTER:String = "COUNTRY_TREASURE_ENTER";
		public static const COUNTRY_TREASURE_QUIT:String = "COUNTRY_TREASURE_QUIT";
		public static const COUNTRY_TREASURE_POINTS:String = "COUNTRY_TREASURE_POINTS";
		public static const COUNTRY_TREASURE_QUERY:String = "COUNTRY_TREASURE_QUERY";

		//LEVEL_GIFT
		public static const LEVEL_GIFT_LIST:String = "LEVEL_GIFT_LIST";
		public static const LEVEL_GIFT_ACCEPT:String = "LEVEL_GIFT_ACCEPT";
		public static const TIME_GIFT_LIST:String = "TIME_GIFT_LIST";
		public static const TIME_GIFT_ACCEPT:String = "TIME_GIFT_ACCEPT";

		//PET
		public static const PET_ENTER:String = "PET_ENTER";
		public static const PET_QUIT:String = "PET_QUIT";
		public static const PET_DEAD:String = "PET_DEAD";
		public static const PET_ATTR_CHANGE:String = "PET_ATTR_CHANGE";
		public static const PET_SUMMON:String = "PET_SUMMON";
		public static const PET_CALL_BACK:String = "PET_CALL_BACK";
		public static const PET_THROW:String = "PET_THROW";
		public static const PET_LEARN_SKILL:String = "PET_LEARN_SKILL";
		public static const PET_LEVEL_UP:String = "PET_LEVEL_UP";
		public static const PET_INFO:String = "PET_INFO";
		public static const PET_BAG_INFO:String = "PET_BAG_INFO";
		public static const PET_ATTR_ASSIGN:String = "PET_ATTR_ASSIGN";
		public static const PET_ADD_LIFE:String = "PET_ADD_LIFE";
		public static const PET_REFRESH_APTITUDE:String = "PET_REFRESH_APTITUDE";
		public static const PET_ADD_UNDERSTANDING:String = "PET_ADD_UNDERSTANDING";
		public static const PET_CHANGE_NAME:String = "PET_CHANGE_NAME";
		public static const PET_FEED_INFO:String = "PET_FEED_INFO";
		public static const PET_FEED_BEGIN:String = "PET_FEED_BEGIN";
		public static const PET_FEED_COMMIT:String = "PET_FEED_COMMIT";
		public static const PET_FEED_GIVE_UP:String = "PET_FEED_GIVE_UP";
		public static const PET_FEED_OVER:String = "PET_FEED_OVER";
		public static const PET_FEED_STAR_UP:String = "PET_FEED_STAR_UP";
		public static const PET_GROW_INFO:String = "PET_GROW_INFO";
		public static const PET_GROW_BEGIN:String = "PET_GROW_BEGIN";
		public static const PET_GROW_OVER:String = "PET_GROW_OVER";
		public static const PET_GROW_GIVE_UP:String = "PET_GROW_GIVE_UP";
		public static const PET_GROW_COMMIT:String = "PET_GROW_COMMIT";
		public static const PET_ADD_SKILL_GRID:String = "PET_ADD_SKILL_GRID";
		public static const PET_FORGET_SKILL:String = "PET_FORGET_SKILL";
		public static const PET_CHANGE_POS:String = "PET_CHANGE_POS";
		public static const PET_REFINING:String = "PET_REFINING";
		public static const PET_REFINING_EXP:String = "PET_REFINING_EXP";
		public static const PET_EGG_USE:String = "PET_EGG_USE";
		public static const PET_EGG_REFRESH:String = "PET_EGG_REFRESH";
		public static const PET_EGG_ADOPT:String = "PET_EGG_ADOPT";
		public static const PET_TRICK_LEARN:String = "PET_TRICK_LEARN";
		public static const PET_TRICK_UPGRADE:String = "PET_TRICK_UPGRADE";
		public static const PET_ADD_BAG:String = "PET_ADD_BAG";
		public static const PET_TRAINING_REQUEST:String = "PET_TRAINING_REQUEST";

		//STAT
		public static const STAT_BUTTON:String = "STAT_BUTTON";
		public static const STAT_CONFIG:String = "STAT_CONFIG";

		//SPY
		public static const SPY_FACTION:String = "SPY_FACTION";
		public static const SPY_FACTION_TIME:String = "SPY_FACTION_TIME";
		public static const SPY_TIME:String = "SPY_TIME";

		//EDUCATE_FB
		public static const EDUCATE_FB_ENTER:String = "EDUCATE_FB_ENTER";
		public static const EDUCATE_FB_QUIT:String = "EDUCATE_FB_QUIT";
		public static const EDUCATE_FB_AWARD:String = "EDUCATE_FB_AWARD";
		public static const EDUCATE_FB_QUERY:String = "EDUCATE_FB_QUERY";
		public static const EDUCATE_FB_GAMBLING:String = "EDUCATE_FB_GAMBLING";
		public static const EDUCATE_FB_ITEM:String = "EDUCATE_FB_ITEM";

		//JAIL
		public static const JAIL_OUT:String = "JAIL_OUT";
		public static const JAIL_DONATE:String = "JAIL_DONATE";
		public static const JAIL_OUT_FORCE:String = "JAIL_OUT_FORCE";

		//PRESENT
		public static const PRESENT_NOTIFY:String = "PRESENT_NOTIFY";
		public static const PRESENT_GET:String = "PRESENT_GET";

		//CONLOGIN
		public static const CONLOGIN_FETCH:String = "CONLOGIN_FETCH";
		public static const CONLOGIN_INFO:String = "CONLOGIN_INFO";
		public static const CONLOGIN_NOTSHOW:String = "CONLOGIN_NOTSHOW";
		public static const CONLOGIN_CLEAR:String = "CONLOGIN_CLEAR";

		//FMLSKILL
		public static const FMLSKILL_RESEARCH:String = "FMLSKILL_RESEARCH";
		public static const FMLSKILL_FORGET:String = "FMLSKILL_FORGET";
		public static const FMLSKILL_LIST:String = "FMLSKILL_LIST";
		public static const FMLSKILL_LIST_BUFF:String = "FMLSKILL_LIST_BUFF";
		public static const FMLSKILL_FETCH_BUFF:String = "FMLSKILL_FETCH_BUFF";

		//PERSONAL_FB
		public static const PERSONAL_FB_LIST:String = "PERSONAL_FB_LIST";
		public static const PERSONAL_FB_ENTER:String = "PERSONAL_FB_ENTER";
		public static const PERSONAL_FB_LOST:String = "PERSONAL_FB_LOST";
		public static const PERSONAL_FB_QUIT:String = "PERSONAL_FB_QUIT";
		public static const PERSONAL_FB_NEXT_LEVEL:String = "PERSONAL_FB_NEXT_LEVEL";
		public static const PERSONAL_FB_PASS:String = "PERSONAL_FB_PASS";
		public static const PERSONAL_FB_STATE:String = "PERSONAL_FB_STATE";

		//ACCUMULATE_EXP
		public static const ACCUMULATE_EXP_REFRESH:String = "ACCUMULATE_EXP_REFRESH";
		public static const ACCUMULATE_EXP_INFO:String = "ACCUMULATE_EXP_INFO";
		public static const ACCUMULATE_EXP_FETCH:String = "ACCUMULATE_EXP_FETCH";
		public static const ACCUMULATE_EXP_NOTIFY:String = "ACCUMULATE_EXP_NOTIFY";
		public static const ACCUMULATE_EXP_LIST:String = "ACCUMULATE_EXP_LIST";
		public static const ACCUMULATE_EXP_VIEW:String = "ACCUMULATE_EXP_VIEW";
		public static const ACCUMULATE_EXP_GET:String = "ACCUMULATE_EXP_GET";
		public static const ACCUMULATE_EXP_REF:String = "ACCUMULATE_EXP_REF";

		//TRAP
		public static const TRAP_ENTER:String = "TRAP_ENTER";
		public static const TRAP_QUIT:String = "TRAP_QUIT";

		//FMLDEPOT
		public static const FMLDEPOT_LIST_GOODS:String = "FMLDEPOT_LIST_GOODS";
		public static const FMLDEPOT_CREATE:String = "FMLDEPOT_CREATE";
		public static const FMLDEPOT_PUTIN:String = "FMLDEPOT_PUTIN";
		public static const FMLDEPOT_GETOUT:String = "FMLDEPOT_GETOUT";
		public static const FMLDEPOT_UPDATE_GOODS:String = "FMLDEPOT_UPDATE_GOODS";
		public static const FMLDEPOT_LIST_LOG:String = "FMLDEPOT_LIST_LOG";

		//VIP
		public static const VIP_ACTIVE:String = "VIP_ACTIVE";
		public static const VIP_MULTI_EXP:String = "VIP_MULTI_EXP";
		public static const VIP_INFO:String = "VIP_INFO";
		public static const VIP_STOP_NOTIFY:String = "VIP_STOP_NOTIFY";
		public static const VIP_LIST:String = "VIP_LIST";
		public static const VIP_REMOTE_DEPOT:String = "VIP_REMOTE_DEPOT";
		public static const VIP_EXCHANGE_PRESTIGE:String = "VIP_EXCHANGE_PRESTIGE";

		//SCENE_WAR_FB
		public static const SCENE_WAR_FB_ENTER:String = "SCENE_WAR_FB_ENTER";
		public static const SCENE_WAR_FB_QUIT:String = "SCENE_WAR_FB_QUIT";
		public static const SCENE_WAR_FB_QUERY:String = "SCENE_WAR_FB_QUERY";
		public static const SCENE_WAR_FB_CALL_MONSTER:String = "SCENE_WAR_FB_CALL_MONSTER";

		//BGP
		public static const BGP_LOGIN:String = "BGP_LOGIN";

		//GIFT
		public static const GIFT_ITEM_AWARD:String = "GIFT_ITEM_AWARD";
		public static const GIFT_ITEM_QUERY:String = "GIFT_ITEM_QUERY";

		//BONFIRE
		public static const BONFIRE_UP:String = "BONFIRE_UP";
		public static const BONFIRE_RM:String = "BONFIRE_RM";
		public static const BONFIRE_ADD_FAGOT:String = "BONFIRE_ADD_FAGOT";
		public static const BONFIRE_GET:String = "BONFIRE_GET";

		//HERO_FB
		public static const HERO_FB_PANEL:String = "HERO_FB_PANEL";
		public static const HERO_FB_REPORT:String = "HERO_FB_REPORT";
		public static const HERO_FB_ENTER:String = "HERO_FB_ENTER";
		public static const HERO_FB_STATE:String = "HERO_FB_STATE";
		public static const HERO_FB_QUIT:String = "HERO_FB_QUIT";
		public static const HERO_FB_REWARD:String = "HERO_FB_REWARD";
		public static const HERO_FB_BUY:String = "HERO_FB_BUY";
		public static const HERO_FB_POKER_REWARD:String = "HERO_FB_POKER_REWARD";

		//FAMILY_COLLECT
		public static const FAMILY_COLLECT_INFO:String = "FAMILY_COLLECT_INFO";
		public static const FAMILY_COLLECT_PRIZE_INFO:String = "FAMILY_COLLECT_PRIZE_INFO";
		public static const FAMILY_COLLECT_REFRESH_PRIZE:String = "FAMILY_COLLECT_REFRESH_PRIZE";
		public static const FAMILY_COLLECT_GET_PRIZE:String = "FAMILY_COLLECT_GET_PRIZE";
		public static const FAMILY_COLLECT_BEGIN:String = "FAMILY_COLLECT_BEGIN";
		public static const FAMILY_COLLECT_GET_ROLE_INFO:String = "FAMILY_COLLECT_GET_ROLE_INFO";

		//MISSION_FB
		public static const MISSION_FB_ENTER:String = "MISSION_FB_ENTER";
		public static const MISSION_FB_QUIT:String = "MISSION_FB_QUIT";
		public static const MISSION_FB_PROP:String = "MISSION_FB_PROP";

		//GOAL
		public static const GOAL_INFO:String = "GOAL_INFO";
		public static const GOAL_FETCH:String = "GOAL_FETCH";
		public static const GOAL_UPDATE:String = "GOAL_UPDATE";

		//PRESTIGE
		public static const PRESTIGE_QUERY:String = "PRESTIGE_QUERY";
		public static const PRESTIGE_DEAL:String = "PRESTIGE_DEAL";

		//SPECIAL_ACTIVITY
		public static const SPECIAL_ACTIVITY_GET_PRIZE:String = "SPECIAL_ACTIVITY_GET_PRIZE";
		public static const SPECIAL_ACTIVITY_ABLE_GET:String = "SPECIAL_ACTIVITY_ABLE_GET";
		public static const SPECIAL_ACTIVITY_LIST:String = "SPECIAL_ACTIVITY_LIST";
		public static const SPECIAL_ACTIVITY_DETAIL:String = "SPECIAL_ACTIVITY_DETAIL";
		public static const SPECIAL_ACTIVITY_STAT:String = "SPECIAL_ACTIVITY_STAT";

		//SHUAQI_FB
		public static const SHUAQI_FB_REQUEST:String = "SHUAQI_FB_REQUEST";

		//EXERCISE_FB
		public static const EXERCISE_FB_REQUEST:String = "EXERCISE_FB_REQUEST";

		//CHAT
		public static const CHAT_AUTH:String = "CHAT_AUTH";
		public static const CHAT_IN_CHANNEL:String = "CHAT_IN_CHANNEL";
		public static const CHAT_IN_PAIRS:String = "CHAT_IN_PAIRS";
		public static const CHAT_LEAVE_CHANNEL:String = "CHAT_LEAVE_CHANNEL";
		public static const CHAT_MANAGE_MUTE:String = "CHAT_MANAGE_MUTE";
		public static const CHAT_MANAGE_KICK:String = "CHAT_MANAGE_KICK";
		public static const CHAT_MANAGE_BAN:String = "CHAT_MANAGE_BAN";
		public static const CHAT_JOIN_CHANNEL:String = "CHAT_JOIN_CHANNEL";
		public static const CHAT_ADD_BLACK:String = "CHAT_ADD_BLACK";
		public static const CHAT_REMOVE_BLACK:String = "CHAT_REMOVE_BLACK";
		public static const CHAT_BLACK_LIST:String = "CHAT_BLACK_LIST";
		public static const CHAT_LIMIT_NOTIFY:String = "CHAT_LIMIT_NOTIFY";
		public static const CHAT_NEW_JOIN:String = "CHAT_NEW_JOIN";
		public static const CHAT_QUICK:String = "CHAT_QUICK";
		public static const CHAT_STATUS_CHANGE:String = "CHAT_STATUS_CHANGE";
		public static const CHAT_GET_ROLES:String = "CHAT_GET_ROLES";
		public static const CHAT_WAROFKING:String = "CHAT_WAROFKING";
		public static const CHAT_GET_GOODS:String = "CHAT_GET_GOODS";
		public static const CHAT_RECONNECT:String = "CHAT_RECONNECT";
		public static const CHAT_KING_BAN:String = "CHAT_KING_BAN";
		public function SocketCommand()
		{
			
		}
	}
}