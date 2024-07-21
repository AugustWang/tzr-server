package proto.line {
	import proto.common.p_online_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_notify_online_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var online_list:Array = new Array;
		public function m_family_notify_online_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_notify_online_toc", m_family_notify_online_toc);
		}
		public override function getMethodName():String {
			return 'family_notify_online';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_online_list:int = this.online_list.length;
			output.writeShort(size_online_list);
			var temp_repeated_byte_online_list:ByteArray= new ByteArray;
			for(i=0; i<size_online_list; i++) {
				var t2_online_list:ByteArray = new ByteArray;
				var tVo_online_list:p_online_info = this.online_list[i] as p_online_info;
				tVo_online_list.writeToDataOutput(t2_online_list);
				var len_tVo_online_list:int = t2_online_list.length;
				temp_repeated_byte_online_list.writeInt(len_tVo_online_list);
				temp_repeated_byte_online_list.writeBytes(t2_online_list);
			}
			output.writeInt(temp_repeated_byte_online_list.length);
			output.writeBytes(temp_repeated_byte_online_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_online_list:int = input.readShort();
			var length_online_list:int = input.readInt();
			if (length_online_list > 0) {
				var byte_online_list:ByteArray = new ByteArray; 
				input.readBytes(byte_online_list, 0, length_online_list);
				for(i=0; i<size_online_list; i++) {
					var tmp_online_list:p_online_info = new p_online_info;
					var tmp_online_list_length:int = byte_online_list.readInt();
					var tmp_online_list_byte:ByteArray = new ByteArray;
					byte_online_list.readBytes(tmp_online_list_byte, 0, tmp_online_list_length);
					tmp_online_list.readFromDataOutput(tmp_online_list_byte);
					this.online_list.push(tmp_online_list);
				}
			}
		}
	}
}
