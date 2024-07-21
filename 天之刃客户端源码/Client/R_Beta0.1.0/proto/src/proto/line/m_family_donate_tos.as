package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_donate_tos extends Message
	{
		public var donate_type:int = 0;
		public var donate_value:int = 0;
		public function m_family_donate_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_donate_tos", m_family_donate_tos);
		}
		public override function getMethodName():String {
			return 'family_donate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.donate_type);
			output.writeInt(this.donate_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.donate_type = input.readInt();
			this.donate_value = input.readInt();
		}
	}
}
