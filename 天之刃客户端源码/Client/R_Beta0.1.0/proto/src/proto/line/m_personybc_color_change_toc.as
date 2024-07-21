package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_color_change_toc extends Message
	{
		public var color:int = 0;
		public function m_personybc_color_change_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_color_change_toc", m_personybc_color_change_toc);
		}
		public override function getMethodName():String {
			return 'personybc_color_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.color = input.readInt();
		}
	}
}
