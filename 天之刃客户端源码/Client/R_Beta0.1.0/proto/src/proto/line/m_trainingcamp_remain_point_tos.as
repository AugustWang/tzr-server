package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trainingcamp_remain_point_tos extends Message
	{
		public function m_trainingcamp_remain_point_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trainingcamp_remain_point_tos", m_trainingcamp_remain_point_tos);
		}
		public override function getMethodName():String {
			return 'trainingcamp_remain_point';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
