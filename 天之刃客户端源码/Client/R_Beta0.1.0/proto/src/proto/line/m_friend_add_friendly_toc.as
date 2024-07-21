package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_add_friendly_toc extends Message
	{
		public var role_id:int = 0;
		public var friendly:int = 0;
		public function m_friend_add_friendly_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_add_friendly_toc", m_friend_add_friendly_toc);
		}
		public override function getMethodName():String {
			return 'friend_add_friendly';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.friendly);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.friendly = input.readInt();
		}
	}
}
