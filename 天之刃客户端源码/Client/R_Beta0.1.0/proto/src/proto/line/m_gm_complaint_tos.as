package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_gm_complaint_tos extends Message
	{
		public var type:int = 0;
		public var title:String = "";
		public var content:String = "";
		public function m_gm_complaint_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_gm_complaint_tos", m_gm_complaint_tos);
		}
		public override function getMethodName():String {
			return 'gm_complaint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.title = input.readUTF();
			this.content = input.readUTF();
		}
	}
}
