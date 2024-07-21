package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_member_recommend_tos extends Message
	{
		public function m_team_member_recommend_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_member_recommend_tos", m_team_member_recommend_tos);
		}
		public override function getMethodName():String {
			return 'team_member_recommend';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
