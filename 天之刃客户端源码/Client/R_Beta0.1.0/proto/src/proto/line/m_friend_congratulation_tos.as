package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_congratulation_tos extends Message
	{
		public var to_friend_id:int = 0;
		public var congratulation:String = "";
		public function m_friend_congratulation_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_congratulation_tos", m_friend_congratulation_tos);
		}
		public override function getMethodName():String {
			return 'friend_congratulation';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.to_friend_id);
			if (this.congratulation != null) {				output.writeUTF(this.congratulation.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.to_friend_id = input.readInt();
			this.congratulation = input.readUTF();
		}
	}
}
