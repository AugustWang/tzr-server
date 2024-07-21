package proto.line {
	import proto.common.p_role_family_donate_info;
	import proto.common.p_role_family_donate_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_get_donate_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var donate_gold_list:Array = new Array;
		public var donate_silver_list:Array = new Array;
		public function m_family_get_donate_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_get_donate_info_toc", m_family_get_donate_info_toc);
		}
		public override function getMethodName():String {
			return 'family_get_donate_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_donate_gold_list:int = this.donate_gold_list.length;
			output.writeShort(size_donate_gold_list);
			var temp_repeated_byte_donate_gold_list:ByteArray= new ByteArray;
			for(i=0; i<size_donate_gold_list; i++) {
				var t2_donate_gold_list:ByteArray = new ByteArray;
				var tVo_donate_gold_list:p_role_family_donate_info = this.donate_gold_list[i] as p_role_family_donate_info;
				tVo_donate_gold_list.writeToDataOutput(t2_donate_gold_list);
				var len_tVo_donate_gold_list:int = t2_donate_gold_list.length;
				temp_repeated_byte_donate_gold_list.writeInt(len_tVo_donate_gold_list);
				temp_repeated_byte_donate_gold_list.writeBytes(t2_donate_gold_list);
			}
			output.writeInt(temp_repeated_byte_donate_gold_list.length);
			output.writeBytes(temp_repeated_byte_donate_gold_list);
			var size_donate_silver_list:int = this.donate_silver_list.length;
			output.writeShort(size_donate_silver_list);
			var temp_repeated_byte_donate_silver_list:ByteArray= new ByteArray;
			for(i=0; i<size_donate_silver_list; i++) {
				var t2_donate_silver_list:ByteArray = new ByteArray;
				var tVo_donate_silver_list:p_role_family_donate_info = this.donate_silver_list[i] as p_role_family_donate_info;
				tVo_donate_silver_list.writeToDataOutput(t2_donate_silver_list);
				var len_tVo_donate_silver_list:int = t2_donate_silver_list.length;
				temp_repeated_byte_donate_silver_list.writeInt(len_tVo_donate_silver_list);
				temp_repeated_byte_donate_silver_list.writeBytes(t2_donate_silver_list);
			}
			output.writeInt(temp_repeated_byte_donate_silver_list.length);
			output.writeBytes(temp_repeated_byte_donate_silver_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_donate_gold_list:int = input.readShort();
			var length_donate_gold_list:int = input.readInt();
			if (length_donate_gold_list > 0) {
				var byte_donate_gold_list:ByteArray = new ByteArray; 
				input.readBytes(byte_donate_gold_list, 0, length_donate_gold_list);
				for(i=0; i<size_donate_gold_list; i++) {
					var tmp_donate_gold_list:p_role_family_donate_info = new p_role_family_donate_info;
					var tmp_donate_gold_list_length:int = byte_donate_gold_list.readInt();
					var tmp_donate_gold_list_byte:ByteArray = new ByteArray;
					byte_donate_gold_list.readBytes(tmp_donate_gold_list_byte, 0, tmp_donate_gold_list_length);
					tmp_donate_gold_list.readFromDataOutput(tmp_donate_gold_list_byte);
					this.donate_gold_list.push(tmp_donate_gold_list);
				}
			}
			var size_donate_silver_list:int = input.readShort();
			var length_donate_silver_list:int = input.readInt();
			if (length_donate_silver_list > 0) {
				var byte_donate_silver_list:ByteArray = new ByteArray; 
				input.readBytes(byte_donate_silver_list, 0, length_donate_silver_list);
				for(i=0; i<size_donate_silver_list; i++) {
					var tmp_donate_silver_list:p_role_family_donate_info = new p_role_family_donate_info;
					var tmp_donate_silver_list_length:int = byte_donate_silver_list.readInt();
					var tmp_donate_silver_list_byte:ByteArray = new ByteArray;
					byte_donate_silver_list.readBytes(tmp_donate_silver_list_byte, 0, tmp_donate_silver_list_length);
					tmp_donate_silver_list.readFromDataOutput(tmp_donate_silver_list_byte);
					this.donate_silver_list.push(tmp_donate_silver_list);
				}
			}
		}
	}
}
