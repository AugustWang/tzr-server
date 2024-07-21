package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personal_fb_next_level_tos extends Message
	{
		public function m_personal_fb_next_level_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personal_fb_next_level_tos", m_personal_fb_next_level_tos);
		}
		public override function getMethodName():String {
			return 'personal_fb_next_level';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
