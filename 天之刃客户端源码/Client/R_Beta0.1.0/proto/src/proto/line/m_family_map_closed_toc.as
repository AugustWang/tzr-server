package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_map_closed_toc extends Message
	{
		public function m_family_map_closed_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_map_closed_toc", m_family_map_closed_toc);
		}
		public override function getMethodName():String {
			return 'family_map_closed';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
