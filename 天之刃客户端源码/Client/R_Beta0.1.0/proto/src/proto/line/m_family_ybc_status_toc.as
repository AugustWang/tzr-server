package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_status_toc extends Message
	{
		public var status:int = 0;
		public function m_family_ybc_status_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_status_toc", m_family_ybc_status_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_status';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.status = input.readInt();
		}
	}
}
