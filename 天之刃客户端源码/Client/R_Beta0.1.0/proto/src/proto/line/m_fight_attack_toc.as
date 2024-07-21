package proto.line {
	import proto.common.p_pos;
	import proto.line.p_attack_result;
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fight_attack_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var src_id:int = 0;
		public var skillid:int = 0;
		public var src_pos:p_pos = null;
		public var src_type:int = 0;
		public var result:Array = new Array;
		public var dir:int = 0;
		public var dest_pos:p_pos = null;
		public var target_type:int = 0;
		public var target_id:int = 0;
		public function m_fight_attack_toc() {
			super();
			this.src_pos = new p_pos;
			this.dest_pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.m_fight_attack_toc", m_fight_attack_toc);
		}
		public override function getMethodName():String {
			return 'fight_attack';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.src_id);
			output.writeInt(this.skillid);
			var tmp_src_pos:ByteArray = new ByteArray;
			this.src_pos.writeToDataOutput(tmp_src_pos);
			var size_tmp_src_pos:int = tmp_src_pos.length;
			output.writeInt(size_tmp_src_pos);
			output.writeBytes(tmp_src_pos);
			output.writeInt(this.src_type);
			var size_result:int = this.result.length;
			output.writeShort(size_result);
			var temp_repeated_byte_result:ByteArray= new ByteArray;
			for(i=0; i<size_result; i++) {
				var t2_result:ByteArray = new ByteArray;
				var tVo_result:p_attack_result = this.result[i] as p_attack_result;
				tVo_result.writeToDataOutput(t2_result);
				var len_tVo_result:int = t2_result.length;
				temp_repeated_byte_result.writeInt(len_tVo_result);
				temp_repeated_byte_result.writeBytes(t2_result);
			}
			output.writeInt(temp_repeated_byte_result.length);
			output.writeBytes(temp_repeated_byte_result);
			output.writeInt(this.dir);
			var tmp_dest_pos:ByteArray = new ByteArray;
			this.dest_pos.writeToDataOutput(tmp_dest_pos);
			var size_tmp_dest_pos:int = tmp_dest_pos.length;
			output.writeInt(size_tmp_dest_pos);
			output.writeBytes(tmp_dest_pos);
			output.writeInt(this.target_type);
			output.writeInt(this.target_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.src_id = input.readInt();
			this.skillid = input.readInt();
			var byte_src_pos_size:int = input.readInt();
			if (byte_src_pos_size > 0) {				this.src_pos = new p_pos;
				var byte_src_pos:ByteArray = new ByteArray;
				input.readBytes(byte_src_pos, 0, byte_src_pos_size);
				this.src_pos.readFromDataOutput(byte_src_pos);
			}
			this.src_type = input.readInt();
			var size_result:int = input.readShort();
			var length_result:int = input.readInt();
			if (length_result > 0) {
				var byte_result:ByteArray = new ByteArray; 
				input.readBytes(byte_result, 0, length_result);
				for(i=0; i<size_result; i++) {
					var tmp_result:p_attack_result = new p_attack_result;
					var tmp_result_length:int = byte_result.readInt();
					var tmp_result_byte:ByteArray = new ByteArray;
					byte_result.readBytes(tmp_result_byte, 0, tmp_result_length);
					tmp_result.readFromDataOutput(tmp_result_byte);
					this.result.push(tmp_result);
				}
			}
			this.dir = input.readInt();
			var byte_dest_pos_size:int = input.readInt();
			if (byte_dest_pos_size > 0) {				this.dest_pos = new p_pos;
				var byte_dest_pos:ByteArray = new ByteArray;
				input.readBytes(byte_dest_pos, 0, byte_dest_pos_size);
				this.dest_pos.readFromDataOutput(byte_dest_pos);
			}
			this.target_type = input.readInt();
			this.target_id = input.readInt();
		}
	}
}
