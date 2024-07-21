package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_upgrade_toc extends Message
	{
		public var roleid:int = 0;
		public var oldlevel:int = 0;
		public var newlevel:int = 0;
		public function m_friend_upgrade_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_upgrade_toc", m_friend_upgrade_toc);
		}
		public override function getMethodName():String {
			return 'friend_upgrade';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			output.writeInt(this.oldlevel);
			output.writeInt(this.newlevel);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.oldlevel = input.readInt();
			this.newlevel = input.readInt();
		}
	}
}
