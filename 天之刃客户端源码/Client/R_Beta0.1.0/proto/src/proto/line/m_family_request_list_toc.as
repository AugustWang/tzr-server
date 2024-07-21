package proto.line {
	import proto.common.p_family_request;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_request_list_toc extends Message
	{
		public var request_list:Array = new Array;
		public function m_family_request_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_request_list_toc", m_family_request_list_toc);
		}
		public override function getMethodName():String {
			return 'family_request_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_request_list:int = this.request_list.length;
			output.writeShort(size_request_list);
			var temp_repeated_byte_request_list:ByteArray= new ByteArray;
			for(i=0; i<size_request_list; i++) {
				var t2_request_list:ByteArray = new ByteArray;
				var tVo_request_list:p_family_request = this.request_list[i] as p_family_request;
				tVo_request_list.writeToDataOutput(t2_request_list);
				var len_tVo_request_list:int = t2_request_list.length;
				temp_repeated_byte_request_list.writeInt(len_tVo_request_list);
				temp_repeated_byte_request_list.writeBytes(t2_request_list);
			}
			output.writeInt(temp_repeated_byte_request_list.length);
			output.writeBytes(temp_repeated_byte_request_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_request_list:int = input.readShort();
			var length_request_list:int = input.readInt();
			if (length_request_list > 0) {
				var byte_request_list:ByteArray = new ByteArray; 
				input.readBytes(byte_request_list, 0, length_request_list);
				for(i=0; i<size_request_list; i++) {
					var tmp_request_list:p_family_request = new p_family_request;
					var tmp_request_list_length:int = byte_request_list.readInt();
					var tmp_request_list_byte:ByteArray = new ByteArray;
					byte_request_list.readBytes(tmp_request_list_byte, 0, tmp_request_list_length);
					tmp_request_list.readFromDataOutput(tmp_request_list_byte);
					this.request_list.push(tmp_request_list);
				}
			}
		}
	}
}
