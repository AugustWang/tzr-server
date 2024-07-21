package proto.line {
	import proto.line.p_shop_goods_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_search_toc extends Message
	{
		public var search_all_goods:Array = new Array;
		public var npc_id:int = 0;
		public function m_shop_search_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_search_toc", m_shop_search_toc);
		}
		public override function getMethodName():String {
			return 'shop_search';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_search_all_goods:int = this.search_all_goods.length;
			output.writeShort(size_search_all_goods);
			var temp_repeated_byte_search_all_goods:ByteArray= new ByteArray;
			for(i=0; i<size_search_all_goods; i++) {
				var t2_search_all_goods:ByteArray = new ByteArray;
				var tVo_search_all_goods:p_shop_goods_info = this.search_all_goods[i] as p_shop_goods_info;
				tVo_search_all_goods.writeToDataOutput(t2_search_all_goods);
				var len_tVo_search_all_goods:int = t2_search_all_goods.length;
				temp_repeated_byte_search_all_goods.writeInt(len_tVo_search_all_goods);
				temp_repeated_byte_search_all_goods.writeBytes(t2_search_all_goods);
			}
			output.writeInt(temp_repeated_byte_search_all_goods.length);
			output.writeBytes(temp_repeated_byte_search_all_goods);
			output.writeInt(this.npc_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_search_all_goods:int = input.readShort();
			var length_search_all_goods:int = input.readInt();
			if (length_search_all_goods > 0) {
				var byte_search_all_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_search_all_goods, 0, length_search_all_goods);
				for(i=0; i<size_search_all_goods; i++) {
					var tmp_search_all_goods:p_shop_goods_info = new p_shop_goods_info;
					var tmp_search_all_goods_length:int = byte_search_all_goods.readInt();
					var tmp_search_all_goods_byte:ByteArray = new ByteArray;
					byte_search_all_goods.readBytes(tmp_search_all_goods_byte, 0, tmp_search_all_goods_length);
					tmp_search_all_goods.readFromDataOutput(tmp_search_all_goods_byte);
					this.search_all_goods.push(tmp_search_all_goods);
				}
			}
			this.npc_id = input.readInt();
		}
	}
}
