package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_personybc_award_attr extends Message
	{
		public var color:int = 0;
		public var attr_type:int = 0;
		public var attr_num:int = 0;
		public function p_personybc_award_attr() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_personybc_award_attr", p_personybc_award_attr);
		}
		public override function getMethodName():String {
			return 'personybc_award_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.color);
			output.writeInt(this.attr_type);
			output.writeInt(this.attr_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.color = input.readInt();
			this.attr_type = input.readInt();
			this.attr_num = input.readInt();
		}
	}
}
