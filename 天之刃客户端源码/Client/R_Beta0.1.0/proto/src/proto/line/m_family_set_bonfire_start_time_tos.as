package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_set_bonfire_start_time_tos extends Message
	{
		public var hour:int = 0;
		public var minute:int = 0;
		public var seconds:int = 0;
		public function m_family_set_bonfire_start_time_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_set_bonfire_start_time_tos", m_family_set_bonfire_start_time_tos);
		}
		public override function getMethodName():String {
			return 'family_set_bonfire_start_time';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.hour);
			output.writeInt(this.minute);
			output.writeInt(this.seconds);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.hour = input.readInt();
			this.minute = input.readInt();
			this.seconds = input.readInt();
		}
	}
}
