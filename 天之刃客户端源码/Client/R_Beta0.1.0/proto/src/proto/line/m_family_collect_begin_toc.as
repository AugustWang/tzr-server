package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_collect_begin_toc extends Message
	{
		public var left_tick:int = 0;
		public function m_family_collect_begin_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_collect_begin_toc", m_family_collect_begin_toc);
		}
		public override function getMethodName():String {
			return 'family_collect_begin';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.left_tick);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.left_tick = input.readInt();
		}
	}
}
