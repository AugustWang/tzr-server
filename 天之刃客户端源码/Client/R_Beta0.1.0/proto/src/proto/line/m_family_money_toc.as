package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_money_toc extends Message
	{
		public var new_money:int = 0;
		public function m_family_money_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_money_toc", m_family_money_toc);
		}
		public override function getMethodName():String {
			return 'family_money';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.new_money);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.new_money = input.readInt();
		}
	}
}
