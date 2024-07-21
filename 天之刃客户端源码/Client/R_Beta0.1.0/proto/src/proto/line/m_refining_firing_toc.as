package proto.line {
	import proto.common.p_refining;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_firing_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var op_type:int = 0;
		public var sub_op_type:int = 0;
		public var firing_list:Array = new Array;
		public var new_list:Array = new Array;
		public var del_list:Array = new Array;
		public var update_list:Array = new Array;
		public function m_refining_firing_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_firing_toc", m_refining_firing_toc);
		}
		public override function getMethodName():String {
			return 'refining_firing';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.op_type);
			output.writeInt(this.sub_op_type);
			var size_firing_list:int = this.firing_list.length;
			output.writeShort(size_firing_list);
			var temp_repeated_byte_firing_list:ByteArray= new ByteArray;
			for(i=0; i<size_firing_list; i++) {
				var t2_firing_list:ByteArray = new ByteArray;
				var tVo_firing_list:p_refining = this.firing_list[i] as p_refining;
				tVo_firing_list.writeToDataOutput(t2_firing_list);
				var len_tVo_firing_list:int = t2_firing_list.length;
				temp_repeated_byte_firing_list.writeInt(len_tVo_firing_list);
				temp_repeated_byte_firing_list.writeBytes(t2_firing_list);
			}
			output.writeInt(temp_repeated_byte_firing_list.length);
			output.writeBytes(temp_repeated_byte_firing_list);
			var size_new_list:int = this.new_list.length;
			output.writeShort(size_new_list);
			var temp_repeated_byte_new_list:ByteArray= new ByteArray;
			for(i=0; i<size_new_list; i++) {
				var t2_new_list:ByteArray = new ByteArray;
				var tVo_new_list:p_goods = this.new_list[i] as p_goods;
				tVo_new_list.writeToDataOutput(t2_new_list);
				var len_tVo_new_list:int = t2_new_list.length;
				temp_repeated_byte_new_list.writeInt(len_tVo_new_list);
				temp_repeated_byte_new_list.writeBytes(t2_new_list);
			}
			output.writeInt(temp_repeated_byte_new_list.length);
			output.writeBytes(temp_repeated_byte_new_list);
			var size_del_list:int = this.del_list.length;
			output.writeShort(size_del_list);
			var temp_repeated_byte_del_list:ByteArray= new ByteArray;
			for(i=0; i<size_del_list; i++) {
				var t2_del_list:ByteArray = new ByteArray;
				var tVo_del_list:p_goods = this.del_list[i] as p_goods;
				tVo_del_list.writeToDataOutput(t2_del_list);
				var len_tVo_del_list:int = t2_del_list.length;
				temp_repeated_byte_del_list.writeInt(len_tVo_del_list);
				temp_repeated_byte_del_list.writeBytes(t2_del_list);
			}
			output.writeInt(temp_repeated_byte_del_list.length);
			output.writeBytes(temp_repeated_byte_del_list);
			var size_update_list:int = this.update_list.length;
			output.writeShort(size_update_list);
			var temp_repeated_byte_update_list:ByteArray= new ByteArray;
			for(i=0; i<size_update_list; i++) {
				var t2_update_list:ByteArray = new ByteArray;
				var tVo_update_list:p_goods = this.update_list[i] as p_goods;
				tVo_update_list.writeToDataOutput(t2_update_list);
				var len_tVo_update_list:int = t2_update_list.length;
				temp_repeated_byte_update_list.writeInt(len_tVo_update_list);
				temp_repeated_byte_update_list.writeBytes(t2_update_list);
			}
			output.writeInt(temp_repeated_byte_update_list.length);
			output.writeBytes(temp_repeated_byte_update_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.op_type = input.readInt();
			this.sub_op_type = input.readInt();
			var size_firing_list:int = input.readShort();
			var length_firing_list:int = input.readInt();
			if (length_firing_list > 0) {
				var byte_firing_list:ByteArray = new ByteArray; 
				input.readBytes(byte_firing_list, 0, length_firing_list);
				for(i=0; i<size_firing_list; i++) {
					var tmp_firing_list:p_refining = new p_refining;
					var tmp_firing_list_length:int = byte_firing_list.readInt();
					var tmp_firing_list_byte:ByteArray = new ByteArray;
					byte_firing_list.readBytes(tmp_firing_list_byte, 0, tmp_firing_list_length);
					tmp_firing_list.readFromDataOutput(tmp_firing_list_byte);
					this.firing_list.push(tmp_firing_list);
				}
			}
			var size_new_list:int = input.readShort();
			var length_new_list:int = input.readInt();
			if (length_new_list > 0) {
				var byte_new_list:ByteArray = new ByteArray; 
				input.readBytes(byte_new_list, 0, length_new_list);
				for(i=0; i<size_new_list; i++) {
					var tmp_new_list:p_goods = new p_goods;
					var tmp_new_list_length:int = byte_new_list.readInt();
					var tmp_new_list_byte:ByteArray = new ByteArray;
					byte_new_list.readBytes(tmp_new_list_byte, 0, tmp_new_list_length);
					tmp_new_list.readFromDataOutput(tmp_new_list_byte);
					this.new_list.push(tmp_new_list);
				}
			}
			var size_del_list:int = input.readShort();
			var length_del_list:int = input.readInt();
			if (length_del_list > 0) {
				var byte_del_list:ByteArray = new ByteArray; 
				input.readBytes(byte_del_list, 0, length_del_list);
				for(i=0; i<size_del_list; i++) {
					var tmp_del_list:p_goods = new p_goods;
					var tmp_del_list_length:int = byte_del_list.readInt();
					var tmp_del_list_byte:ByteArray = new ByteArray;
					byte_del_list.readBytes(tmp_del_list_byte, 0, tmp_del_list_length);
					tmp_del_list.readFromDataOutput(tmp_del_list_byte);
					this.del_list.push(tmp_del_list);
				}
			}
			var size_update_list:int = input.readShort();
			var length_update_list:int = input.readInt();
			if (length_update_list > 0) {
				var byte_update_list:ByteArray = new ByteArray; 
				input.readBytes(byte_update_list, 0, length_update_list);
				for(i=0; i<size_update_list; i++) {
					var tmp_update_list:p_goods = new p_goods;
					var tmp_update_list_length:int = byte_update_list.readInt();
					var tmp_update_list_byte:ByteArray = new ByteArray;
					byte_update_list.readBytes(tmp_update_list_byte, 0, tmp_update_list_length);
					tmp_update_list.readFromDataOutput(tmp_update_list_byte);
					this.update_list.push(tmp_update_list);
				}
			}
		}
	}
}
