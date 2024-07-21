package modules.mypackage {
	import flash.utils.Dictionary;
	
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	import proto.common.p_goods;

	/**
	 * 装备常量定义
	 */
	public class ItemConstant {
		private static var CDS:Vector.<int>;
		/**
		 * 道具细分种类
		 */
		public static const KIND_GENERAL:int=1; //杂物
		public static const KIND_MEDICATION:int=2; //药品
		public static const KIND_BOOK:int=3; //书籍
		public static const KIND_MATERIAL:int=4; //材料
		public static const KIND_PACK:int=13; //包裹
		public static const KIND_HIEROGRAM:int=6; //灵符
		public static const KIND_TOOL:int=7; //工具
		public static const KIND_SPECIAL:int=8; //特殊
		public static const KIND_TASK:int=9; //任务
		public static const KIND_GIFT_BAG:int=14; //礼包
		public static const KIND_EQUIP_MOUNT:int=1201; //马
		public static const KIND_BREAT:int=501; //盔甲
		public static const KIND_FASHION:int=1101; //时装
		public static const KIND_PET:int=23; //宠物

		public static const ITEM_KINDS:Array=["", "杂物", "药品", "书籍", "材料", "包裹", "灵符", "工具", "特殊", "任务"];
		public static const ITEM_QUALITY:Array=["", "普通的", "精良的", "优质的", "无暇的", "完美的","绝世的"];

		public static const SEX_NAMES:Array=["", "男", "女"];

		public static const FIVE_ELE:Array=["", "金", "木", "水", "火", "土"];
		public static const PET_EXP_DRUG:Array=[12300108, 12300109, 12300110, 12300111, 12300112, 12300113, 12300114, 12300115, 12300116, 12300117, 12300135]; //背包中宠物经验药typeid
		/**
		 * 装备颜色
		 *
		 */
		public static const COLOR_GRAY:int=1; //白色
		public static const COLOR_GREEN:int=2; //绿色
		public static const COLOR_BLUE:int=3; //蓝色
		public static const COLOR_PURPLE:int=4; //紫色
		public static const COLOR_ORANGE:int=5; //橙色
		public static const COLOR_GOLD:int=6; //金色

		public static const COLOR_NAMES:Array=["", "白色", "绿色", "蓝色", "紫色", "橙色", "金色"];
		public static const COLOR_NAME:Array=["", "白", "绿", "蓝", "紫", "橙", "金"];
		public static const COLOR_VALUES:Array=["#EDE8E1", "#EDE8E1", "#12CC12", "#0d79ff", "#fe00e9", "#ff7e00", "#FFD700"];
		public static const COLOR_VALUES2:Array=[0xEDE8E1, 0xEDE8E1, 0x12CC12, 0x0d79ff, 0xfe00e9, 0xff7e00, 0xFFD700];
		/**
		 * 背包分类(对于不同的分类要做出不同的逻辑处理)
		 */
		public static const TYPE_GENERAL:int=1; //普通
		public static const TYPE_STONE:int=2; //宝石
		public static const TYPE_EQUIP:int=3; //装备

		public static const ITEM_TOOLTIP:String="itemToolTip";
		/**
		 * 装备位置
		 * 、护腕、靴子、项链、戒指、饰品
		 */

		public static const PUT_ARM:int=1; //武器
		public static const PUT_NECKLACE:int=2; //项链
		public static const PUT_FINGER:int=3; //戒子
		public static const PUT_ARMET:int=4; //头盔
		public static const PUT_BREAST:int=5; //护甲
		public static const PUT_CAESTUS:int=6; //腰带
		public static const PUT_HAND:int=7; //护腕
		public static const PUT_SHOES:int=8; //靴子
		public static const PUT_ASSISTANT:int=9; //副手武器
		public static const PUT_ADORN:int=10; //挂饰
		public static const PUT_FASHION:int=11; //时装
		public static const PUT_MOUNT:int=12; //坐骑

		public static const KIND_KNIFE:int=101; //刀
		public static const KIND_FAN:int=102; //扇


		public static const NORMAL:int=0;
		public static const LOCK:int=1;

		public static const WEAPON_KINDS:Array=["", "刀", "弓", "杖", "扇", "特殊"];
		public static const ASSISTANT_KINDS:Array=["", "盾牌\n不可与弓,杖,扇同时装备", "弹药", "特殊"];
		public static const EQUIP_KINDS:Array=["", "同部位类型", "特殊"];

		public static const EFFECT_HP:int=1; //金仓药
		public static const EFFECT_MP:int=2; //内力药
		public static const EFFECT_LIBAO:int=14;
		public static const EFFECT_PET_HP:int=30; //宠物药
		public static const EFFECT_RETURN:int=4; //回程
		public static const EFFECT_ENDURANCE:int=7; //增加耐久度
		public static const EFFECT_EXP:int=6; //经验buffer
		public static const EFFECT_SUPER_HP:int=15; //超级红药
		public static const EFFECT_SUPER_MP:int=17; //超级蓝药
		public static const EFFECT_HCL:int=16; //换车令牌
		public static const EFFECT_YP:int=20; //金砖， 银票
		public static const EFFECT_XISHUIDAN:int=19; //洗髓丹
		public static const EFFECT_YIJINWAN:int=22; //易筋丸
		public static const EFFECT_FAMILY_CMD:int=21; //门派令
		public static const EFFECT_LABA:int=10700002; //喇叭
		public static const EFFECT_TREASURY:int=24; //江湖宝典
		public static const EFFECT_FLOWER:int=26; // 送花用的
		public static const EFFECT_TRANSFORM_MAP:int=8; //传送卷
		public static const EFFECT_ZHUIZONG_LING:int=27; //追踪令
		public static const EFFECT_KING_TOKEN:int=28; // 国王令
		public static const EFFECT_BIAN_SHEN:int=31; //变身符
		public static const EFFECT_EDUCATE_FB_MEMBER:int=32; //师门副本队员道具
		public static const EFFECT_EDUCATE_FB_LEADER:int=33; //师门副本队长道具
		public static const EFFECT_MOUNT_UPGRADE:int=105; //坐骑提速牌
		public static const EFFECT_CALL_PET:int=29; //宠物召唤符
		public static const EFFECT_ADD_DRUNK_BUF:int=110; //增加醉酒buff

		public static const SMALL_MP:String="中型金创药";
		public static const SMALL_HP:String="中型内力药水";
		//没办法  策划不配置，测试要这么提示，所以写死
		public static var EXP_TIP:Dictionary=new Dictionary();
		
		//颜色对应的buff id
		public static var DRUNK_BUF:Dictionary=new Dictionary();

		////////////为了判断玩家不重复使用经验增益///////////////
		/**
		 * 根据武器装备细分类型ID
		 * @param putWhere
		 * @return
		 *
		 */
		public static function getKind(kind:int):int {
			var k:String=kind.toString().substr(1);
			return int(k);
			
		}

		/**
		 * 根据武器装备细分类型名称
		 * @param putWhere
		 * @return
		 *
		 */
		public static function getEquipKindName(type:int, kind:int):String {
			var k:int=getKind(kind);
			if (type == PUT_ARM) {
				return WEAPON_KINDS[k];
			} else if (type == PUT_ASSISTANT) {
				return ASSISTANT_KINDS[k];
			} else if (type == PUT_FASHION) {
				return "时装";
			} else if (type == PUT_MOUNT) {
				return "坐骑";
			} else {
				if (k == 1) {
					return getNameByEquipType(type);
				}
				return EQUIP_KINDS[k];
			}
		}

		private static var inited:Boolean=init();
		public static var pos:Array;

		private static function init():Boolean {
			EXP_TIP["初级经验符"]=1.3;
			EXP_TIP["中级经验符"]=1.6;
			EXP_TIP["高级经验符"]=2;
			pos=[];
			
			pos[0]=PUT_ARMET;
			pos[1]=PUT_NECKLACE;
			pos[2]=PUT_BREAST;
			pos[3]=PUT_ARM;
			pos[4]=PUT_ASSISTANT;
			pos[5]=PUT_SHOES;
			pos[6]=PUT_ADORN;
			pos[7]=PUT_FASHION;
			pos[8]=PUT_HAND;
			pos[9]=PUT_HAND;
			pos[10]=PUT_CAESTUS;
			pos[11]=PUT_FINGER;
			pos[12]=PUT_FINGER;
			pos[13]=PUT_ADORN;
			pos[14]=PUT_MOUNT;

			CDS=new Vector.<int>();
			CDS[0]=500;
			CDS[1]=6000;
			CDS[2]=6000;
			CDS[3]=5000;
			CDS[4]=5000;
			CDS[5]=1000;
			CDS[6]=1000;
			CDS[7]=500;
			CDS[8]=500;
			CDS[9]=500;
			CDS[10]=500;
			CDS[11]=500;
			CDS[12]=500;
			CDS[13]=500;
			CDS[14]=500;
			CDS[15]=6000;
			CDS[16]=500;
			CDS[17]=6000;
			CDS[18]=500;
			CDS[19]=500;
			CDS[20]=500;
			CDS[21]=1000;
			CDS[22]=500;
			CDS[23]=500;
			CDS[24]=0;
			CDS[25]=0;
			CDS[26]=0;
			CDS[27]=0;
			CDS[28]=0;
			CDS[29]=0;
			CDS[30]=3000;
			
			DRUNK_BUF[1] = 10737;
			DRUNK_BUF[2] = 10738;
			DRUNK_BUF[3] = 10739;
			DRUNK_BUF[4] = 10740;
			return true;
		}

		public static function getCDS(effectType:int):int {
			if (effectType >= CDS.length) {
				return 0;
			}
			return CDS[effectType];
		}

		/**
		 * 根据位置获取类型
		 * @param putWhere
		 * @return
		 *
		 */
		public static function getPostionByPutWhere(putWhere:int):Array {
			var temp:Array=[];
			for (var i:int=0; i < pos.length; i++) {
				if (pos[i] == putWhere) {
					temp.push(i);
				}
			}
			return temp;
		}

		/**
		 * 根据类型获取名称
		 * @param putWhere
		 * @return
		 *
		 */
		public static function getNameByEquipType(putWhere:int):String {
			switch (putWhere) {
				case PUT_ARMET:
					return "头盔";
				case PUT_NECKLACE:
					return "项链";
				case PUT_ARM:
					return "武器";
				case PUT_BREAST:
					return "盔甲";
				case PUT_FINGER:
					return "戒指";
				case PUT_HAND:
					return "护腕";
				case PUT_CAESTUS:
					return "腰带";
				case PUT_ADORN:
					return "特殊";
				case PUT_SHOES:
					return "靴子";
			}
			return "";
		}

		/**
		 * 组装客户端需要的VO
		 * @param vo
		 * @return
		 *
		 */
		public static function wrapperItemVO(vo:p_goods):BaseItemVO {
			var baseItemVO:BaseItemVO;
			if (vo == null || vo.id == 0)
				return null;
			switch (vo.type) {
				case TYPE_EQUIP:
					baseItemVO=new EquipVO();
					break;
				case TYPE_GENERAL:
					baseItemVO=new GeneralVO();
					break;
				case TYPE_STONE:
					baseItemVO=new StoneVO();
			}
			baseItemVO.copy(vo);
			return baseItemVO;
		}

		/**
		 * 获取五行相生名称
		 */
		public static function getFiveEleSource(fiveele:int):String {
			switch (fiveele) {
				case 1:
					return "土";
				case 2:
					return "水";
				case 3:
					return "金";
				case 4:
					return "木";
				case 5:
					return "火";
			}
			return "";
		}

		/**
		 * 获取五行相克名称
		 */
		public static function getFiveEleKiller(fiveele:int):String {
			switch (fiveele) {
				case 1:
					return "木";
				case 2:
					return "土";
				case 3:
					return "火";
				case 4:
					return "金";
				case 5:
					return "水";
			}
			return "";
		}
	}
}