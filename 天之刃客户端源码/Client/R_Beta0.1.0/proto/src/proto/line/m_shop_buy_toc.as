package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_buy_toc extends Message
	{
		public var succ:Boolean = false;
		public var reason:String = "";
		public var goods:Array = new Array;
		public var property:Array = new Array;
		public var error_code:int = 0;
		public function m_shop_buy_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_buy_toc", m_shop_buy_toc);
		}
		public override function getMethodName():String {
			return 'shop_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_goods:int = this.goods.length;
			output.writeShort(size_goods);
			var temp_repeated_byte_goods:ByteArray= new ByteArray;
			for(i=0; i<size_goods; i++) {
				var t2_goods:ByteArray = new ByteArray;
				var tVo_goods:p_goods = this.goods[i] as p_goods;
				tVo_goods.writeToDataOutput(t2_goods);
				var len_tVo_goods:int = t2_goods.length;
				temp_repeated_byte_goods.writeInt(len_tVo_goods);
				temp_repeated_byte_goods.writeBytes(t2_goods);
			}
			output.writeInt(temp_repeated_byte_goods.length);
			output.writeBytes(temp_repeated_byte_goods);
			var size_property:int = this.property.length;
			output.writeShort(size_property);
			var temp_repeated_byte_property:ByteArray= new ByteArray;
			for(i=0; i<size_property; i++) {
				temp_repeated_byte_property.writeInt(this.property[i]);
			}
			output.writeInt(temp_repeated_byte_property.length);
			output.writeBytes(temp_repeated_byte_property);
			output.writeInt(this.error_code);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_goods:int = input.readShort();
			var length_goods:int = input.readInt();
			if (length_goods > 0) {
				var byte_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_goods, 0, length_goods);
				for(i=0; i<size_goods; i++) {
					var tmp_goods:p_goods = new p_goods;
					var tmp_goods_length:int = byte_goods.readInt();
					var tmp_goods_byte:ByteArray = new ByteArray;
					byte_goods.readBytes(tmp_goods_byte, 0, tmp_goods_length);
					tmp_goods.readFromDataOutput(tmp_goods_byte);
					this.goods.push(tmp_goods);
				}
			}
			var size_property:int = input.readShort();
			var length_property:int = input.readInt();
			var byte_property:ByteArray = new ByteArray; 
			if (size_property > 0) {
				input.readBytes(byte_property, 0, size_property * 4);
				for(i=0; i<size_property; i++) {
					var tmp_property:int = byte_property.readInt();
					this.property.push(tmp_property);
				}
			}
			this.error_code = input.readInt();
		}
	}
}
