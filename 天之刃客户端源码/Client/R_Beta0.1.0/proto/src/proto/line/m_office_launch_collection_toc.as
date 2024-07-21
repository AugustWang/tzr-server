package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_launch_collection_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var role_name:String = "";
		public var office_name:String = "";
		public function m_office_launch_collection_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_launch_collection_toc", m_office_launch_collection_toc);
		}
		public override function getMethodName():String {
			return 'office_launch_collection';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.role_name = input.readUTF();
			this.office_name = input.readUTF();
		}
	}
}
