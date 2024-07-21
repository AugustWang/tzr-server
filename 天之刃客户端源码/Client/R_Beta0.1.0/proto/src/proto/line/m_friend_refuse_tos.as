package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_refuse_tos extends Message
	{
		public var name:String = "";
		public function m_friend_refuse_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_refuse_tos", m_friend_refuse_tos);
		}
		public override function getMethodName():String {
			return 'friend_refuse';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.name = input.readUTF();
		}
	}
}
