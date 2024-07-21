package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_disappoint_tos extends Message
	{
		public var office_id:int = 0;
		public function m_office_disappoint_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_disappoint_tos", m_office_disappoint_tos);
		}
		public override function getMethodName():String {
			return 'office_disappoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.office_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.office_id = input.readInt();
		}
	}
}
