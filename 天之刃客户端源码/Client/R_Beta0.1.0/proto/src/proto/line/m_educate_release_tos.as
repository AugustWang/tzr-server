package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_release_tos extends Message
	{
		public var opt:int = 0;
		public var msg:String = "";
		public function m_educate_release_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_release_tos", m_educate_release_tos);
		}
		public override function getMethodName():String {
			return 'educate_release';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.opt);
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.opt = input.readInt();
			this.msg = input.readUTF();
		}
	}
}
