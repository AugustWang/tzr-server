package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_compose_tos extends Message
	{
		public var compose_type:int = 0;
		public function m_refining_compose_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_compose_tos", m_refining_compose_tos);
		}
		public override function getMethodName():String {
			return 'refining_compose';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.compose_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.compose_type = input.readInt();
		}
	}
}
