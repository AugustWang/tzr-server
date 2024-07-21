package proto.line {
	import proto.line.p_mission_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_list_toc extends Message
	{
		public var code:int = 0;
		public var code_data:Array = new Array;
		public var list:Array = new Array;
		public function m_mission_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_list_toc", m_mission_list_toc);
		}
		public override function getMethodName():String {
			return 'mission_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.code);
			var size_code_data:int = this.code_data.length;
			output.writeShort(size_code_data);
			var temp_repeated_byte_code_data:ByteArray= new ByteArray;
			for(i=0; i<size_code_data; i++) {
				temp_repeated_byte_code_data.writeInt(this.code_data[i]);
			}
			output.writeInt(temp_repeated_byte_code_data.length);
			output.writeBytes(temp_repeated_byte_code_data);
			var size_list:int = this.list.length;
			output.writeShort(size_list);
			var temp_repeated_byte_list:ByteArray= new ByteArray;
			for(i=0; i<size_list; i++) {
				var t2_list:ByteArray = new ByteArray;
				var tVo_list:p_mission_info = this.list[i] as p_mission_info;
				tVo_list.writeToDataOutput(t2_list);
				var len_tVo_list:int = t2_list.length;
				temp_repeated_byte_list.writeInt(len_tVo_list);
				temp_repeated_byte_list.writeBytes(t2_list);
			}
			output.writeInt(temp_repeated_byte_list.length);
			output.writeBytes(temp_repeated_byte_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.code = input.readInt();
			var size_code_data:int = input.readShort();
			var length_code_data:int = input.readInt();
			var byte_code_data:ByteArray = new ByteArray; 
			if (size_code_data > 0) {
				input.readBytes(byte_code_data, 0, size_code_data * 4);
				for(i=0; i<size_code_data; i++) {
					var tmp_code_data:int = byte_code_data.readInt();
					this.code_data.push(tmp_code_data);
				}
			}
			var size_list:int = input.readShort();
			var length_list:int = input.readInt();
			if (length_list > 0) {
				var byte_list:ByteArray = new ByteArray; 
				input.readBytes(byte_list, 0, length_list);
				for(i=0; i<size_list; i++) {
					var tmp_list:p_mission_info = new p_mission_info;
					var tmp_list_length:int = byte_list.readInt();
					var tmp_list_byte:ByteArray = new ByteArray;
					byte_list.readBytes(tmp_list_byte, 0, tmp_list_length);
					tmp_list.readFromDataOutput(tmp_list_byte);
					this.list.push(tmp_list);
				}
			}
		}
	}
}
