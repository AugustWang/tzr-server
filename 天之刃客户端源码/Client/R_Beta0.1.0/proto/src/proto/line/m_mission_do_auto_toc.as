package proto.line {
	import proto.line.p_mission_auto;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_do_auto_toc extends Message
	{
		public var id:int = 0;
		public var auto_info:p_mission_auto = null;
		public var code:int = 0;
		public var code_data:Array = new Array;
		public function m_mission_do_auto_toc() {
			super();
			this.auto_info = new p_mission_auto;

			flash.net.registerClassAlias("copy.proto.line.m_mission_do_auto_toc", m_mission_do_auto_toc);
		}
		public override function getMethodName():String {
			return 'mission_do_auto';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			var tmp_auto_info:ByteArray = new ByteArray;
			this.auto_info.writeToDataOutput(tmp_auto_info);
			var size_tmp_auto_info:int = tmp_auto_info.length;
			output.writeInt(size_tmp_auto_info);
			output.writeBytes(tmp_auto_info);
			output.writeInt(this.code);
			var size_code_data:int = this.code_data.length;
			output.writeShort(size_code_data);
			var temp_repeated_byte_code_data:ByteArray= new ByteArray;
			for(i=0; i<size_code_data; i++) {
				temp_repeated_byte_code_data.writeInt(this.code_data[i]);
			}
			output.writeInt(temp_repeated_byte_code_data.length);
			output.writeBytes(temp_repeated_byte_code_data);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			var byte_auto_info_size:int = input.readInt();
			if (byte_auto_info_size > 0) {				this.auto_info = new p_mission_auto;
				var byte_auto_info:ByteArray = new ByteArray;
				input.readBytes(byte_auto_info, 0, byte_auto_info_size);
				this.auto_info.readFromDataOutput(byte_auto_info);
			}
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
		}
	}
}
