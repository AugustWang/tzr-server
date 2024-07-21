package proto.line {
	import proto.common.p_prestige_item;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_prestige_query_toc extends Message
	{
		public var op_type:int = 0;
		public var group_id:int = 0;
		public var class_id:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var item_list:Array = new Array;
		public function m_prestige_query_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_prestige_query_toc", m_prestige_query_toc);
		}
		public override function getMethodName():String {
			return 'prestige_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.group_id);
			output.writeInt(this.class_id);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_item_list:int = this.item_list.length;
			output.writeShort(size_item_list);
			var temp_repeated_byte_item_list:ByteArray= new ByteArray;
			for(i=0; i<size_item_list; i++) {
				var t2_item_list:ByteArray = new ByteArray;
				var tVo_item_list:p_prestige_item = this.item_list[i] as p_prestige_item;
				tVo_item_list.writeToDataOutput(t2_item_list);
				var len_tVo_item_list:int = t2_item_list.length;
				temp_repeated_byte_item_list.writeInt(len_tVo_item_list);
				temp_repeated_byte_item_list.writeBytes(t2_item_list);
			}
			output.writeInt(temp_repeated_byte_item_list.length);
			output.writeBytes(temp_repeated_byte_item_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.group_id = input.readInt();
			this.class_id = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_item_list:int = input.readShort();
			var length_item_list:int = input.readInt();
			if (length_item_list > 0) {
				var byte_item_list:ByteArray = new ByteArray; 
				input.readBytes(byte_item_list, 0, length_item_list);
				for(i=0; i<size_item_list; i++) {
					var tmp_item_list:p_prestige_item = new p_prestige_item;
					var tmp_item_list_length:int = byte_item_list.readInt();
					var tmp_item_list_byte:ByteArray = new ByteArray;
					byte_item_list.readBytes(tmp_item_list_byte, 0, tmp_item_list_length);
					tmp_item_list.readFromDataOutput(tmp_item_list_byte);
					this.item_list.push(tmp_item_list);
				}
			}
		}
	}
}
