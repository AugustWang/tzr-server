package proto.line {
	import proto.line.p_friend_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_get_info_toc extends Message
	{
		public var roleinfo:p_friend_info = null;
		public function m_friend_get_info_toc() {
			super();
			this.roleinfo = new p_friend_info;

			flash.net.registerClassAlias("copy.proto.line.m_friend_get_info_toc", m_friend_get_info_toc);
		}
		public override function getMethodName():String {
			return 'friend_get_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_roleinfo:ByteArray = new ByteArray;
			this.roleinfo.writeToDataOutput(tmp_roleinfo);
			var size_tmp_roleinfo:int = tmp_roleinfo.length;
			output.writeInt(size_tmp_roleinfo);
			output.writeBytes(tmp_roleinfo);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_roleinfo_size:int = input.readInt();
			if (byte_roleinfo_size > 0) {				this.roleinfo = new p_friend_info;
				var byte_roleinfo:ByteArray = new ByteArray;
				input.readBytes(byte_roleinfo, 0, byte_roleinfo_size);
				this.roleinfo.readFromDataOutput(byte_roleinfo);
			}
		}
	}
}
