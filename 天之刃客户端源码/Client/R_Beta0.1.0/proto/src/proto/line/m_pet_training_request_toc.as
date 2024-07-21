package proto.line {
	import proto.common.p_pet_training_info;
	import proto.common.p_pet_training_info;
	import proto.common.p_pet;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_training_request_toc extends Message
	{
		public var op_type:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var cur_room:int = 0;
		public var pet_training_list:Array = new Array;
		public var pet_training_info:p_pet_training_info = null;
		public var pet_info:p_pet = null;
		public function m_pet_training_request_toc() {
			super();
			this.pet_training_info = new p_pet_training_info;
			this.pet_info = new p_pet;

			flash.net.registerClassAlias("copy.proto.line.m_pet_training_request_toc", m_pet_training_request_toc);
		}
		public override function getMethodName():String {
			return 'pet_training_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.cur_room);
			var size_pet_training_list:int = this.pet_training_list.length;
			output.writeShort(size_pet_training_list);
			var temp_repeated_byte_pet_training_list:ByteArray= new ByteArray;
			for(i=0; i<size_pet_training_list; i++) {
				var t2_pet_training_list:ByteArray = new ByteArray;
				var tVo_pet_training_list:p_pet_training_info = this.pet_training_list[i] as p_pet_training_info;
				tVo_pet_training_list.writeToDataOutput(t2_pet_training_list);
				var len_tVo_pet_training_list:int = t2_pet_training_list.length;
				temp_repeated_byte_pet_training_list.writeInt(len_tVo_pet_training_list);
				temp_repeated_byte_pet_training_list.writeBytes(t2_pet_training_list);
			}
			output.writeInt(temp_repeated_byte_pet_training_list.length);
			output.writeBytes(temp_repeated_byte_pet_training_list);
			var tmp_pet_training_info:ByteArray = new ByteArray;
			this.pet_training_info.writeToDataOutput(tmp_pet_training_info);
			var size_tmp_pet_training_info:int = tmp_pet_training_info.length;
			output.writeInt(size_tmp_pet_training_info);
			output.writeBytes(tmp_pet_training_info);
			var tmp_pet_info:ByteArray = new ByteArray;
			this.pet_info.writeToDataOutput(tmp_pet_info);
			var size_tmp_pet_info:int = tmp_pet_info.length;
			output.writeInt(size_tmp_pet_info);
			output.writeBytes(tmp_pet_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.cur_room = input.readInt();
			var size_pet_training_list:int = input.readShort();
			var length_pet_training_list:int = input.readInt();
			if (length_pet_training_list > 0) {
				var byte_pet_training_list:ByteArray = new ByteArray; 
				input.readBytes(byte_pet_training_list, 0, length_pet_training_list);
				for(i=0; i<size_pet_training_list; i++) {
					var tmp_pet_training_list:p_pet_training_info = new p_pet_training_info;
					var tmp_pet_training_list_length:int = byte_pet_training_list.readInt();
					var tmp_pet_training_list_byte:ByteArray = new ByteArray;
					byte_pet_training_list.readBytes(tmp_pet_training_list_byte, 0, tmp_pet_training_list_length);
					tmp_pet_training_list.readFromDataOutput(tmp_pet_training_list_byte);
					this.pet_training_list.push(tmp_pet_training_list);
				}
			}
			var byte_pet_training_info_size:int = input.readInt();
			if (byte_pet_training_info_size > 0) {				this.pet_training_info = new p_pet_training_info;
				var byte_pet_training_info:ByteArray = new ByteArray;
				input.readBytes(byte_pet_training_info, 0, byte_pet_training_info_size);
				this.pet_training_info.readFromDataOutput(byte_pet_training_info);
			}
			var byte_pet_info_size:int = input.readInt();
			if (byte_pet_info_size > 0) {				this.pet_info = new p_pet;
				var byte_pet_info:ByteArray = new ByteArray;
				input.readBytes(byte_pet_info, 0, byte_pet_info_size);
				this.pet_info.readFromDataOutput(byte_pet_info);
			}
		}
	}
}
