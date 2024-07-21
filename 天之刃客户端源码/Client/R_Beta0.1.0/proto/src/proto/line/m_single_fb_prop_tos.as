package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_single_fb_prop_tos extends Message
	{
		public var barrier_id:int = 0;
		public function m_single_fb_prop_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_single_fb_prop_tos", m_single_fb_prop_tos);
		}
		public override function getMethodName():String {
			return 'single_fb_prop';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.barrier_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.barrier_id = input.readInt();
		}
	}
}
