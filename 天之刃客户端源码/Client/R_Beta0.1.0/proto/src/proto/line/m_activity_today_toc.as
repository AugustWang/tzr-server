package proto.line {
	import proto.common.p_activity_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_today_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var activity_list:Array = new Array;
		public function m_activity_today_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_today_toc", m_activity_today_toc);
		}
		public override function getMethodName():String {
			return 'activity_today';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_activity_list:int = this.activity_list.length;
			output.writeShort(size_activity_list);
			var temp_repeated_byte_activity_list:ByteArray= new ByteArray;
			for(i=0; i<size_activity_list; i++) {
				var t2_activity_list:ByteArray = new ByteArray;
				var tVo_activity_list:p_activity_info = this.activity_list[i] as p_activity_info;
				tVo_activity_list.writeToDataOutput(t2_activity_list);
				var len_tVo_activity_list:int = t2_activity_list.length;
				temp_repeated_byte_activity_list.writeInt(len_tVo_activity_list);
				temp_repeated_byte_activity_list.writeBytes(t2_activity_list);
			}
			output.writeInt(temp_repeated_byte_activity_list.length);
			output.writeBytes(temp_repeated_byte_activity_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_activity_list:int = input.readShort();
			var length_activity_list:int = input.readInt();
			if (length_activity_list > 0) {
				var byte_activity_list:ByteArray = new ByteArray; 
				input.readBytes(byte_activity_list, 0, length_activity_list);
				for(i=0; i<size_activity_list; i++) {
					var tmp_activity_list:p_activity_info = new p_activity_info;
					var tmp_activity_list_length:int = byte_activity_list.readInt();
					var tmp_activity_list_byte:ByteArray = new ByteArray;
					byte_activity_list.readBytes(tmp_activity_list_byte, 0, tmp_activity_list_length);
					tmp_activity_list.readFromDataOutput(tmp_activity_list_byte);
					this.activity_list.push(tmp_activity_list);
				}
			}
		}
	}
}
