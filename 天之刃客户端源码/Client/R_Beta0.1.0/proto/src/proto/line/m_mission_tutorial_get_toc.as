package proto.line {
	import proto.line.p_mission_tutorial_data;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_tutorial_get_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var id:int = 0;
		public var tutorial_data:Array = new Array;
		public function m_mission_tutorial_get_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_tutorial_get_toc", m_mission_tutorial_get_toc);
		}
		public override function getMethodName():String {
			return 'mission_tutorial_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.id);
			var size_tutorial_data:int = this.tutorial_data.length;
			output.writeShort(size_tutorial_data);
			var temp_repeated_byte_tutorial_data:ByteArray= new ByteArray;
			for(i=0; i<size_tutorial_data; i++) {
				var t2_tutorial_data:ByteArray = new ByteArray;
				var tVo_tutorial_data:p_mission_tutorial_data = this.tutorial_data[i] as p_mission_tutorial_data;
				tVo_tutorial_data.writeToDataOutput(t2_tutorial_data);
				var len_tVo_tutorial_data:int = t2_tutorial_data.length;
				temp_repeated_byte_tutorial_data.writeInt(len_tVo_tutorial_data);
				temp_repeated_byte_tutorial_data.writeBytes(t2_tutorial_data);
			}
			output.writeInt(temp_repeated_byte_tutorial_data.length);
			output.writeBytes(temp_repeated_byte_tutorial_data);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.id = input.readInt();
			var size_tutorial_data:int = input.readShort();
			var length_tutorial_data:int = input.readInt();
			if (length_tutorial_data > 0) {
				var byte_tutorial_data:ByteArray = new ByteArray; 
				input.readBytes(byte_tutorial_data, 0, length_tutorial_data);
				for(i=0; i<size_tutorial_data; i++) {
					var tmp_tutorial_data:p_mission_tutorial_data = new p_mission_tutorial_data;
					var tmp_tutorial_data_length:int = byte_tutorial_data.readInt();
					var tmp_tutorial_data_byte:ByteArray = new ByteArray;
					byte_tutorial_data.readBytes(tmp_tutorial_data_byte, 0, tmp_tutorial_data_length);
					tmp_tutorial_data.readFromDataOutput(tmp_tutorial_data_byte);
					this.tutorial_data.push(tmp_tutorial_data);
				}
			}
		}
	}
}
