package modules.flowers
{
	import com.loaders.CommonLocator;
	
	import modules.scene.SceneDataManager;
	
	import proto.line.m_flowers_give_faction_broadcast_toc;
	import proto.line.m_flowers_give_map_broadcast_toc;
	import proto.line.m_flowers_give_world_broadcast_toc;
	import proto.line.p_flowers_give_broadcast_info;
	import proto.line.p_flowers_give_info;

	public class FlowersTypes
	{
		public static const SEND_BTN_TOOLTIP:String = "1、请保证背包内有足够的鲜花；\n" +
														"2、异性之间可以签名送花；\n" +
														"3、可以向任何人“匿名送花”；\n";
		
		public static const REPYTYPE2:String = "很感谢你送的鲜花哦，" +
			"希望还有机会能再次收到你送的花！^_^"//^_^ ";
		public static const REPYTYPE3:String = "REPYTYPE@@@";
		
		public static const TYPE9_TIME:int=12000;
		public static const TYPE99_TIME:int=30000;
		public static const TYPE999_TIME:int=60000;
		
		
		private static var broadContent_9:Array = ["9朵红玫瑰，表达了一份简单美好的祝愿！",
			"9朵红玫瑰，她脸上洋溢着幸福的笑容！",	
			"9朵红玫瑰，蕴含着一个长久的祝福！",
			"9朵红玫瑰，表达了一份暖暖的关怀！",
			"9朵红玫瑰，愿鲜花带给她每天好心情！"] ;
		private static var broadContent_99:Array = ["99朵漂亮的红玫瑰，表达了对她无数的期盼和爱慕！",
			"99朵漂亮的红玫瑰，表达对她坚定而又执着的爱！",	
			"99朵漂亮的红玫瑰，祝她幸福快乐每一天！",
			"99朵漂亮的红玫瑰，深情地诉说他无尽的爱！",
			"99朵漂亮的红玫瑰，这是最炽热的爱情表达！"] ;
		private static var broadContent_999:Array = ["999朵高贵的红玫瑰，这是天长地久的爱的体现！",
			"999朵高贵的红玫瑰，他们的爱充满了红玫瑰般美丽的回忆！",	
			"999朵高贵的红玫瑰，许下了一份天长地久的美好诺言！",
			"999朵高贵的红玫瑰，愿用一生一世永恒的爱来呵护她！",
			"999朵高贵的红玫瑰，表达了他们至死不渝的爱情！"] ;
		
		
		private static var allArr:Array = [{num:1,label:"签名送花1朵"},{num:9,label:"签名送花9朵"},
			{num:99,label:"签名送花99朵"},{num:999,label:"签名送花999朵"},
			{num:1,label:"匿名送花1朵"},{num:9,label:"匿名送花9朵"},{num:99,label:"匿名送花99朵"},
			{num:999,label:"匿名送花999朵"}];
		public static function sendTypeArr(canSignName:Boolean,num:int=0):Array
		{
			var arr:Array=[];
			var i:int;
			switch(num)
			{
				case 1:
					if(canSignName)
					{
						arr[0] = allArr[0];
						arr[1] = allArr[4];
					}else{
						arr[0] = allArr[4];
					}
					break;
				
				case 9:
					if(canSignName)
					{
						arr[0] = allArr[1];
						arr[1] = allArr[5];
					}else{
						arr[0] = allArr[5];
					}
					break;
				case 99:
					if(canSignName)
					{
						arr[0] = allArr[2];
						arr[1] = allArr[6];
					}else{
						arr[0] = allArr[6];
					}
					break;
				case 999:
					if(canSignName)
					{
						arr[0] = allArr[3];
						arr[1] = allArr[7];
					}else{
						arr[0] = allArr[7];
					}
					break;
				case 0:
					if(canSignName)
					{
						for(i=0;i<allArr.length;i++)
						{
							arr[i] = allArr[i];
						}
					}else{
						var beginId:int = allArr.length/2;
						for(i=0;i<4;i++)
						{
							arr[i] = allArr[4+i];
						}
					}
					
					break;
			}
			
			return arr;
		}
		
		
		public static function loadData():void{
			if(flowersXml.length>0){
				return;
			}
			var flowersXML:XML = CommonLocator.getXML(CommonLocator.FLOWERS);
			for each(var flower:XML in flowersXML.flower){
				flowersXml.push(flower); //flower.@id
			}
		}
		
		private static var flowerURL:String;
		
		//<flower id="12000001" name="1朵玫瑰花" broadcast="none" num="1"/>
		public static var flowersXml:Array = [];
		public static function getTypeByNum(num:int,bigTypes:int=1):int //配置里有多个　99。。。的。用bigTypes区分
		{                                                                  //   
			var typeid:int ;                                                  
			for(var i:int = 0;i<flowersXml.length;i++)
			{
				var xml:XML = flowersXml[i];
				if(int(xml.@num) == num)
				{
					typeid = xml.@id;
					bigTypes--;
					if(bigTypes==0)
						break;
				}
			}
			return typeid;
		}
		
		public static function getNumByType(type:int):int
		{
			var num:int ;
			for(var i:int = 0;i<flowersXml.length;i++)
			{
				var xml:XML = flowersXml[i];
				if(int(xml.@id) == type)
				{
					num = xml.@num;
				}
			}
			return num;
		}
		
		public static function getPlayTimeByType(type:int):int
		{
			var time:int;
			var num:int = getNumByType(type);
			
			if(num == 9)
				time = TYPE9_TIME;
			else if(num==99)
				time = TYPE99_TIME;// 单位  ms  即 20s   
			else if(num == 999)
				time = TYPE999_TIME;
			
			return time;
				
		}
		
		public static function getRandomBroadcast(f_num:int):String  // sender+"送给"+reciever + this.function();
		{
//			if(f_num)
			var idex:int = randomNum(4);
			var str:String="";
			
			switch(f_num)
			{
				case 1:
					
					break;
				case 9:
					str = broadContent_9[idex];
					break;
				case 99:
					str = broadContent_99[idex];
					break;
				case 999:
					str = broadContent_999[idex];
					break;
				default :  break;
			}
			
			return str;
		}
		
		
		public static function randomNum(max:int):int  // 0-max 一个随机int型数。
		{
			var num:int;
			num = Math.floor( Math.random()*(max+1));   // 0=<random <1
			
			return num;
		}
		
		public static function randomNumSpace(min:int,max:int):int  // 两个数之间的随机int型数。
		{
			var num:int;
			num = min + randomNum(max-min);
			return num;
		}
		
		
		//  收到花的信息列表。 有多个人送或一人送多次的时候就会有列表。
		private static var _recieveList:Array=[];
		public static function addRecieveList(infoVO:p_flowers_give_info):void
		{
			_recieveList.push(infoVO);
		}
		public static function popRecieveList():void
		{
			if(_recieveList.length>0)
			{
				_recieveList.pop();
			}
		}
		
		public static function get recieveList():Array
		{
			return _recieveList;
		}
		
		
		// 飘花 广播 列表 。。。
		private static var world_broacastList:Array=[];
		public static function addWorldBroadcast(vo:m_flowers_give_world_broadcast_toc):void
		{
			if(vo && vo.broadcast)
			{
				world_broacastList.push(vo.broadcast)
				
			}
		}
		public static function getFlowerBroadcast():p_flowers_give_broadcast_info
		{
			var broadcast_info:p_flowers_give_broadcast_info;
			if(world_broacastList.length>0)
			{
				broadcast_info = world_broacastList.shift() as p_flowers_give_broadcast_info;
			}else if(faction_broacastList.length>0){
				broadcast_info = faction_broacastList.shift() as p_flowers_give_broadcast_info;  //faction_broacastList.splice(0,1)
			}else if(map_broacastList.length>0){
				var obj:Object = map_broacastList.shift();
				var current_mapId:int = SceneDataManager.mapData.map_id;
				
				if(obj.map_id == current_mapId)
				{
					broadcast_info = obj.vo as p_flowers_give_broadcast_info;
				}else{
					
					removeMapFlowerBroacast();
					broadcast_info = null;
				}
			}else{
				broadcast_info = null;
			}
			
			return broadcast_info;
		}
		
		// 国家的广播。
		private static var faction_broacastList:Array=[];
		public static function addFactionBroadcast(vo:m_flowers_give_faction_broadcast_toc):void
		{
			if(vo && vo.broadcast)
			{
				faction_broacastList.push(vo.broadcast)
			}
		}
		public static function removeFactionFlowerBroacast():void
		{
			while(faction_broacastList.length>0)
			{
				var info:m_flowers_give_faction_broadcast_toc = faction_broacastList.splice(0,1);
				info = null;
			}
		}
		
		
		//当前场景的广播
		private static var map_broacastList:Array=[];
		public static function addMapBroadcast(vo:m_flowers_give_map_broadcast_toc):void
		{
			if(vo && vo.broadcast)
			{
				var obj:Object = {};
				obj.vo = vo.broadcast;
				obj.map_id = SceneDataManager.mapData.map_id;
				
				map_broacastList.push(obj);
				
//				map_broacastList.push(vo.broadcast);
			}
		}
		public static function removeMapFlowerBroacast():void
		{
			while(map_broacastList.length>0)
			{
				var info:Object = map_broacastList.splice(0,1);
				info = null;
			}
		}
		
		
		
		
		
		public function FlowersTypes()
		{
		}
		
	}
}

