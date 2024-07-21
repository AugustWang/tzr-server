package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_search_toc extends Message
	{
		public var result:Array = new Array;
		public var total_page:int = 0;
		public function m_stall_search_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_search_toc", m_stall_search_toc);
		}
		public override function getMethodName():String {
			return 'stall_search';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_result:int = this.result.length;
			output.writeShort(size_result);
			var temp_repeated_byte_result:ByteArray= new ByteArray;
			for(i=0; i<size_result; i++) {
				var t2_result:ByteArray = new ByteArray;
				var tVo_result:p_stall_search_goods = this.result[i] as p_stall_search_goods;
				tVo_result.writeToDataOutput(t2_result);
				var len_tVo_result:int = t2_result.length;
				temp_repeated_byte_result.writeInt(len_tVo_result);
				temp_repeated_byte_result.writeBytes(t2_result);
			}
			output.writeInt(temp_repeated_byte_result.length);
			output.writeBytes(temp_repeated_byte_result);
			output.writeInt(this.total_page);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_result:int = input.readShort();
			var length_result:int = input.readInt();
			if (length_result > 0) {
				var byte_result:ByteArray = new ByteArray; 
				input.readBytes(byte_result, 0, length_result);
				for(i=0; i<size_result; i++) {
					var tmp_result:p_stall_search_goods = new p_stall_search_goods;
					var tmp_result_length:int = byte_result.readInt();
					var tmp_result_byte:ByteArray = new ByteArray;
					byte_result.readBytes(tmp_result_byte, 0, tmp_result_length);
					tmp_result.readFromDataOutput(tmp_result_byte);
					this.result.push(tmp_result);
				}
			}
			this.total_page = input.readInt();
		}
	}
}
