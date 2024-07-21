package proto.line {
	import proto.common.p_trading_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trading_sale_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var role_goods:Array = new Array;
		public var bill:int = 0;
		public function m_trading_sale_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trading_sale_toc", m_trading_sale_toc);
		}
		public override function getMethodName():String {
			return 'trading_sale';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_role_goods:int = this.role_goods.length;
			output.writeShort(size_role_goods);
			var temp_repeated_byte_role_goods:ByteArray= new ByteArray;
			for(i=0; i<size_role_goods; i++) {
				var t2_role_goods:ByteArray = new ByteArray;
				var tVo_role_goods:p_trading_goods = this.role_goods[i] as p_trading_goods;
				tVo_role_goods.writeToDataOutput(t2_role_goods);
				var len_tVo_role_goods:int = t2_role_goods.length;
				temp_repeated_byte_role_goods.writeInt(len_tVo_role_goods);
				temp_repeated_byte_role_goods.writeBytes(t2_role_goods);
			}
			output.writeInt(temp_repeated_byte_role_goods.length);
			output.writeBytes(temp_repeated_byte_role_goods);
			output.writeInt(this.bill);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_role_goods:int = input.readShort();
			var length_role_goods:int = input.readInt();
			if (length_role_goods > 0) {
				var byte_role_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_role_goods, 0, length_role_goods);
				for(i=0; i<size_role_goods; i++) {
					var tmp_role_goods:p_trading_goods = new p_trading_goods;
					var tmp_role_goods_length:int = byte_role_goods.readInt();
					var tmp_role_goods_byte:ByteArray = new ByteArray;
					byte_role_goods.readBytes(tmp_role_goods_byte, 0, tmp_role_goods_length);
					tmp_role_goods.readFromDataOutput(tmp_role_goods_byte);
					this.role_goods.push(tmp_role_goods);
				}
			}
			this.bill = input.readInt();
		}
	}
}
