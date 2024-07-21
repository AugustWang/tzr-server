package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_ybc_money extends Message
	{
		public var level:int = 0;
		public var common:int = 0;
		public var advance:int = 0;
		public function p_family_ybc_money() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_ybc_money", p_family_ybc_money);
		}
		public override function getMethodName():String {
			return 'family_ybc_m';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.level);
			output.writeInt(this.common);
			output.writeInt(this.advance);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.level = input.readInt();
			this.common = input.readInt();
			this.advance = input.readInt();
		}
	}
}
