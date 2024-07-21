package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_set_notice_tos extends Message
	{
		public var notice_content:String = "";
		public function m_office_set_notice_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_set_notice_tos", m_office_set_notice_tos);
		}
		public override function getMethodName():String {
			return 'office_set_notice';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.notice_content != null) {				output.writeUTF(this.notice_content.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.notice_content = input.readUTF();
		}
	}
}
