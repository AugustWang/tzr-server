package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_callmember_tos extends Message
	{
		public var message:String = "";
		public function m_family_callmember_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_callmember_tos", m_family_callmember_tos);
		}
		public override function getMethodName():String {
			return 'family_callmember';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.message = input.readUTF();
		}
	}
}
