package proto.common {
	import proto.common.p_role_base;
	import proto.common.p_role_fight;
	import proto.common.p_role_pos;
	import proto.common.p_role_attr;
	import proto.common.p_role_ext;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role extends Message
	{
		public var base:p_role_base = null;
		public var fight:p_role_fight = null;
		public var pos:p_role_pos = null;
		public var attr:p_role_attr = null;
		public var ext:p_role_ext = null;
		public function p_role() {
			super();
			this.base = new p_role_base;
			this.fight = new p_role_fight;
			this.pos = new p_role_pos;
			this.attr = new p_role_attr;
			this.ext = new p_role_ext;

			flash.net.registerClassAlias("copy.proto.common.p_role", p_role);
		}
		public override function getMethodName():String {
			return '';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_base:ByteArray = new ByteArray;
			this.base.writeToDataOutput(tmp_base);
			var size_tmp_base:int = tmp_base.length;
			output.writeInt(size_tmp_base);
			output.writeBytes(tmp_base);
			var tmp_fight:ByteArray = new ByteArray;
			this.fight.writeToDataOutput(tmp_fight);
			var size_tmp_fight:int = tmp_fight.length;
			output.writeInt(size_tmp_fight);
			output.writeBytes(tmp_fight);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			var tmp_attr:ByteArray = new ByteArray;
			this.attr.writeToDataOutput(tmp_attr);
			var size_tmp_attr:int = tmp_attr.length;
			output.writeInt(size_tmp_attr);
			output.writeBytes(tmp_attr);
			var tmp_ext:ByteArray = new ByteArray;
			this.ext.writeToDataOutput(tmp_ext);
			var size_tmp_ext:int = tmp_ext.length;
			output.writeInt(size_tmp_ext);
			output.writeBytes(tmp_ext);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_base_size:int = input.readInt();
			if (byte_base_size > 0) {				this.base = new p_role_base;
				var byte_base:ByteArray = new ByteArray;
				input.readBytes(byte_base, 0, byte_base_size);
				this.base.readFromDataOutput(byte_base);
			}
			var byte_fight_size:int = input.readInt();
			if (byte_fight_size > 0) {				this.fight = new p_role_fight;
				var byte_fight:ByteArray = new ByteArray;
				input.readBytes(byte_fight, 0, byte_fight_size);
				this.fight.readFromDataOutput(byte_fight);
			}
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_role_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			var byte_attr_size:int = input.readInt();
			if (byte_attr_size > 0) {				this.attr = new p_role_attr;
				var byte_attr:ByteArray = new ByteArray;
				input.readBytes(byte_attr, 0, byte_attr_size);
				this.attr.readFromDataOutput(byte_attr);
			}
			var byte_ext_size:int = input.readInt();
			if (byte_ext_size > 0) {				this.ext = new p_role_ext;
				var byte_ext:ByteArray = new ByteArray;
				input.readBytes(byte_ext, 0, byte_ext_size);
				this.ext.readFromDataOutput(byte_ext);
			}
		}
	}
}
