package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_getgift_tos extends Message
	{
		public var type:int = 0;
		public var id:int = 0;
		public function m_activity_getgift_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_getgift_tos", m_activity_getgift_tos);
		}
		public override function getMethodName():String {
			return 'activity_getgift';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.id = input.readInt();
		}
	}
}
