package proto.line {
	import proto.common.p_vip_list_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var vip_list:Array = new Array;
		public var max_page:int = 0;
		public function m_vip_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vip_list_toc", m_vip_list_toc);
		}
		public override function getMethodName():String {
			return 'vip_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_vip_list:int = this.vip_list.length;
			output.writeShort(size_vip_list);
			var temp_repeated_byte_vip_list:ByteArray= new ByteArray;
			for(i=0; i<size_vip_list; i++) {
				var t2_vip_list:ByteArray = new ByteArray;
				var tVo_vip_list:p_vip_list_info = this.vip_list[i] as p_vip_list_info;
				tVo_vip_list.writeToDataOutput(t2_vip_list);
				var len_tVo_vip_list:int = t2_vip_list.length;
				temp_repeated_byte_vip_list.writeInt(len_tVo_vip_list);
				temp_repeated_byte_vip_list.writeBytes(t2_vip_list);
			}
			output.writeInt(temp_repeated_byte_vip_list.length);
			output.writeBytes(temp_repeated_byte_vip_list);
			output.writeInt(this.max_page);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_vip_list:int = input.readShort();
			var length_vip_list:int = input.readInt();
			if (length_vip_list > 0) {
				var byte_vip_list:ByteArray = new ByteArray; 
				input.readBytes(byte_vip_list, 0, length_vip_list);
				for(i=0; i<size_vip_list; i++) {
					var tmp_vip_list:p_vip_list_info = new p_vip_list_info;
					var tmp_vip_list_length:int = byte_vip_list.readInt();
					var tmp_vip_list_byte:ByteArray = new ByteArray;
					byte_vip_list.readBytes(tmp_vip_list_byte, 0, tmp_vip_list_length);
					tmp_vip_list.readFromDataOutput(tmp_vip_list_byte);
					this.vip_list.push(tmp_vip_list);
				}
			}
			this.max_page = input.readInt();
		}
	}
}
