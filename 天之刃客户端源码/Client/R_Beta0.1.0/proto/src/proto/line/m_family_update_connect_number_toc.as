package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_update_connect_number_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var content:String = "";
		public var type:String = "";
		public function m_family_update_connect_number_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_update_connect_number_toc", m_family_update_connect_number_toc);
		}
		public override function getMethodName():String {
			return 'family_update_connect_number';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
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
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.content = input.readUTF();
			this.type = input.readUTF();
		}
	}
}
