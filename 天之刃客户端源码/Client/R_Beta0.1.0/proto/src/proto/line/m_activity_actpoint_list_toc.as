package proto.line {
	import proto.common.p_actpoint_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_actpoint_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var is_rewarded:Boolean = true;
		public var actpoint_list:Array = new Array;
		public function m_activity_actpoint_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_actpoint_list_toc", m_activity_actpoint_list_toc);
		}
		public override function getMethodName():String {
			return 'activity_actpoint_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_rewarded);
			var size_actpoint_list:int = this.actpoint_list.length;
			output.writeShort(size_actpoint_list);
			var temp_repeated_byte_actpoint_list:ByteArray= new ByteArray;
			for(i=0; i<size_actpoint_list; i++) {
				var t2_actpoint_list:ByteArray = new ByteArray;
				var tVo_actpoint_list:p_actpoint_info = this.actpoint_list[i] as p_actpoint_info;
				tVo_actpoint_list.writeToDataOutput(t2_actpoint_list);
				var len_tVo_actpoint_list:int = t2_actpoint_list.length;
				temp_repeated_byte_actpoint_list.writeInt(len_tVo_actpoint_list);
				temp_repeated_byte_actpoint_list.writeBytes(t2_actpoint_list);
			}
			output.writeInt(temp_repeated_byte_actpoint_list.length);
			output.writeBytes(temp_repeated_byte_actpoint_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.is_rewarded = input.readBoolean();
			var size_actpoint_list:int = input.readShort();
			var length_actpoint_list:int = input.readInt();
			if (length_actpoint_list > 0) {
				var byte_actpoint_list:ByteArray = new ByteArray; 
				input.readBytes(byte_actpoint_list, 0, length_actpoint_list);
				for(i=0; i<size_actpoint_list; i++) {
					var tmp_actpoint_list:p_actpoint_info = new p_actpoint_info;
					var tmp_actpoint_list_length:int = byte_actpoint_list.readInt();
					var tmp_actpoint_list_byte:ByteArray = new ByteArray;
					byte_actpoint_list.readBytes(tmp_actpoint_list_byte, 0, tmp_actpoint_list_length);
					tmp_actpoint_list.readFromDataOutput(tmp_actpoint_list_byte);
					this.actpoint_list.push(tmp_actpoint_list);
				}
			}
		}
	}
}
