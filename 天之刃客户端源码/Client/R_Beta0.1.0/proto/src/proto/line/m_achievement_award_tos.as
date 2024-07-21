package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_achievement_award_tos extends Message
	{
		public var achieve_id:int = 0;
		public function m_achievement_award_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_achievement_award_tos", m_achievement_award_tos);
		}
		public override function getMethodName():String {
			return 'achievement_award';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.achieve_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.achieve_id = input.readInt();
		}
	}
}
