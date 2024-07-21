package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_moral_value_to_pkpoint_toc extends Message
	{
		public var succ:Boolean = true;
		public var moral_value:int = 0;
		public var reason:String = "";
		public var pk_point:int = 0;
		public function m_educate_moral_value_to_pkpoint_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_moral_value_to_pkpoint_toc", m_educate_moral_value_to_pkpoint_toc);
		}
		public override function getMethodName():String {
			return 'educate_moral_value_to_pkpoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.moral_value);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pk_point);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.moral_value = input.readInt();
			this.reason = input.readUTF();
			this.pk_point = input.readInt();
		}
	}
}
