package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_search_tos extends Message
	{
		public var search_goods_id:Array = new Array;
		public var npc_id:int = 0;
		public function m_shop_search_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_search_tos", m_shop_search_tos);
		}
		public override function getMethodName():String {
			return 'shop_search';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_search_goods_id:int = this.search_goods_id.length;
			output.writeShort(size_search_goods_id);
			var temp_repeated_byte_search_goods_id:ByteArray= new ByteArray;
			for(i=0; i<size_search_goods_id; i++) {
				temp_repeated_byte_search_goods_id.writeInt(this.search_goods_id[i]);
			}
			output.writeInt(temp_repeated_byte_search_goods_id.length);
			output.writeBytes(temp_repeated_byte_search_goods_id);
			output.writeInt(this.npc_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_search_goods_id:int = input.readShort();
			var length_search_goods_id:int = input.readInt();
			var byte_search_goods_id:ByteArray = new ByteArray; 
			if (size_search_goods_id > 0) {
				input.readBytes(byte_search_goods_id, 0, size_search_goods_id * 4);
				for(i=0; i<size_search_goods_id; i++) {
					var tmp_search_goods_id:int = byte_search_goods_id.readInt();
					this.search_goods_id.push(tmp_search_goods_id);
				}
			}
			this.npc_id = input.readInt();
		}
	}
}
