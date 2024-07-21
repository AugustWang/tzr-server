package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_timer_toc extends Message
	{
		public var remain_time:int = 0;
		public function m_personybc_timer_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_timer_toc", m_personybc_timer_toc);
		}
		public override function getMethodName():String {
			return 'personybc_timer';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.remain_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.remain_time = input.readInt();
		}
	}
}
