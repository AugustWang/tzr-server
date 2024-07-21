package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vie_world_fb_quit_tos extends Message
	{
		public function m_vie_world_fb_quit_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vie_world_fb_quit_tos", m_vie_world_fb_quit_tos);
		}
		public override function getMethodName():String {
			return 'vie_world_fb_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
