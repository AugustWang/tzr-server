package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_present_get_tos extends Message
	{
		public var present_id:int = 0;
		public function m_present_get_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_present_get_tos", m_present_get_tos);
		}
		public override function getMethodName():String {
			return 'present_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.present_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.present_id = input.readInt();
		}
	}
}
