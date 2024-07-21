package proto.line {
	import proto.common.p_family_member_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_member_join_toc extends Message
	{
		public var member:p_family_member_info = null;
		public function m_family_member_join_toc() {
			super();
			this.member = new p_family_member_info;

			flash.net.registerClassAlias("copy.proto.line.m_family_member_join_toc", m_family_member_join_toc);
		}
		public override function getMethodName():String {
			return 'family_member_join';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_member:ByteArray = new ByteArray;
			this.member.writeToDataOutput(tmp_member);
			var size_tmp_member:int = tmp_member.length;
			output.writeInt(size_tmp_member);
			output.writeBytes(tmp_member);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_member_size:int = input.readInt();
			if (byte_member_size > 0) {				this.member = new p_family_member_info;
				var byte_member:ByteArray = new ByteArray;
				input.readBytes(byte_member, 0, byte_member_size);
				this.member.readFromDataOutput(byte_member);
			}
		}
	}
}
