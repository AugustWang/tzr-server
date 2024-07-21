package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_today_tos extends Message
	{
		public var type:int = 1;
		public function m_activity_today_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_today_tos", m_activity_today_tos);
		}
		public override function getMethodName():String {
			return 'activity_today';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
		}
	}
}
