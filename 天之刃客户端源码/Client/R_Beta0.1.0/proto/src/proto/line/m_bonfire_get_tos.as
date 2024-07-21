package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bonfire_get_tos extends Message
	{
		public var bonfire_id:int = 0;
		public function m_bonfire_get_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bonfire_get_tos", m_bonfire_get_tos);
		}
		public override function getMethodName():String {
			return 'bonfire_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bonfire_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bonfire_id = input.readInt();
		}
	}
}
