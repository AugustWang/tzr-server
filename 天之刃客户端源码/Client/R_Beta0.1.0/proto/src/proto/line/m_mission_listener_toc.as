package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_listener_toc extends Message
	{
		public var code:int = 0;
		public var code_data:Array = new Array;
		public var mission_id:int = 0;
		public var listener:p_mission_listener = null;
		public function m_mission_listener_toc() {
			super();
			this.listener = new p_mission_listener;

			flash.net.registerClassAlias("copy.proto.line.m_mission_listener_toc", m_mission_listener_toc);
		}
		public override function getMethodName():String {
			return 'mission_listener';
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
			output.writeInt(this.mission_id);
			var tmp_listener:ByteArray = new ByteArray;
			this.listener.writeToDataOutput(tmp_listener);
			var size_tmp_listener:int = tmp_listener.length;
			output.writeInt(size_tmp_listener);
			output.writeBytes(tmp_listener);
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
			this.mission_id = input.readInt();
			var byte_listener_size:int = input.readInt();
			if (byte_listener_size > 0) {				this.listener = new p_mission_listener;
				var byte_listener:ByteArray = new ByteArray;
				input.readBytes(byte_listener, 0, byte_listener_size);
				this.listener.readFromDataOutput(byte_listener);
			}
		}
	}
}
