package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_collect_toc extends Message
	{
		public var map_id:int = 0;
		public function m_warofcity_collect_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_collect_toc", m_warofcity_collect_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_collect';
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
