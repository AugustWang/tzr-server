package proto.line {
	import proto.common.p_role_base;
	import proto.common.p_role_fight;
	import proto.common.p_role_pos;
	import proto.common.p_map_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_relive_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var role_base:p_role_base = null;
		public var role_fight:p_role_fight = null;
		public var role_pos:p_role_pos = null;
		public var map_role:p_map_role = null;
		public var map_changed:Boolean = false;
		public function m_role2_relive_toc() {
			super();
			this.role_base = new p_role_base;
			this.role_fight = new p_role_fight;
			this.role_pos = new p_role_pos;
			this.map_role = new p_map_role;

			flash.net.registerClassAlias("copy.proto.line.m_role2_relive_toc", m_role2_relive_toc);
		}
		public override function getMethodName():String {
			return 'role2_relive';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_role_base:ByteArray = new ByteArray;
			this.role_base.writeToDataOutput(tmp_role_base);
			var size_tmp_role_base:int = tmp_role_base.length;
			output.writeInt(size_tmp_role_base);
			output.writeBytes(tmp_role_base);
			var tmp_role_fight:ByteArray = new ByteArray;
			this.role_fight.writeToDataOutput(tmp_role_fight);
			var size_tmp_role_fight:int = tmp_role_fight.length;
			output.writeInt(size_tmp_role_fight);
			output.writeBytes(tmp_role_fight);
			var tmp_role_pos:ByteArray = new ByteArray;
			this.role_pos.writeToDataOutput(tmp_role_pos);
			var size_tmp_role_pos:int = tmp_role_pos.length;
			output.writeInt(size_tmp_role_pos);
			output.writeBytes(tmp_role_pos);
			var tmp_map_role:ByteArray = new ByteArray;
			this.map_role.writeToDataOutput(tmp_map_role);
			var size_tmp_map_role:int = tmp_map_role.length;
			output.writeInt(size_tmp_map_role);
			output.writeBytes(tmp_map_role);
			output.writeBoolean(this.map_changed);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			var byte_role_base_size:int = input.readInt();
			if (byte_role_base_size > 0) {				this.role_base = new p_role_base;
				var byte_role_base:ByteArray = new ByteArray;
				input.readBytes(byte_role_base, 0, byte_role_base_size);
				this.role_base.readFromDataOutput(byte_role_base);
			}
			var byte_role_fight_size:int = input.readInt();
			if (byte_role_fight_size > 0) {				this.role_fight = new p_role_fight;
				var byte_role_fight:ByteArray = new ByteArray;
				input.readBytes(byte_role_fight, 0, byte_role_fight_size);
				this.role_fight.readFromDataOutput(byte_role_fight);
			}
			var byte_role_pos_size:int = input.readInt();
			if (byte_role_pos_size > 0) {				this.role_pos = new p_role_pos;
				var byte_role_pos:ByteArray = new ByteArray;
				input.readBytes(byte_role_pos, 0, byte_role_pos_size);
				this.role_pos.readFromDataOutput(byte_role_pos);
			}
			var byte_map_role_size:int = input.readInt();
			if (byte_map_role_size > 0) {				this.map_role = new p_map_role;
				var byte_map_role:ByteArray = new ByteArray;
				input.readBytes(byte_map_role, 0, byte_map_role_size);
				this.map_role.readFromDataOutput(byte_map_role);
			}
			this.map_changed = input.readBoolean();
		}
	}
}
