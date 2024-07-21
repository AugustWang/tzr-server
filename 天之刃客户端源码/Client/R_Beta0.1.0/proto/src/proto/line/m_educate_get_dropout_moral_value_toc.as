package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_dropout_moral_value_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var value:int = 0;
		public function m_educate_get_dropout_moral_value_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_dropout_moral_value_toc", m_educate_get_dropout_moral_value_toc);
		}
		public override function getMethodName():String {
			return 'educate_get_dropout_moral_value';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.value = input.readInt();
		}
	}
}
