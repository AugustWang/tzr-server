package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_update_connect_number_tos extends Message
	{
		public var content:String = "";
		public var type:String = "";
		public function m_family_update_connect_number_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_update_connect_number_tos", m_family_update_connect_number_tos);
		}
		public override function getMethodName():String {
			return 'family_update_connect_number';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			if (this.type != null) {				output.writeUTF(this.type.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.content = input.readUTF();
			this.type = input.readUTF();
		}
	}
}
