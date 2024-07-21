package modules.deal.views.stallViews
{
	import com.common.GlobalObjectManager;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.TextArea;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_chat_role;
	import proto.common.p_goods;
	import proto.line.m_stall_buy_toc;
	import proto.line.m_stall_chat_toc;
	import proto.line.p_stall_log;
	
	public class StallList extends Canvas
	{
		private var vsTxt:VScrollText;
		private var chat_role:p_chat_role;
		
		private var scrollPane:TextArea ;  //172 226
		private var text:TextField ;
		
		private var changeScroll:Boolean = false ;
		private var role:Object = {roleid:123,rolename:"" };
		private var roleArr:Array=[];
		
		private var chatIndex:Array;
		private var msgItems:Array ;
		private var menuItems:Array;
		private var targetRoleInfo:TargetRoleInfo;
		public function StallList()
		{
			init();
		}
		
		private function init():void
		{
			vsTxt = new VScrollText();
			vsTxt.width = 160;//171;
			vsTxt.height = 147;//173;
			vsTxt.bgColor =0xd9d6c3;
			vsTxt.bgAlpha = 0;//0.4;
			vsTxt.direction = ScrollDirection.RIGHT;
			addChild(vsTxt);
			
			menuItems = [MenuItemConstant.CHAT,MenuItemConstant.FRIEND]
			targetRoleInfo = new TargetRoleInfo();
				
			var tf:TextFormat = new TextFormat("Tahoma",12,0xffffff);
			tf.leading = 5;
			vsTxt.textField.defaultTextFormat = tf;
			vsTxt.textField.addEventListener(TextEvent.LINK,onNameClick);
			chatIndex  = new Array();
			msgItems = new Array();
		}
		
		public function resetInit():void
		{
			while(chatIndex.length>0)
			{
				chatIndex.pop();
			}
			while(msgItems.length>0)
			{
				msgItems.pop();
			}
			chatIndex  = null;
			msgItems = null;
			
			chatIndex  = new Array();
			msgItems = new Array();
			
			vsTxt.htmlText = "";
		}
		
		public function appendMsg(vo:Object, isBuy:Boolean):void
		{
			var date:Date = new Date();
			var time:String = DateFormatUtil.getHMBysecond(uint((date.getTime()/1000)));
			var role:Object = new Object();
			
			changeScroll = true ;
			
			if(isBuy)
			{
				var buyMsg:m_stall_buy_toc = vo as m_stall_buy_toc;
				role.roleid = buyMsg.role_id;
				role.rolename = buyMsg.role_name;
				
				var itemvo:BaseItemVO = DealModule.getInstance().getGoodsVoBuyId(buyMsg.goods_id);
				if(!itemvo)
				{
					return;
				}
				
				var color:String = ItemConstant.COLOR_VALUES[itemvo.color];
				var goodsName:String
				var equipVo:EquipVO = itemvo as EquipVO;
				if(equipVo && equipVo.quality > 1)
				{
					goodsName = getNameNum(ItemConstant.ITEM_QUALITY[equipVo.color]+""+itemvo.name,buyMsg.num,color);
				}else{
					
					goodsName = getNameNum(itemvo.name,buyMsg.num,color); //itemvo.name;//"XX";
				}
				
				var cost:String ="";
				if (itemvo.price_type == DealConstant.STALL_PRICE_TYPE_SILVER) {
					var totalprice:int = itemvo.unit_price * buyMsg.num;
					var arr:Array = DealConstant.silverToOther(totalprice);
					if(arr[0]>0)
					{
						cost = arr[0] + "锭";
					}
					if(arr[1]>0)
					{
						cost += arr[1] + "两";
					}
					if(arr[2]>0)
					{
						cost += arr[2] + "文";
					}
				} else {
					cost = itemvo.unit_price * buyMsg.num + "元宝";
				}
				
				addBuyMsg(time,role,goodsName,cost);
			}else{
				var chatMsg:m_stall_chat_toc = vo as m_stall_chat_toc;
				role.roleid = chatMsg.src_role_id;
				role.rolename = chatMsg.src_role_name;
				
				addChatMsg(chatMsg.content,role,time);
			}
		}
		
		//【2级攻击符石】
		private function getNameNum(name:String,num:int,color:String):String
		{
				return HtmlUtil.font(HtmlUtil.bold("【"+name+"】"),color) +"×"+String(num);
			
		}
		
		//buy_logs
		//chat_logs
		public function resettext():void
		{
			vsTxt.htmlText = "";
		}
		
		public function stall_log(arr:Array,isBuy:Boolean):void
		{
			if(!arr)
				return;
			var i:int;
			changeScroll = false ;
			
			if(isBuy)
			{
				// 购买信息
				for(i = 0; i<arr.length ; i++)
				{
					var buy_log:p_stall_log = arr[i] as p_stall_log;
					if(!buy_log) {
						return;
					}
					var role_info:Object = new Object();
					role_info.roleid = buy_log.src_role_id;
					role_info.rolename = buy_log.src_role_name;
					
					//  trace(" ...... time:"+buy_log.time);
					var buy_time:String = DateFormatUtil.getHMBysecond( buy_log.time);  //时间格式　16:50　
					
					var goods:p_goods = buy_log.goods_info;
					var bsItemVo:BaseItemVO = PackageModule.getInstance().getBaseItemVO(goods);
					
					var color:String = ItemConstant.COLOR_VALUES[bsItemVo.color];
					var goodsName:String;
					
					var equipVo:EquipVO = bsItemVo as EquipVO;
					if(equipVo && equipVo.quality > 1)
					{
						goodsName = getNameNum(ItemConstant.ITEM_QUALITY[equipVo.quality]+""+bsItemVo.name,buy_log.number,color);
					}else{
						
						goodsName = getNameNum(bsItemVo.name,buy_log.number,color); //itemvo.name;//"XX";
					}
					
					var cost:String="";
					if (buy_log.price_type == DealConstant.STALL_PRICE_TYPE_SILVER) {
						var array:Array = DealConstant.silverToOther(buy_log.price);
						if(array[0]>0)
						{
							cost = array[0] + "锭" ;
						}
						if(array[1]>0)
						{
							cost += array[1]　+"两";
						}
						if(array[2]>0)
						{
							cost += array[2] + "文";
						}
					} else {
						cost = buy_log.price + "元宝";
					}
					
					if(i==arr.length-1)
					{
						changeScroll = true;
					}
					
					//					addBuyMsg(buy_time,role_info,bsItemVo.name,buy_log.number,cost);
					addBuyMsg(buy_time,role_info,goodsName,cost);
				}
				
			}else{ 
				// 聊天信息
				for(i = 0; i<arr.length; i++)
				{
					var chat_log:p_stall_log =  arr[i] as p_stall_log;
					//					var chat_role:p_role_attr = chat_log.src_role_info;  // 聊天发起者；
					//					var chat_to_role:p_role_attr = chat_log.desc_role_info;  //聊天接收者；
					
					var chat_role:Object = new Object();
					chat_role.roleid = chat_log.src_role_id;
					chat_role.rolename = chat_log.src_role_name;
					
					var chat_to_role:Object = new Object();
					chat_to_role.roleid = chat_log.dest_role_id;
					chat_to_role.rolename = chat_log.dest_role_name;
					
					
					var chat_time:String = DateFormatUtil.getHMBysecond(chat_log.time);
					var content:String = chat_log.content;
					
					
					if(i==arr.length-1)
					{
						changeScroll = true;
					}
					addChatMsg(content,chat_role,chat_time);
				}
			}
		}
		
		
		private function addBuyMsg(time:String, role:Object, goodsName:String, cost:String):void
		{
			var item:String = "";
			if(role.roleid == GlobalObjectManager.getInstance().user.base.role_id)
			{
				item = "<font>" +
					"购买记录："+time +"\n" +
					"[<font color='#00ff00'>"+ role.rolename +
					"</font>]" + "购买"+
					goodsName +
					"共花费<font color='#ffff00'>"+ cost+ "</font>"  +
					"</font> \n" ;
				/*"<font>" +
				"购买记录："+time +"\n" +
				"[<font color='#00ff00'>"+ role.rolename +
				"</font>]" + "<font color='#ffff00'>购买</font>"+
				goodsName +
				"<font color='#ffff00'>共花费"+ cost+ "</font>"  +
				"</font> \n" ;*/
				
			}else
			{
				item = "<font>" +
					"购买记录："+time +"\n" +
					"[<font color='#00ff00'><a href='event:" + String(role.roleid) + "'>"+ role.rolename +
					"</a></font>]" + ",购买"+
					goodsName +
					"共花费<font color='#ffff00'>"+ cost+ "</font>"  +
					"</font> \n" ;
			}
				
			msgItems.push(item);
			
			var obj:Object = new Object();
			obj.role_id = role.roleid;
			obj.role_name = role.rolename;
			roleArr.push(obj);
			showMsg();
		}
		
		public function clearArr():void
		{
			while(msgItems.length>0)
			{
				msgItems.pop();
			}
			while(roleArr.length>0)
			{
				roleArr.pop();
			}
		}
		
		private function showMsg():void
		{
			if(!changeScroll )
				return;
			
			vsTxt.htmlText = "";
			
			for(var i:int =0;i<msgItems.length;i++)
			{
				vsTxt.htmlText += msgItems[i];
			}
			
			setTimeout(updateDisplay,200);
		}
		
		private function addChatMsg(str:String,role:Object, time:String):void
		{
			var i:int;
			var item:String="";
			if(role.roleid  == GlobalObjectManager.getInstance().user.base.role_id)
			{
				item = "<font>" + 
					"[<font color='#00ff00'>" +
					role.rolename + "</font>] :（" + time + "）\n" +
					str+ 
					"</font>\n";
				
			}else{
				item = "<font>" + 
					"[<font color='#00ff00'><a href='event:" + String(role.roleid) + "'>" +
					role.rolename + "</a></font>] :（" + time + "）\n" +
			        str+ 
					"</font>\n";
			}
			msgItems.push(item);
			if(chatIndex.length==30)
			{
				msgItems.splice(chatIndex[0],1);
				
				for(i=0;i<29;i++)
				{
					chatIndex[i] = chatIndex[i+1]-1;
				}
				chatIndex[29]=msgItems.length -1;
				
			}else{
				
				chatIndex[chatIndex.length] = msgItems.length -1;
			}
			
			showMsg();
			
			for(i=0;i<roleArr.length;i++)
			{
				var obj:Object = roleArr[i];
				if(obj.role_id == role.roleid)
				{
					return;
				}
			}
			
			var tmpObj:Object = new Object();
			tmpObj.role_id = role.roleid;
			tmpObj.role_name = role.rolename;
			roleArr.push(tmpObj);
			
		}
		
		private function updateDisplay():void
		{
			if(!changeScroll )
				return;
			
			if(vsTxt.vscrollBar)
			{
				vsTxt.vScrollPosition = vsTxt.vscrollBar.maxScrollPosition;
			}
			
		}
		
		private function onNameClick(evt:TextEvent):void
		{
			//  trace("evt.text:"+evt.text);
			chat_role = new p_chat_role();
			
			for(var i:int=0;i<roleArr.length;i++)
			{
				if(int(evt.text) == roleArr[i].role_id)
				{
					chat_role.roleid = roleArr[i].role_id;
					chat_role.rolename = roleArr[i].role_name;
				}
			}
			
			if(chat_role.roleid == GlobalObjectManager.getInstance().user.base.role_id)
				return;
				
			targetRoleInfo.roleId = chat_role.roleid;
			targetRoleInfo.roleName = chat_role.rolename;
			GameMenuItems.getInstance().show(menuItems,targetRoleInfo);
			//to do 开始私聊
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			if(text)
			{
				text = null;
				
			}
			
//			if(stallSaleMsgArr)
//			{
//				while(stallSaleMsgArr.length >0)
//				{
//					var str1:String = stallSaleMsgArr.pop();
//					str1 = null;
//				}
//			}
//			
//			if(stallChatArr)
//			{
//				while(stallChatArr.length >0)
//				{
//					var str2:String = stallChatArr.pop();
//					str2 = null;
//				}
//			}
			while(roleArr.length>0)
			{
				var r:p_chat_role = roleArr.pop() as p_chat_role;//= null;
				r = null;
			}
			
		}
		
		
	}
}


