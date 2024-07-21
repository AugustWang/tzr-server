package proto.line {
	import proto.common.p_accumulate_exp_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_accumulate_exp_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var list:Array = new Array;
		public function m_accumulate_exp_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_accumulate_exp_list_toc", m_accumulate_exp_list_toc);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_list:int = this.list.length;
			output.writeShort(size_list);
			var temp_repeated_byte_list:ByteArray= new ByteArray;
			for(i=0; i<size_list; i++) {
				var t2_list:ByteArray = new ByteArray;
				var tVo_list:p_accumulate_exp_info = this.list[i] as p_accumulate_exp_info;
				tVo_list.writeToDataOutput(t2_list);
				var len_tVo_list:int = t2_list.length;
				temp_repeated_byte_list.writeInt(len_tVo_list);
				temp_repeated_byte_list.writeBytes(t2_list);
			}
			output.writeInt(temp_repeated_byte_list.length);
			output.writeBytes(temp_repeated_byte_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_list:int = input.readShort();
			var length_list:int = input.readInt();
			if (length_list > 0) {
				var byte_list:ByteArray = new ByteArray; 
				input.readBytes(byte_list, 0, length_list);
				for(i=0; i<size_list; i++) {
					var tmp_list:p_accumulate_exp_info = new p_accumulate_exp_info;
					var tmp_list_length:int = byte_list.readInt();
					var tmp_list_byte:ByteArray = new ByteArray;
					byte_list.readBytes(tmp_list_byte, 0, tmp_list_length);
					tmp_list.readFromDataOutput(tmp_list_byte);
					this.list.push(tmp_list);
				}
			}
		}
	}
}
