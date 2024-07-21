package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_dynamic_toc extends Message
	{
		public var id:int = 0;
		public var dynamic_info:Array = new Array;
		public function m_mission_dynamic_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_dynamic_toc", m_mission_dynamic_toc);
		}
		public override function getMethodName():String {
			return 'mission_dynamic';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			var size_dynamic_info:int = this.dynamic_info.length;
			output.writeShort(size_dynamic_info);
			var temp_repeated_byte_dynamic_info:ByteArray= new ByteArray;
			for(i=0; i<size_dynamic_info; i++) {
				var t2_dynamic_info:ByteArray = new ByteArray;
				var tVo_dynamic_info:p_mission_dynamic = this.dynamic_info[i] as p_mission_dynamic;
				tVo_dynamic_info.writeToDataOutput(t2_dynamic_info);
				var len_tVo_dynamic_info:int = t2_dynamic_info.length;
				temp_repeated_byte_dynamic_info.writeInt(len_tVo_dynamic_info);
				temp_repeated_byte_dynamic_info.writeBytes(t2_dynamic_info);
			}
			output.writeInt(temp_repeated_byte_dynamic_info.length);
			output.writeBytes(temp_repeated_byte_dynamic_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			var size_dynamic_info:int = input.readShort();
			var length_dynamic_info:int = input.readInt();
			if (length_dynamic_info > 0) {
				var byte_dynamic_info:ByteArray = new ByteArray; 
				input.readBytes(byte_dynamic_info, 0, length_dynamic_info);
				for(i=0; i<size_dynamic_info; i++) {
					var tmp_dynamic_info:p_mission_dynamic = new p_mission_dynamic;
					var tmp_dynamic_info_length:int = byte_dynamic_info.readInt();
					var tmp_dynamic_info_byte:ByteArray = new ByteArray;
					byte_dynamic_info.readBytes(tmp_dynamic_info_byte, 0, tmp_dynamic_info_length);
					tmp_dynamic_info.readFromDataOutput(tmp_dynamic_info_byte);
					this.dynamic_info.push(tmp_dynamic_info);
				}
			}
		}
	}
}
