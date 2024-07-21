package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trading_get_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var goods:Array = new Array;
		public var bill:int = 0;
		public var max_bill:int = 0;
		public var trading_times:int = 0;
		public var award_type:int = 0;
		public function m_trading_get_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trading_get_toc", m_trading_get_toc);
		}
		public override function getMethodName():String {
			return 'trading_get';
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
			output.writeInt(this.bill);
			output.writeInt(this.max_bill);
			output.writeInt(this.trading_times);
			output.writeInt(this.award_type);
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
			this.bill = input.readInt();
			this.max_bill = input.readInt();
			this.trading_times = input.readInt();
			this.award_type = input.readInt();
		}
	}
}
