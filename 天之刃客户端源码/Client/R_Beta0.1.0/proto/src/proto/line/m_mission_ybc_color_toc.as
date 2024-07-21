package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_ybc_color_toc extends Message
	{
		public var color:int = 0;
		public function m_mission_ybc_color_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_ybc_color_toc", m_mission_ybc_color_toc);
		}
		public override function getMethodName():String {
			return 'mission_ybc_color';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.color = input.readInt();
		}
	}
}
