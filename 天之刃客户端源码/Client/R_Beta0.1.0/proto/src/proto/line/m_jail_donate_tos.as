package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_jail_donate_tos extends Message
	{
		public var gold:int = 0;
		public function m_jail_donate_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_jail_donate_tos", m_jail_donate_tos);
		}
		public override function getMethodName():String {
			return 'jail_donate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.gold);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.gold = input.readInt();
		}
	}
}
