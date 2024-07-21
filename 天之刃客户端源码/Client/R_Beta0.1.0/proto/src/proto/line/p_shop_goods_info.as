package proto.line {
	import proto.line.p_shop_price;
	import proto.common.p_property_add;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_shop_goods_info extends Message
	{
		public var goods_id:int = 0;
		public var seat_id:int = 0;
		public var packe_num:int = 1;
		public var time:Array = new Array;
		public var role_grade:Array = new Array;
		public var goods_bind:Boolean = false;
		public var goods_modify:String = "";
		public var price:Array = new Array;
		public var type:int = 0;
		public var property:p_property_add = null;
		public var colour:int = 0;
		public var discount_type:int = 0;
		public var shop_id:int = 0;
		public var price_bind:int = 0;
		public function p_shop_goods_info() {
			super();
			this.property = new p_property_add;

			flash.net.registerClassAlias("copy.proto.line.p_shop_goods_info", p_shop_goods_info);
		}
		public override function getMethodName():String {
			return 'shop_goods_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.seat_id);
			output.writeInt(this.packe_num);
			var size_time:int = this.time.length;
			output.writeShort(size_time);
			var temp_repeated_byte_time:ByteArray= new ByteArray;
			for(i=0; i<size_time; i++) {
				temp_repeated_byte_time.writeInt(this.time[i]);
			}
			output.writeInt(temp_repeated_byte_time.length);
			output.writeBytes(temp_repeated_byte_time);
			var size_role_grade:int = this.role_grade.length;
			output.writeShort(size_role_grade);
			var temp_repeated_byte_role_grade:ByteArray= new ByteArray;
			for(i=0; i<size_role_grade; i++) {
				temp_repeated_byte_role_grade.writeInt(this.role_grade[i]);
			}
			output.writeInt(temp_repeated_byte_role_grade.length);
			output.writeBytes(temp_repeated_byte_role_grade);
			output.writeBoolean(this.goods_bind);
			if (this.goods_modify != null) {				output.writeUTF(this.goods_modify.toString());
			} else {
				output.writeUTF("");
			}
			var size_price:int = this.price.length;
			output.writeShort(size_price);
			var temp_repeated_byte_price:ByteArray= new ByteArray;
			for(i=0; i<size_price; i++) {
				var t2_price:ByteArray = new ByteArray;
				var tVo_price:p_shop_price = this.price[i] as p_shop_price;
				tVo_price.writeToDataOutput(t2_price);
				var len_tVo_price:int = t2_price.length;
				temp_repeated_byte_price.writeInt(len_tVo_price);
				temp_repeated_byte_price.writeBytes(t2_price);
			}
			output.writeInt(temp_repeated_byte_price.length);
			output.writeBytes(temp_repeated_byte_price);
			output.writeInt(this.type);
			var tmp_property:ByteArray = new ByteArray;
			this.property.writeToDataOutput(tmp_property);
			var size_tmp_property:int = tmp_property.length;
			output.writeInt(size_tmp_property);
			output.writeBytes(tmp_property);
			output.writeInt(this.colour);
			output.writeInt(this.discount_type);
			output.writeInt(this.shop_id);
			output.writeInt(this.price_bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.seat_id = input.readInt();
			this.packe_num = input.readInt();
			var size_time:int = input.readShort();
			var length_time:int = input.readInt();
			var byte_time:ByteArray = new ByteArray; 
			if (size_time > 0) {
				input.readBytes(byte_time, 0, size_time * 4);
				for(i=0; i<size_time; i++) {
					var tmp_time:int = byte_time.readInt();
					this.time.push(tmp_time);
				}
			}
			var size_role_grade:int = input.readShort();
			var length_role_grade:int = input.readInt();
			var byte_role_grade:ByteArray = new ByteArray; 
			if (size_role_grade > 0) {
				input.readBytes(byte_role_grade, 0, size_role_grade * 4);
				for(i=0; i<size_role_grade; i++) {
					var tmp_role_grade:int = byte_role_grade.readInt();
					this.role_grade.push(tmp_role_grade);
				}
			}
			this.goods_bind = input.readBoolean();
			this.goods_modify = input.readUTF();
			var size_price:int = input.readShort();
			var length_price:int = input.readInt();
			if (length_price > 0) {
				var byte_price:ByteArray = new ByteArray; 
				input.readBytes(byte_price, 0, length_price);
				for(i=0; i<size_price; i++) {
					var tmp_price:p_shop_price = new p_shop_price;
					var tmp_price_length:int = byte_price.readInt();
					var tmp_price_byte:ByteArray = new ByteArray;
					byte_price.readBytes(tmp_price_byte, 0, tmp_price_length);
					tmp_price.readFromDataOutput(tmp_price_byte);
					this.price.push(tmp_price);
				}
			}
			this.type = input.readInt();
			var byte_property_size:int = input.readInt();
			if (byte_property_size > 0) {				this.property = new p_property_add;
				var byte_property:ByteArray = new ByteArray;
				input.readBytes(byte_property, 0, byte_property_size);
				this.property.readFromDataOutput(byte_property);
			}
			this.colour = input.readInt();
			this.discount_type = input.readInt();
			this.shop_id = input.readInt();
			this.price_bind = input.readInt();
		}
	}
}
