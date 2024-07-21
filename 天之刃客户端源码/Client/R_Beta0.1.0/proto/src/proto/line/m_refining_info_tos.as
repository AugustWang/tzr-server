package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_info_tos extends Message
	{
		public var id:int = 0;
		public function m_refining_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_info_tos", m_refining_info_tos);
		}
		public override function getMethodName():String {
			return 'refining_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
		}
	}
}
