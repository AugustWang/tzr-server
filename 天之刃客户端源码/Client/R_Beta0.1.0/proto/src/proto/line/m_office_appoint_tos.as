package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_appoint_tos extends Message
	{
		public var role_name:String = "";
		public var office_id:int = 0;
		public function m_office_appoint_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_appoint_tos", m_office_appoint_tos);
		}
		public override function getMethodName():String {
			return 'office_appoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.office_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_name = input.readUTF();
			this.office_id = input.readInt();
		}
	}
}
