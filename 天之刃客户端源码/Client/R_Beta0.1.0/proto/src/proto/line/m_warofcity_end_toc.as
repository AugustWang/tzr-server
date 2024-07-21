package proto.line {
	import proto.line.p_warofcity_family_winner;
	import proto.line.p_warofcity_family_winner;
	import proto.line.p_warofcity_family_winner;
	import proto.line.p_warofcity_role_winner;
	import proto.line.p_warofcity_role_winner;
	import proto.line.p_warofcity_role_winner;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_end_toc extends Message
	{
		public var first:p_warofcity_family_winner = null;
		public var second:p_warofcity_family_winner = null;
		public var third:p_warofcity_family_winner = null;
		public var first_role:p_warofcity_role_winner = null;
		public var second_role:p_warofcity_role_winner = null;
		public var third_role:p_warofcity_role_winner = null;
		public function m_warofcity_end_toc() {
			super();
			this.first = new p_warofcity_family_winner;
			this.second = new p_warofcity_family_winner;
			this.third = new p_warofcity_family_winner;
			this.first_role = new p_warofcity_role_winner;
			this.second_role = new p_warofcity_role_winner;
			this.third_role = new p_warofcity_role_winner;

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_end_toc", m_warofcity_end_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_end';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_first:ByteArray = new ByteArray;
			this.first.writeToDataOutput(tmp_first);
			var size_tmp_first:int = tmp_first.length;
			output.writeInt(size_tmp_first);
			output.writeBytes(tmp_first);
			var tmp_second:ByteArray = new ByteArray;
			this.second.writeToDataOutput(tmp_second);
			var size_tmp_second:int = tmp_second.length;
			output.writeInt(size_tmp_second);
			output.writeBytes(tmp_second);
			var tmp_third:ByteArray = new ByteArray;
			this.third.writeToDataOutput(tmp_third);
			var size_tmp_third:int = tmp_third.length;
			output.writeInt(size_tmp_third);
			output.writeBytes(tmp_third);
			var tmp_first_role:ByteArray = new ByteArray;
			this.first_role.writeToDataOutput(tmp_first_role);
			var size_tmp_first_role:int = tmp_first_role.length;
			output.writeInt(size_tmp_first_role);
			output.writeBytes(tmp_first_role);
			var tmp_second_role:ByteArray = new ByteArray;
			this.second_role.writeToDataOutput(tmp_second_role);
			var size_tmp_second_role:int = tmp_second_role.length;
			output.writeInt(size_tmp_second_role);
			output.writeBytes(tmp_second_role);
			var tmp_third_role:ByteArray = new ByteArray;
			this.third_role.writeToDataOutput(tmp_third_role);
			var size_tmp_third_role:int = tmp_third_role.length;
			output.writeInt(size_tmp_third_role);
			output.writeBytes(tmp_third_role);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_first_size:int = input.readInt();
			if (byte_first_size > 0) {				this.first = new p_warofcity_family_winner;
				var byte_first:ByteArray = new ByteArray;
				input.readBytes(byte_first, 0, byte_first_size);
				this.first.readFromDataOutput(byte_first);
			}
			var byte_second_size:int = input.readInt();
			if (byte_second_size > 0) {				this.second = new p_warofcity_family_winner;
				var byte_second:ByteArray = new ByteArray;
				input.readBytes(byte_second, 0, byte_second_size);
				this.second.readFromDataOutput(byte_second);
			}
			var byte_third_size:int = input.readInt();
			if (byte_third_size > 0) {				this.third = new p_warofcity_family_winner;
				var byte_third:ByteArray = new ByteArray;
				input.readBytes(byte_third, 0, byte_third_size);
				this.third.readFromDataOutput(byte_third);
			}
			var byte_first_role_size:int = input.readInt();
			if (byte_first_role_size > 0) {				this.first_role = new p_warofcity_role_winner;
				var byte_first_role:ByteArray = new ByteArray;
				input.readBytes(byte_first_role, 0, byte_first_role_size);
				this.first_role.readFromDataOutput(byte_first_role);
			}
			var byte_second_role_size:int = input.readInt();
			if (byte_second_role_size > 0) {				this.second_role = new p_warofcity_role_winner;
				var byte_second_role:ByteArray = new ByteArray;
				input.readBytes(byte_second_role, 0, byte_second_role_size);
				this.second_role.readFromDataOutput(byte_second_role);
			}
			var byte_third_role_size:int = input.readInt();
			if (byte_third_role_size > 0) {				this.third_role = new p_warofcity_role_winner;
				var byte_third_role:ByteArray = new ByteArray;
				input.readBytes(byte_third_role, 0, byte_third_role_size);
				this.third_role.readFromDataOutput(byte_third_role);
			}
		}
	}
}
