package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personal_fb_lost_toc extends Message
	{
		public function m_personal_fb_lost_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personal_fb_lost_toc", m_personal_fb_lost_toc);
		}
		public override function getMethodName():String {
			return 'personal_fb_lost';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
