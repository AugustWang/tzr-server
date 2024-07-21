package modules.shop {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.utils.DateFormatUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import modules.deal.DealConstant;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.EquipVO;
	import modules.vip.VipModule;
	
	import proto.common.p_present_info;
	import proto.common.p_property_add;
	import proto.line.p_shop_currency;
	import proto.line.p_shop_goods_info;
	import proto.line.p_shop_price;

	/**
	 *商品的详细信息
	 *
	 */
	public class ShopItem extends EventDispatcher{
		
		public static const NUM_CHANGED:String = "numChanged";
		public static const ALL:int = 1;
		public static const BIND:int = 2;
		public static const NO_BIND:int = 3;
		
		private var _data:p_shop_goods_info;
		private var _shopId:int;
		private var _npcId:int;
		private var _id:int;
		private var _name:String;
		private var _colour:int;
		private var _colourStr:String;
		private var _discount_type:int;
		private var _bind:Boolean;
		private var _modify:String;
		private var _price_type:int;
		public var price_bind:int;
		private var _price:int;
		private var _priceStr:String;
		private var _money:int;
		private var _role_min_level:int;
		private var _role_max_level:int;
		private var _seat_id:int;
		private var _type:int;
		private var _url:String;
		private var _property:p_property_add;
		private var _config:Object;
		private var _desc:String;
		private var _sell_time:String;
		private var _num:int;
		private var _maxico:String;

		public function ShopItem() {
		}

		public function set data(v:Object):void {
			var item:p_shop_goods_info=v as p_shop_goods_info;
			this._data=item;
			this._config=ItemLocator.getInstance().getItem(item.type, item.goods_id);
			this._id=item.goods_id;
			this._name=_config.name;
			this._colour=item.colour;
			this.price_bind = item.price_bind;
			this._colourStr=_colourStr=ItemConstant.COLOR_VALUES[item.colour];
			this._discount_type=item.discount_type;
			this._bind=item.goods_bind;
			this._modify=item.goods_modify;
			this._seat_id=item.seat_id;
			this._type=item.type;
			this._url=_config.path;
			this.formatPrice(item.price);
			this._property=item.property;
			this._desc=_config.desc;
			this.formatTime(item.time);
			this._role_min_level=item.role_grade[0] as int;
			this._role_max_level=item.role_grade[1] as int;
			this._num=item.packe_num;
			this._shopId=item.shop_id;
			this._maxico=_config.maxico;
		}

		private function formatTime(time:Array):void {
			if (!time) {
				this._sell_time="";
			} else if (time[0] == 0 && time[1] == 0) {
				this._sell_time="永久";
			} else if (time[0] == 0 && time[1] > 0) {
				this._sell_time=int(time[1] / 86400).toString() + "天";
			} else {
				var begin_date:Date=new Date(Number(time[0]) * 1000);
				var end_date:Date=new Date(Number(time[1]) * 1000);
				this._sell_time=DateFormatUtil.getSubDate(begin_date, end_date).toString();
			}
		}

		private function formatPrice(priceArr:Array):void {
			if (priceArr.length > 0) {
				var price:p_shop_price=priceArr[0] as p_shop_price;
				if (price.currency.length > 0) {
					var currency:p_shop_currency=price.currency[0] as p_shop_currency;
					if (currency.id == 1) {
						this._price=currency.amount;
						this._price_type=1;
						this._priceStr=DealConstant.silverToOtherString(currency.amount);
					} else if (currency.id == 2) {
						this._price=currency.amount;
						this._price_type=2;
						this._priceStr=currency.amount.toString();// + ShopConstant.getMoneyType(2);
					}
				}
			}
		}
		
		public function set id(tmp_id:int):void {
			_id=tmp_id;
		}

		public function get id():int {
			return _id;
		}

		public function set shopId(tmp_shopId:int):void {
			_shopId=tmp_shopId;
		}

		public function get shopId():int {
			return _shopId;
		}

		public function set seat(tmpSeat:int):void {
			this._seat_id=tmpSeat;
		}

		public function get seat():int {
			return _seat_id;
		}

		public function get name():String {
			return _name;
		}

		public function get price():String {
			return _priceStr;
		}

		public function get priceVip():String {
			var vipDiscount:int = VipModule.getInstance().getShopDiscount(this.vipLevel);
			if (this._price_type == 1) {
				return DealConstant.silverToOtherString(_price * vipDiscount / 100);
			} else {
				return Math.ceil(_price * vipDiscount / 100).toString();// + ShopConstant.getMoneyType(_price_type);
			}
		}
	
		public function get discPrice():String{
			if (this._discount_type != 0 || this._discount_type != 1){
				if (this._price_type == 1) {
					return DealConstant.silverToOtherString(_discount_type);
				} else {
					return Math.ceil(_discount_type).toString();// + ShopConstant.getMoneyType(_price_type);
				}
			}else{
				return "";
			}
		}

		public function get priceType():int {
			return _price_type;
		}

		public function get money():int {
			return _price;
		}

		public function set url(tmpURL:String):void {
			this._url=tmpURL;
		}

		
		public function get url():String {
			return _url;
		}

		public function set maxico(tmpURL:String):void {
			this._maxico=tmpURL;
		}
		
		
		public function get maxico():String {
			return _maxico;
		}		
		
		public function get discountType():int {
			return _discount_type;
		}

		public function get vipLevel():int {
			var level:int =  VipModule.getInstance().getRoleVipLevel();
			if(level == 0){
				return 1;
			}else{
				return level;
			}
		}

		public function get colour():String {
			return _colourStr
		}

		public function get modify():String {
			return _modify;
		}

		public function get putWhere():int {
			return _config.putWhere;
		}

		public function get kind():int {
			return _config.kind;
		}

		public function get typeName():String {
			if (this._type == ItemConstant.TYPE_EQUIP) {
				return ItemConstant.getEquipKindName(_config.putWhere, _config.kind);
			} else {
				return "不是装备";
			}
		}

		public function get type():int {
			return this._type;
		}

		public function get property():p_property_add {
			return this._property;
		}

		public function get bind():Boolean {
			return this._bind;
		}

		public function get desc():String {
			return this._desc;
		}

		public function get sellTime():String {
			return this._sell_time;
		}

		public function set npcId(_npc_id:int):void {
			if (!_npc_id) {
				this._npcId=0;
			} else {
				this._npcId=_npc_id;
			}
		}

		public function get npcId():int {
			return this._npcId;
		}

		public function get isCanBuy():Boolean {
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			return !(level > this._role_max_level || level < this._role_min_level);
		}
		
		public function set num(tmpNum:int):void{
			this._num = tmpNum;
			dispatchEvent(new Event(NUM_CHANGED));
		}
		
		public function get num():int{
			return this._num;
		}
		
		public function get preViewPath():String{
			if(this._config.preview == ""){
				return "";
			}else{
				return GameConfig.ROOT_URL +'com/assets/fashionImg/'+ this._config.preview + ".png";
			}
		}

		public function clone():ShopItem {
			var item:ShopItem=new ShopItem();
			item.data=this._data;
			return item;
		}

		public function calcMoney(num:int):String {
			if (this._discount_type != 0 && this._discount_type != 1){
				if (this._price_type == 1) {
					return DealConstant.silverToOtherString((_discount_type)*num);
				} else {
					return Math.ceil(( _discount_type)*num).toString();// + ShopConstant.getMoneyType(_price_type);
				}
			}else{
				var pt:String="";
				var roleVipLevel:int = VipModule.getInstance().getRoleVipLevel();
				var vipDiscount:int = VipModule.getInstance().getShopDiscount(roleVipLevel);
				if (this._price_type == 1) {
					if (this._discount_type == 1 && vipDiscount != 0) {
						pt=DealConstant.silverToOtherString(Math.ceil(_price * vipLevel / 100 * num));
					} else {
						pt=DealConstant.silverToOtherString(Math.ceil(_price * num));
					}
				} else if (this._price_type == 2) {
					if (this._discount_type == 1 && vipDiscount != 0) {
						pt=Math.ceil(_price * vipDiscount / 100 * num).toString();// + ShopConstant.getMoneyType(2);
					} else {
						pt=Math.ceil(_price * num).toString();// + ShopConstant.getMoneyType(2);
					}
				}
				return pt;
			}
		}

	}
}