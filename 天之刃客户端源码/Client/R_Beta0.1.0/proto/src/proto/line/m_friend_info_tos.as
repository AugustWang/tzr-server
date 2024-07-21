package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_info_tos extends Message
	{
		public var roleid:int = 0;
		public function m_friend_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_info_tos", m_friend_info_tos);
		}
		public override function getMethodName():String {
			return 'friend_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
		}
	}
}
