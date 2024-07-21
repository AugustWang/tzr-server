package proto.line {
	import proto.common.p_fmldepot_log;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_list_log_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var log_type:int = 0;
		public var log_count:int = 0;
		public var page_num:int = 1;
		public var logs:Array = new Array;
		public function m_fmldepot_list_log_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_list_log_toc", m_fmldepot_list_log_toc);
		}
		public override function getMethodName():String {
			return 'fmldepot_list_log';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.log_type);
			output.writeInt(this.log_count);
			output.writeInt(this.page_num);
			var size_logs:int = this.logs.length;
			output.writeShort(size_logs);
			var temp_repeated_byte_logs:ByteArray= new ByteArray;
			for(i=0; i<size_logs; i++) {
				var t2_logs:ByteArray = new ByteArray;
				var tVo_logs:p_fmldepot_log = this.logs[i] as p_fmldepot_log;
				tVo_logs.writeToDataOutput(t2_logs);
				var len_tVo_logs:int = t2_logs.length;
				temp_repeated_byte_logs.writeInt(len_tVo_logs);
				temp_repeated_byte_logs.writeBytes(t2_logs);
			}
			output.writeInt(temp_repeated_byte_logs.length);
			output.writeBytes(temp_repeated_byte_logs);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.log_type = input.readInt();
			this.log_count = input.readInt();
			this.page_num = input.readInt();
			var size_logs:int = input.readShort();
			var length_logs:int = input.readInt();
			if (length_logs > 0) {
				var byte_logs:ByteArray = new ByteArray; 
				input.readBytes(byte_logs, 0, length_logs);
				for(i=0; i<size_logs; i++) {
					var tmp_logs:p_fmldepot_log = new p_fmldepot_log;
					var tmp_logs_length:int = byte_logs.readInt();
					var tmp_logs_byte:ByteArray = new ByteArray;
					byte_logs.readBytes(tmp_logs_byte, 0, tmp_logs_length);
					tmp_logs.readFromDataOutput(tmp_logs_byte);
					this.logs.push(tmp_logs);
				}
			}
		}
	}
}
