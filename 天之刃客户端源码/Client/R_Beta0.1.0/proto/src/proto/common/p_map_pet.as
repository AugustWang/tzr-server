package proto.common {
	import proto.common.p_pos;
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_pet extends Message
	{
		public var pet_id:int = 0;
		public var type_id:int = 0;
		public var pet_name:String = "";
		public var state:int = 1;
		public var hp:int = 0;
		public var pos:p_pos = null;
		public var attack_speed:int = 0;
		public var max_hp:int = 0;
		public var level:int = 0;
		public var role_id:int = 0;
		public var state_buffs:Array = new Array;
		public var title:String = "";
		public var color:int = 0;
		public function p_map_pet() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_map_pet", p_map_pet);
		}
		public override function getMethodName():String {
			return 'map';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			output.writeInt(this.type_id);
			if (this.pet_name != null) {				output.writeUTF(this.pet_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.state);
			output.writeInt(this.hp);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.attack_speed);
			output.writeInt(this.max_hp);
			output.writeInt(this.level);
			output.writeInt(this.role_id);
			var size_state_buffs:int = this.state_buffs.length;
			output.writeShort(size_state_buffs);
			var temp_repeated_byte_state_buffs:ByteArray= new ByteArray;
			for(i=0; i<size_state_buffs; i++) {
				var t2_state_buffs:ByteArray = new ByteArray;
				var tVo_state_buffs:p_actor_buf = this.state_buffs[i] as p_actor_buf;
				tVo_state_buffs.writeToDataOutput(t2_state_buffs);
				var len_tVo_state_buffs:int = t2_state_buffs.length;
				temp_repeated_byte_state_buffs.writeInt(len_tVo_state_buffs);
				temp_repeated_byte_state_buffs.writeBytes(t2_state_buffs);
			}
			output.writeInt(temp_repeated_byte_state_buffs.length);
			output.writeBytes(temp_repeated_byte_state_buffs);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.type_id = input.readInt();
			this.pet_name = input.readUTF();
			this.state = input.readInt();
			this.hp = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.attack_speed = input.readInt();
			this.max_hp = input.readInt();
			this.level = input.readInt();
			this.role_id = input.readInt();
			var size_state_buffs:int = input.readShort();
			var length_state_buffs:int = input.readInt();
			if (length_state_buffs > 0) {
				var byte_state_buffs:ByteArray = new ByteArray; 
				input.readBytes(byte_state_buffs, 0, length_state_buffs);
				for(i=0; i<size_state_buffs; i++) {
					var tmp_state_buffs:p_actor_buf = new p_actor_buf;
					var tmp_state_buffs_length:int = byte_state_buffs.readInt();
					var tmp_state_buffs_byte:ByteArray = new ByteArray;
					byte_state_buffs.readBytes(tmp_state_buffs_byte, 0, tmp_state_buffs_length);
					tmp_state_buffs.readFromDataOutput(tmp_state_buffs_byte);
					this.state_buffs.push(tmp_state_buffs);
				}
			}
			this.title = input.readUTF();
			this.color = input.readInt();
		}
	}
}
