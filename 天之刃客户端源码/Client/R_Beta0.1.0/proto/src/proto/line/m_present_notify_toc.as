package proto.line {
	import proto.common.p_present_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_present_notify_toc extends Message
	{
		public var present_list:Array = new Array;
		public function m_present_notify_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_present_notify_toc", m_present_notify_toc);
		}
		public override function getMethodName():String {
			return 'present_notify';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_present_list:int = this.present_list.length;
			output.writeShort(size_present_list);
			var temp_repeated_byte_present_list:ByteArray= new ByteArray;
			for(i=0; i<size_present_list; i++) {
				var t2_present_list:ByteArray = new ByteArray;
				var tVo_present_list:p_present_info = this.present_list[i] as p_present_info;
				tVo_present_list.writeToDataOutput(t2_present_list);
				var len_tVo_present_list:int = t2_present_list.length;
				temp_repeated_byte_present_list.writeInt(len_tVo_present_list);
				temp_repeated_byte_present_list.writeBytes(t2_present_list);
			}
			output.writeInt(temp_repeated_byte_present_list.length);
			output.writeBytes(temp_repeated_byte_present_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_present_list:int = input.readShort();
			var length_present_list:int = input.readInt();
			if (length_present_list > 0) {
				var byte_present_list:ByteArray = new ByteArray; 
				input.readBytes(byte_present_list, 0, length_present_list);
				for(i=0; i<size_present_list; i++) {
					var tmp_present_list:p_present_info = new p_present_info;
					var tmp_present_list_length:int = byte_present_list.readInt();
					var tmp_present_list_byte:ByteArray = new ByteArray;
					byte_present_list.readBytes(tmp_present_list_byte, 0, tmp_present_list_length);
					tmp_present_list.readFromDataOutput(tmp_present_list_byte);
					this.present_list.push(tmp_present_list);
				}
			}
		}
	}
}
