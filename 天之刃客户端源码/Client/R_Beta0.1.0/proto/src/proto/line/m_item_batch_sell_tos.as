package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_batch_sell_tos extends Message
	{
		public var id_list:Array = new Array;
		public function m_item_batch_sell_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_batch_sell_tos", m_item_batch_sell_tos);
		}
		public override function getMethodName():String {
			return 'item_batch_sell';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_id_list:int = this.id_list.length;
			output.writeShort(size_id_list);
			var temp_repeated_byte_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_id_list; i++) {
				temp_repeated_byte_id_list.writeInt(this.id_list[i]);
			}
			output.writeInt(temp_repeated_byte_id_list.length);
			output.writeBytes(temp_repeated_byte_id_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_id_list:int = input.readShort();
			var length_id_list:int = input.readInt();
			var byte_id_list:ByteArray = new ByteArray; 
			if (size_id_list > 0) {
				input.readBytes(byte_id_list, 0, size_id_list * 4);
				for(i=0; i<size_id_list; i++) {
					var tmp_id_list:int = byte_id_list.readInt();
					this.id_list.push(tmp_id_list);
				}
			}
		}
	}
}
