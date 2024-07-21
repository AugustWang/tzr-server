package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_donate_tos extends Message
	{
		public var money:int = 0;
		public var donate_type:int = 0;
		public function m_office_donate_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_donate_tos", m_office_donate_tos);
		}
		public override function getMethodName():String {
			return 'office_donate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.money);
			output.writeInt(this.donate_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.money = input.readInt();
			this.donate_type = input.readInt();
		}
	}
}
