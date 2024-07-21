package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_expel_moral_value_toc extends Message
	{
		public var succ:Boolean = true;
		public var roleid:int = 0;
		public var reason:String = "";
		public var value:int = 0;
		public var name:String = "";
		public function m_educate_get_expel_moral_value_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_expel_moral_value_toc", m_educate_get_expel_moral_value_toc);
		}
		public override function getMethodName():String {
			return 'educate_get_expel_moral_value';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.roleid);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.value);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.roleid = input.readInt();
			this.reason = input.readUTF();
			this.value = input.readInt();
			this.name = input.readUTF();
		}
	}
}
