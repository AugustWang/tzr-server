package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_get_tos extends Message
	{
		public var pack_num:int = 0;
		public function m_letter_get_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_get_tos", m_letter_get_tos);
		}
		public override function getMethodName():String {
			return 'letter_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pack_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pack_num = input.readInt();
		}
	}
}
