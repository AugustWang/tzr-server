package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_vs_toc extends Message
	{
		public var version:int = 0;
		public function m_mission_vs_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_vs_toc", m_mission_vs_toc);
		}
		public override function getMethodName():String {
			return 'mission_vs';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.version);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.version = input.readInt();
		}
	}
}
