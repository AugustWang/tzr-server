package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_cancel_auto_toc extends Message
	{
		public var id:int = 0;
		public var code:int = 0;
		public var code_data:Array = new Array;
		public function m_mission_cancel_auto_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_cancel_auto_toc", m_mission_cancel_auto_toc);
		}
		public override function getMethodName():String {
			return 'mission_cancel_auto';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
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
