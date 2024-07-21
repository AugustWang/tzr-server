package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ybc_speed_toc extends Message
	{
		public var ybc_id:int = 0;
		public var move_speed:int = 0;
		public function m_ybc_speed_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ybc_speed_toc", m_ybc_speed_toc);
		}
		public override function getMethodName():String {
			return 'ybc_speed';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.ybc_id);
			output.writeInt(this.move_speed);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ybc_id = input.readInt();
			this.move_speed = input.readInt();
		}
	}
}
