package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_enter_tos extends Message
	{
		public var map_id:int = 0;
		public function m_map_enter_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_enter_tos", m_map_enter_tos);
		}
		public override function getMethodName():String {
			return 'map_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.map_id = input.readInt();
		}
	}
}
