package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_set_fcm_tos extends Message
	{
		public var name:String = "";
		public var card:String = "";
		public function m_system_set_fcm_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_system_set_fcm_tos", m_system_set_fcm_tos);
		}
		public override function getMethodName():String {
			return 'system_set_fcm';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.card != null) {				output.writeUTF(this.card.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.name = input.readUTF();
			this.card = input.readUTF();
		}
	}
}
