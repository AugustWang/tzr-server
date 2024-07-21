package modules.chat
{
	import proto.chat.m_chat_auth_toc;
	import proto.common.p_channel_info;
	import proto.common.p_chat_role;

	public class ChatType
	{
		
		public static var channels:m_chat_auth_toc;
		/**
		 * 综合频道
		 */ 
		public static const WORLD_CHANNEL:String = "worldChannel";
		/**
		 * 国家频道
		 */ 
		public static const COUNTRY_CHANNEL:String = "countryChannel";
		/**
		 * 门派频道
		 */ 
		public static const FAMILY_CHANNEL:String = "familyChannel";
		/**
		 * 附近聊天 
		 */
		public static const BUBBLE_CHANNEL:String = "bubbleChannel";
		/**
		 * 私聊频道
		 */ 
		public static const PRIVATE_CHANNEL:String = "privateChannel";
		/**
		 * 组队频道
		 */		
		public static const TEAM_CHANNEL:String = "teamChannel";
		/**
		 * 群组聊天 
		 */		
		public static const GROUP_CHANNEL:String = "groupChannel";
		
		
		/**
		 * 传音，用line发送。 
		 */		
		public static const HORN_CHANNEL:String = "horn";
		public static const horn_money:int = 10*100;    //喇叭 10两。
		
		
		public static const WORLD_CHAT_LEVEL:int = 10; //世界聊天的等级
		
		public static const WORLD_CHAT_TIMES:Number = 3000;  //世界聊天间隔30秒  变成60秒了
		
		
		public static var chat_record_index:int;
		
		private static var record_array:Array = new Array();
		
		private static var _isUseHornGood:Boolean = false;
		
		
		public static function addRecord(msg:String,channel:String):void
		{
			var obj:Object = new Object;
			obj.msg = msg;
			obj.channel = channel;
			record_array.push(obj);
			while(record_array.length > 10)
			{
				record_array.shift();
			}
			chat_record_index = record_array.length; 
			
		}
		
		public static function getRecord(index:int):Object
		{
			if(index>=record_array.length)
			{
				chat_record_index = record_array.length;
				return null;
			}
			if(index<0)
			{
				chat_record_index = -1;
				return null;
			}
			return record_array[index];
		}
		
		public static function getChannel(type:String, sign:String = null):p_channel_info
		{
			var temp:int;
			switch(type)
			{
				case WORLD_CHANNEL:
					temp = 1;
					break;
				case COUNTRY_CHANNEL:
					temp = 2;
					break;
				case FAMILY_CHANNEL:
					temp = 3;
					break;
				case TEAM_CHANNEL:
					temp = 4;
					break;
			}
			
			for(var i:int = 0; i< channels.channel_list.length; i++)
			{
				var vo:p_channel_info = channels.channel_list[i] as p_channel_info;
				if(vo.channel_type == temp)
				{
					if(sign != null)
					{
						if(sign == vo.channel_sign)
							return vo;
					}
					else
						return vo;
				}
			}
			
			return null;
		}
		
		public static function getType(sign:String):String
		{
			var intType:int;
			for(var i:int = 0; i<channels.channel_list.length; i++)
			{
				var vo:p_channel_info = channels.channel_list[i] as p_channel_info;
				if(vo.channel_sign == sign)
				{
					intType = vo.channel_type;
					break;
				}
			}
			
			switch(intType)
			{
				case 1:
					return WORLD_CHANNEL;
					break;
				case 2:
					return COUNTRY_CHANNEL;
					break;
				case 3:
					return FAMILY_CHANNEL;
					break;
				case 4:
					return TEAM_CHANNEL;
					break;
				default:
					return GROUP_CHANNEL;
			}
		}
		
		public static function showOnWorldChannel(channel:String):Boolean
		{
			if(!channel)
				return false;
			var flag:Boolean;
			switch(channel)
			{
				case WORLD_CHANNEL:
					flag = true;
					break;
				case COUNTRY_CHANNEL:
					flag = true;
					break;
				case FAMILY_CHANNEL:
					flag = true;
					break;
				case PRIVATE_CHANNEL:
					flag = true;
					break;
				case TEAM_CHANNEL:
					flag = true;
					break;
				case BUBBLE_CHANNEL:
					flag = true;
					break;
				default: flag = false; break;
				
			}
			return flag;
			
		}
		
		public static function addChannel(value:p_channel_info):Boolean
		{
			if(channels == null)
				return false;
			for(var i:int = 0; i<channels.channel_list.length; i++)
			{
				var vo:p_channel_info = channels.channel_list[i] as p_channel_info;
				
				if(vo.channel_sign == value.channel_sign && vo.channel_type == value.channel_type)
				{
					return false;
				}
			}
			
			channels.channel_list.push(value);
			return true;
		}
		
		public static function removeChannel(type:int, sign:String):p_channel_info
		{
			if(channels == null)
				return null;
			
			for(var i:int = 0; i<channels.channel_list.length; i++)
			{
				var vo:p_channel_info = channels.channel_list[i] as p_channel_info;
				
				if(vo.channel_sign == sign && vo.channel_type == type)
				{
					return channels.channel_list.splice(i, 1) as p_channel_info;
				}
			}
			
			return null;
		}
		
		public static function isBlack(roleId:int):Boolean
		{
			if(channels == null)
				return false;
			var blacks:Array = channels.black_list;
			
			for(var i:int = 0; i < blacks.length; i++)
			{
				if(blacks[i].roleid == roleId)
					return true;
			}
			return false;
		}
		
		public static function addBlack(role:p_chat_role):void
		{
			if(channels == null)
				return;
			var exit:Boolean = false;
			
			for(var i:int = 0; i< channels.black_list.length; i++)
			{
				if(channels.black_list[i].roleid == role.roleid)
				{
					exit = true;
					break;
				}
					
			}
			if(!exit)
				channels.black_list.push(role);
		}
		
		public static function removeBlack(roleId:int):void
		{
			if(channels == null)
				return;
			var blacks:Array = channels.black_list;
			
			for(var i:int = 0; i < blacks.length; i++)
			{
				if(blacks[i].roleid == roleId)
				{
					blacks.splice(i, 1);
					return;
				}
				
			}
		}
		
		public static function getSelectedIndex(value:String):int
		{
			var index:int=-1;
			switch(value)
			{
				case WORLD_CHANNEL:index=0;break;
				
				case COUNTRY_CHANNEL:index=1;break;
					
				case FAMILY_CHANNEL:index=2;break;
					
				case TEAM_CHANNEL:index=3;break;
					
				case PRIVATE_CHANNEL:index=4;break;
				
//				case HORN_CHANNEL: index = 11;break;
				default:break;
			}
			return index;
		}
		
		public static function set useHornGood(flag:Boolean):void
		{
			_isUseHornGood = flag;
		}
		
		public static function isUseHornGood():Boolean
		{
			return _isUseHornGood;
		}
		
		
		/////////////////////
		public static function shieldChannel(channel:String):void
		{
			var msg:String = "";
			switch(channel)
			{
				case ChatType.WORLD_CHANNEL:
					msg = "你已屏蔽综合频道。";
					ChatModule.getInstance().sendChatMsg(msg, null, channel);
					break;
				case ChatType.FAMILY_CHANNEL:
					msg = "你已屏蔽门派频道。";
					ChatModule.getInstance().sendChatMsg(msg, null, channel);
					//					ChatModel.getInstance().chat.appendMessage(msg, null, channel);
					break;
				case ChatType.COUNTRY_CHANNEL:
					msg = "你已屏蔽国家频道。";
					ChatModule.getInstance().sendChatMsg(msg, null, channel);
					break;
				case ChatType.TEAM_CHANNEL:
					msg = "你已屏蔽组队频道。";
					ChatModule.getInstance().sendChatMsg(msg, null, channel);
					break;
				default: break;
			}
		}
		public  static function getCountryStr(id:int):String
		{
			var str:String ="<font color='#ffffff'>【世】</font>";//"<font color='#ffffff'>【世】</font>"+
			switch(id)
			{
				case 1:
					str = "<font color='#00ff00'>【洪】</font>"
					
					break;
				case 2:
					str = "<font color='#f600ff'>【永】</font>"
					
					break;
				case 3:
					str = "<font color='#00ccff'>【万】</font>"
					
					break;
				default : break;
			}
			return str;
		}
		
		public static function getTitleMark(i:int):String
		{
			var str:String="";
			switch(i)
			{
				case 1:
					str="★";
					break;
				case 2:
					str="❤";
					break;
				default :break;
				
			}
			return str;
		}
		
	}
}


