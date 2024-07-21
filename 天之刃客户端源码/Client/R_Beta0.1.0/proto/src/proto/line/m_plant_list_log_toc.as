package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_list_log_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var logs:Array = new Array;
		public function m_plant_list_log_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_list_log_toc", m_plant_list_log_toc);
		}
		public override function getMethodName():String {
			return 'plant_list_log';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_logs:int = this.logs.length;
			output.writeShort(size_logs);
			var temp_repeated_byte_logs:ByteArray= new ByteArray;
			for(i=0; i<size_logs; i++) {
				if (this.logs != null) {					temp_repeated_byte_logs.writeUTF(this.logs[i].toString());
				} else {
					temp_repeated_byte_logs.writeUTF("");
				}
			}
			output.writeInt(temp_repeated_byte_logs.length);
			output.writeBytes(temp_repeated_byte_logs);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_logs:int = input.readShort();
			var length_logs:int = input.readInt();
			if (size_logs>0) {
				var byte_logs:ByteArray = new ByteArray; 
				input.readBytes(byte_logs, 0, length_logs);
				for(i=0; i<size_logs; i++) {
					var tmp_logs:String = byte_logs.readUTF(); 
					this.logs.push(tmp_logs);
				}
			}
		}
	}
}
