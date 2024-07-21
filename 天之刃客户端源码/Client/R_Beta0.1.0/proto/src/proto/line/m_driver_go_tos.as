package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_driver_go_tos extends Message
	{
		public var id:int = 0;
		public var type:int = 1;
		public function m_driver_go_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_driver_go_tos", m_driver_go_tos);
		}
		public override function getMethodName():String {
			return 'driver_go';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.type = input.readInt();
		}
	}
}
