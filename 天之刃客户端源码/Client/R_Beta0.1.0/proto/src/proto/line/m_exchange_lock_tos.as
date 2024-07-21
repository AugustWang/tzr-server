package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_lock_tos extends Message
	{
		public var goods:Array = new Array;
		public var silver:int = 0;
		public var gold:int = 0;
		public function m_exchange_lock_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_lock_tos", m_exchange_lock_tos);
		}
		public override function getMethodName():String {
			return 'exchange_lock';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_goods:int = this.goods.length;
			output.writeShort(size_goods);
			var temp_repeated_byte_goods:ByteArray= new ByteArray;
			for(i=0; i<size_goods; i++) {
				temp_repeated_byte_goods.writeInt(this.goods[i]);
			}
			output.writeInt(temp_repeated_byte_goods.length);
			output.writeBytes(temp_repeated_byte_goods);
			output.writeInt(this.silver);
			output.writeInt(this.gold);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_goods:int = input.readShort();
			var length_goods:int = input.readInt();
			var byte_goods:ByteArray = new ByteArray; 
			if (size_goods > 0) {
				input.readBytes(byte_goods, 0, size_goods * 4);
				for(i=0; i<size_goods; i++) {
					var tmp_goods:int = byte_goods.readInt();
					this.goods.push(tmp_goods);
				}
			}
			this.silver = input.readInt();
			this.gold = input.readInt();
		}
	}
}
