package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ybc_dead_toc extends Message
	{
		public var ybc_id:int = 0;
		public function m_ybc_dead_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ybc_dead_toc", m_ybc_dead_toc);
		}
		public override function getMethodName():String {
			return 'ybc_dead';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.ybc_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ybc_id = input.readInt();
		}
	}
}
