package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_accumulate_exp_info extends Message
	{
		public var id:int = 0;
		public var day:int = 0;
		public var exp:Number = 0;
		public var max_exp:Number = 0;
		public var times_per_day:int = 0;
		public var need_gold:int = 0;
		public var status:int = 0;
		public var next_exp:Number = 0;
		public var rate:int = 0;
		public function p_accumulate_exp_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_accumulate_exp_info", p_accumulate_exp_info);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.day);
			output.writeDouble(this.exp);
			output.writeDouble(this.max_exp);
			output.writeInt(this.times_per_day);
			output.writeInt(this.need_gold);
			output.writeInt(this.status);
			output.writeDouble(this.next_exp);
			output.writeInt(this.rate);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.day = input.readInt();
			this.exp = input.readDouble();
			this.max_exp = input.readDouble();
			this.times_per_day = input.readInt();
			this.need_gold = input.readInt();
			this.status = input.readInt();
			this.next_exp = input.readDouble();
			this.rate = input.readInt();
		}
	}
}
