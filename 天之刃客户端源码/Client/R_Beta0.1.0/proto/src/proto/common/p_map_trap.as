package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_trap extends Message
	{
		public var trap_id:int = 0;
		public var owner_id:int = 0;
		public var owner_name:String = "";
		public var owner_type:int = 0;
		public var faction_id:int = 0;
		public var family_id:int = 0;
		public var team_id:int = 0;
		public var pk_mode:int = 0;
		public var target_area:int = 0;
		public var effects:Array = new Array;
		public var buffs:Array = new Array;
		public var skill_id:int = 0;
		public var pos:p_pos = null;
		public var remove_time:int = 0;
		public var trap_type:int = 0;
		public function p_map_trap() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_map_trap", p_map_trap);
		}
		public override function getMethodName():String {
			return 'map_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.trap_id);
			output.writeInt(this.owner_id);
			if (this.owner_name != null) {				output.writeUTF(this.owner_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.owner_type);
			output.writeInt(this.faction_id);
			output.writeInt(this.family_id);
			output.writeInt(this.team_id);
			output.writeInt(this.pk_mode);
			output.writeInt(this.target_area);
			var size_effects:int = this.effects.length;
			output.writeShort(size_effects);
			var temp_repeated_byte_effects:ByteArray= new ByteArray;
			for(i=0; i<size_effects; i++) {
				temp_repeated_byte_effects.writeInt(this.effects[i]);
			}
			output.writeInt(temp_repeated_byte_effects.length);
			output.writeBytes(temp_repeated_byte_effects);
			var size_buffs:int = this.buffs.length;
			output.writeShort(size_buffs);
			var temp_repeated_byte_buffs:ByteArray= new ByteArray;
			for(i=0; i<size_buffs; i++) {
				temp_repeated_byte_buffs.writeInt(this.buffs[i]);
			}
			output.writeInt(temp_repeated_byte_buffs.length);
			output.writeBytes(temp_repeated_byte_buffs);
			output.writeInt(this.skill_id);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.remove_time);
			output.writeInt(this.trap_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.trap_id = input.readInt();
			this.owner_id = input.readInt();
			this.owner_name = input.readUTF();
			this.owner_type = input.readInt();
			this.faction_id = input.readInt();
			this.family_id = input.readInt();
			this.team_id = input.readInt();
			this.pk_mode = input.readInt();
			this.target_area = input.readInt();
			var size_effects:int = input.readShort();
			var length_effects:int = input.readInt();
			var byte_effects:ByteArray = new ByteArray; 
			if (size_effects > 0) {
				input.readBytes(byte_effects, 0, size_effects * 4);
				for(i=0; i<size_effects; i++) {
					var tmp_effects:int = byte_effects.readInt();
					this.effects.push(tmp_effects);
				}
			}
			var size_buffs:int = input.readShort();
			var length_buffs:int = input.readInt();
			var byte_buffs:ByteArray = new ByteArray; 
			if (size_buffs > 0) {
				input.readBytes(byte_buffs, 0, size_buffs * 4);
				for(i=0; i<size_buffs; i++) {
					var tmp_buffs:int = byte_buffs.readInt();
					this.buffs.push(tmp_buffs);
				}
			}
			this.skill_id = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.remove_time = input.readInt();
			this.trap_type = input.readInt();
		}
	}
}
