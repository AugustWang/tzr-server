package modules.finery {
	import modules.mypackage.ItemConstant;

	public class StoveConstant {
		public static const RECAST_BTN_CLICK:String = "RECAST_BTN_CLICK";
		public static const PUNCH_BTN_CLICK:String="PUNCH_BTN_CLICK";
		public static const INSERT_BTN_CLICK:String="INSERT_BTN_CLICK";
		public static const DISASSEMBLY_BTN_CLICK:String="DISASSEMBLY_BTN_CLICK";
		public static const BIND_BTN_CLICK:String="BING_BTN_CLICK";
		public static const STRENGTH_BTN_CLICK:String="STRENGTH_BTN_CLICK";
		public static const COMPOSE_BTN_CLICK:String="COMPOSE_BTN_CLICK";
		public static const REFINE_BTN_CLICK:String="REFINE_BTN_CLICK";
		public static const EXALT_BTN_CLICK:String="EXALT_BTN_CLICK";
		public static const EXALT_NEXT:String="EXALT_NEXT";
		public static const UPGRADE_NEXT:String="UPGRADE_NEXT";
		public static const UPGRADE_BTN_CLICK:String="UPGRADE_BTN_CLICK";
		public static const BOX_RELOAD:String="BOX_RELOAD";
		public static const BOX_GET_INFO:String="BOX_GET_INFO";
		public static const BOX_RESTORE:String="BOX_RESTORE";
		public static const BOX_RESTORE_TO_PACK:String="BOX_RESTORE_TO_PACK";
		public static const BOX_QUERY:String="BOX_QUERY";
		public static const BOX_GET_TO_PACK:String="BOX_GET_TO_PACK";
		public static const BOX_ITEM_DOULE_CLICK:String="BOX_ITEM_DOULE_CLICK";
		public static const BOX_MERGE_CLICK:String="BOX_MERGE_CLICK";
		public static const BOX_ALL_GET_CLICK:String="BOX_ALL_GET_CLICK";
		public static const BOX_CLASS_CLICK:String="BOX_CLASS_CLICK";

		public static const OP_TYPE_PUNCH:int=100000;
		public static const OP_TYPE_INSERT:int=200000;
		public static const OP_TYPE_DISASSEMBLY:int=300000;
		public static const OP_TYPE_STRENGTH:int=400000;
		public static const OP_TYPE_COMPOSE:int=500000;
		public static const OP_TYPE_REFINE:int=600000;
		public static const OP_TYPE_BIND:int=700000;
		public static const OP_TYPE_BIND_UP:int=800000;
		public static const OP_TYPE_EXALT:int=900000;
		public static const OP_TYPE_UPGRADE:int=110000;
		public static const OP_TYPE_RECAST:int=120000;

		public static const SUB_BIND_BIND:int=1;
		public static const SUB_BIND_REBIND:int=2;
		public static const SUB_BIND_UP:int=3;

		public static const SUB_EXALT_NEXT:int=1;
		public static const SUB_EXALT_UP:int=2;

		public static const SUB_UPGRADE_NEXT:int=1;
		public static const SUB_UPGRADE:int=2;

		public static const BOX_OP_TYPE_INFO:int=100000;
		public static const BOX_OP_TYPE_ISOPEN:int=100001;
		public static const BOX_OP_TYPE_RELOAD:int=200000;
		public static const BOX_OP_TYPE_RESTORE:int=300000;
		public static const BOX_OP_TYPE_QUERY:int=400000;
		public static const BOX_OP_TYPE_GET:int=500000;
		public static const BOX_OP_TYPE_RESTORE_TO_PACK:int=200001;
		public static const BOX_OP_TYPE_GET_TO_PACK:int=800000;
		public static const BOX_OP_TYPE_MERGE:int=900000;

		public static const GOODS_TYPE_MATERIAL:int=1;
		public static const GOODS_TYPE_STONE:int=2;
		public static const GOODS_TYPE_EQUIP:int=3;

		public static const FIRING_TYPE_TARGET:int=1;
		public static const FIRING_TYPE_MATERIAL:int=2;

		public static var SHOP_ID:Array=[10600001, 10600002, 10600003, 10600007, 10600008, 10600009, 10600013, 10401001,
			10401002, 10401003, 23100001, 10410001, 10410002, 10410003, 10410004, 10410005, 10600102,10600103,10600104, 10600105, 10600106,
			10600107, 10600108, 10600109, 10600110, 10600111, 10600112,10404001,10404002,10404003,10410006,10410007,10410008];

		public static var materialPCT:Array=[[-100, 0, 30], [-1, 1, 20], [0, 2, 3], [1, 3, 0.5], [2, 100, 0]];
		public static var equipPCT_0_100:Array=[[-1, 100], [-100, 0, 15], [-1, 1, 5], [0, 2, 1], [1, 3, 0.2], [2, 100, 0]];
		public static var equipPCT_f1:Array=[[-2, 0], [-100, 0, 10], [-1, 1, 3], [0, 2, 0.8], [1, 3, 0.1], [2, 100, 0]];
		public static var equipPCT_f2f3:Array=[[-4, -1], [-100, 0, 5], [-1, 1, 2], [0, 2, 0.5], [1, 3, 0.08], [2, 100, 0]];
		public static var equipPCT_f4:Array=[[-100, -3], [-100, 0, 2], [-1, 1, 1], [0, 2, 0.3], [1, 3, 0.05], [2, 100, 0]];
		public static var equipPCT:Array=[equipPCT_0_100, equipPCT_f1, equipPCT_f2f3, equipPCT_f4];
		
		public static var upgradeSymbols:Array=[
			{name:"20级装备符",level:40,id:10600102},
			{name:"30级装备符",level:40,id:10600103},
			{name:"40级装备符",level:40,id:10600104},
			{name:"50级装备符",level:50,id:10600105},
			{name:"60级装备符",level:60,id:10600106},
			{name:"70级装备符",level:70,id:10600107},
			{name:"80级装备符",level:80,id:10600108},
			{name:"90级装备符",level:90,id:10600109},
			{name:"100级装备符",level:100,id:10600110}];
		//{name:"110级装备符",level:110,id:10600111}
		//{name:"120级装备符",level:120,id:10600112}

		public static const MAX_PUNCH_NUMBER:int=6; //装备最大开孔数
		public static const MAX_REINFORCE_LEVEL:int=6; //强化最高级别
		public static const MAX_REINFORCE_STAR:int=6; //强化最高星级

		public static var boxIsOpen:Boolean=false;
		public static var boxIsFree:Boolean=false;

		//特殊装备列表，即炼制不显示
		public static var specialEquipArr:Array=[30101102, 30101202, 30101302, 30101402];
		
		//开孔成功概率
		public static var punchRate:Array = ["100%","100%","50%","50%","30%","30%"];
		
		public static const EQUIP_COLORS:Array = [{label:"全部",value:-1},{label:"绿色",value:ItemConstant.COLOR_GREEN},{label:"蓝色",value:ItemConstant.COLOR_BLUE},{label:"紫色",value:ItemConstant.COLOR_PURPLE},{label:"橙色",value:ItemConstant.COLOR_ORANGE},{label:"金色",value:ItemConstant.COLOR_GOLD}];
		public static const EQUIP_TYPES:Array = [{label:"全部",value:-1},{label:"武器",value:ItemConstant.PUT_ARM},{label:"护甲",value:ItemConstant.PUT_BREAST},{label:"项链",value:ItemConstant.PUT_NECKLACE},{label:"护腕",value:ItemConstant.PUT_HAND},{label:"戒子",value:ItemConstant.PUT_FINGER},{label:"头盔",value:ItemConstant.PUT_ARMET},{label:"靴子",value:ItemConstant.PUT_SHOES},{label:"腰带",value:ItemConstant.PUT_CAESTUS}];
	
		public static const ADD_PROPERTIES:Object = {
			1:[3,6,9,12,16,20,25],
			2:[2,5,8,12,16,20,25],
			3:[2,5,8,12,16,20,25],
			4:[2,5,8,12,16,20,25],
			5:[2,5,8,12,16,20,25],
			6:[2,5,8,12,16,20,25],
			7:[50,100,150,250,400,600,850],
			8:[10,20,30,50,80,120,160],
			9:[2,5,8,12,16,20,25],
			10:[1,2,3,4,5,6,8],
			11:[10,20,30,50,70,100,130],
			12:[2,4,6,8,10,12,15]
		};
	}
}