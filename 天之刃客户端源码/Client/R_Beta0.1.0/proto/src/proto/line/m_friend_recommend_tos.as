package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_recommend_tos extends Message
	{
		public function m_friend_recommend_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_recommend_tos", m_friend_recommend_tos);
		}
		public override function getMethodName():String {
			return 'friend_recommend';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
