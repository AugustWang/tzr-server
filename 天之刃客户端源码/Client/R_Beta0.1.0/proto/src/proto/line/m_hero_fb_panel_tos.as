package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_hero_fb_panel_tos extends Message
	{
		public function m_hero_fb_panel_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_hero_fb_panel_tos", m_hero_fb_panel_tos);
		}
		public override function getMethodName():String {
			return 'hero_fb_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
