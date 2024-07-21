package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personal_fb_enter_tos extends Message
	{
		public var fb_id:int = 0;
		public function m_personal_fb_enter_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personal_fb_enter_tos", m_personal_fb_enter_tos);
		}
		public override function getMethodName():String {
			return 'personal_fb_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.fb_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.fb_id = input.readInt();
		}
	}
}
