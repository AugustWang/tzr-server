package modules.mypackage.vo {
	import modules.system.SystemConfig;
	
	import proto.common.p_goods;

	/**
	 * 物品基类vo
	 */
	public class BaseItemVO {
		public static const NORMAL:int=2; // 常规
		public static const UN_STARTUP:int=1; //未启用
		public static const STARTUP:int=0; //未启用
		public static const PASS_DATE:int=3; //过期

		public var oid:int; //数据库唯一ID
		public var roleId:int; //玩家ID
		public var name:String; //物品名称
		public var position:int; //在背包中的位置
		private var _typeId:int; //物品类型ID,对应XML的 
		public var desc:String; //物品描述
		public var path:String; // 图片路径		
		public var bind:Boolean=false; //是否绑定
		public var color:int=0; // 	道具珍稀度（颜色）
		public var num:int=0; //当前数量
		public var startTime:int; //启用时间
		public var timeoutData:int; //过期时间
		public var sellType:int; //售卖货币种类，0不可卖
		public var sellPrice:int; //当前价格
		public var bagid:int; //第几个背包
		public var unit_price:int; // 摆摊出售的　单价　货币都是银子，元宝不给交易！
		public var price_type:int; // 价格类型：1、银两，2、元宝
		public var stall_pos:int; //摊位上的位置
		public var kind:int; //细分种类
		public var state:int; //物品当前状态
		public var use_bind:int; // 绑定值
		public var show_bind:Boolean=false;
		public var level:int; //物品等级
		public var quality:int; //物品品质
		public var type:int; //专门为宝石用的
		public var preview:String; //预览内容
		public var maxico:String;	//大图标

		public function BaseItemVO() {
		}

		public function set typeId(value:int):void {
			_typeId=value;
		}

		public function get typeId():int {
			return this._typeId;
		}

		public function copy(vo:p_goods):void {
			this.oid=vo.id;
			this.roleId=vo.roleid;
			this.position=vo.bagposition;
			this.bind=vo.bind;
			this.num=vo.current_num;
			this.sellType=vo.sell_type;
			this.sellPrice=vo.sell_price;
			this.bagid=vo.bagid;
			this.typeId=vo.typeid;
			this.state=vo.state;
			this.use_bind=vo.use_bind;
			this.startTime=vo.start_time;
			this.timeoutData=vo.end_time;
			this.level=vo.level;
			this.quality=vo.quality;
			if (vo.typeid == 12300135) {
				this.desc=this.desc + (vo.level * Math.pow(10, 9) + vo.quality) + "点";
			}
		}

		/**
		 * 比较两个对象是否可以合并
		 * @param item
		 * @return
		 *
		 */
		public function toCompare(item:BaseItemVO):Boolean {
			return typeId == item.typeId && bind == item.bind && timeoutData == item.timeoutData;
		}

		/**
		 * 获取道具当前过期状态
		 */
		public function getItemStatus():int {
			if (startTime != 0 && timeoutData != 0) {
				if (SystemConfig.serverTime <= startTime) {
					return UN_STARTUP;
				} else if (SystemConfig.serverTime >= timeoutData) {
					return PASS_DATE;
				}
				return STARTUP;
			} else if (startTime == 0 && timeoutData != 0) {
				if (SystemConfig.serverTime >= timeoutData) {
					return PASS_DATE;
				} else {
					return STARTUP;
				}
			} else if (startTime != 0 && timeoutData == 0) {
				if (SystemConfig.serverTime <= startTime) {
					return UN_STARTUP;
				} else {
					return STARTUP;
				}
			}
			return NORMAL;
//				
//			return NORMAL;


		}
	}
}