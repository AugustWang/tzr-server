package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_fb_quit_tos extends Message
	{
		public var quit_type:int = 0;
		public function m_mission_fb_quit_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_fb_quit_tos", m_mission_fb_quit_tos);
		}
		public override function getMethodName():String {
			return 'mission_fb_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.quit_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.quit_type = input.readInt();
		}
	}
}
