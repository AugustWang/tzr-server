package proto.line {
	import proto.line.p_warofcity_family_mark;
	import proto.line.p_warofcity_role_mark;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_get_mark_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var families:Array = new Array;
		public var roles:Array = new Array;
		public function m_warofcity_get_mark_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_get_mark_toc", m_warofcity_get_mark_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_get_mark';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_families:int = this.families.length;
			output.writeShort(size_families);
			var temp_repeated_byte_families:ByteArray= new ByteArray;
			for(i=0; i<size_families; i++) {
				var t2_families:ByteArray = new ByteArray;
				var tVo_families:p_warofcity_family_mark = this.families[i] as p_warofcity_family_mark;
				tVo_families.writeToDataOutput(t2_families);
				var len_tVo_families:int = t2_families.length;
				temp_repeated_byte_families.writeInt(len_tVo_families);
				temp_repeated_byte_families.writeBytes(t2_families);
			}
			output.writeInt(temp_repeated_byte_families.length);
			output.writeBytes(temp_repeated_byte_families);
			var size_roles:int = this.roles.length;
			output.writeShort(size_roles);
			var temp_repeated_byte_roles:ByteArray= new ByteArray;
			for(i=0; i<size_roles; i++) {
				var t2_roles:ByteArray = new ByteArray;
				var tVo_roles:p_warofcity_role_mark = this.roles[i] as p_warofcity_role_mark;
				tVo_roles.writeToDataOutput(t2_roles);
				var len_tVo_roles:int = t2_roles.length;
				temp_repeated_byte_roles.writeInt(len_tVo_roles);
				temp_repeated_byte_roles.writeBytes(t2_roles);
			}
			output.writeInt(temp_repeated_byte_roles.length);
			output.writeBytes(temp_repeated_byte_roles);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_families:int = input.readShort();
			var length_families:int = input.readInt();
			if (length_families > 0) {
				var byte_families:ByteArray = new ByteArray; 
				input.readBytes(byte_families, 0, length_families);
				for(i=0; i<size_families; i++) {
					var tmp_families:p_warofcity_family_mark = new p_warofcity_family_mark;
					var tmp_families_length:int = byte_families.readInt();
					var tmp_families_byte:ByteArray = new ByteArray;
					byte_families.readBytes(tmp_families_byte, 0, tmp_families_length);
					tmp_families.readFromDataOutput(tmp_families_byte);
					this.families.push(tmp_families);
				}
			}
			var size_roles:int = input.readShort();
			var length_roles:int = input.readInt();
			if (length_roles > 0) {
				var byte_roles:ByteArray = new ByteArray; 
				input.readBytes(byte_roles, 0, length_roles);
				for(i=0; i<size_roles; i++) {
					var tmp_roles:p_warofcity_role_mark = new p_warofcity_role_mark;
					var tmp_roles_length:int = byte_roles.readInt();
					var tmp_roles_byte:ByteArray = new ByteArray;
					byte_roles.readBytes(tmp_roles_byte, 0, tmp_roles_length);
					tmp_roles.readFromDataOutput(tmp_roles_byte);
					this.roles.push(tmp_roles);
				}
			}
		}
	}
}
