package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_effect extends Message
	{
		public var effect_id:int = 0;
		public var effect_type:int = 0;
		public var calc_type:int = 0;
		public var absolute_or_rate:int = 0;
		public var value:int = 0;
		public var value_out_type:int = 0;
		public var probability:int = 100;
		public function p_effect() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_effect", p_effect);
		}
		public override function getMethodName():String {
			return 'ef';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.effect_id);
			output.writeInt(this.effect_type);
			output.writeInt(this.calc_type);
			output.writeInt(this.absolute_or_rate);
			output.writeInt(this.value);
			output.writeInt(this.value_out_type);
			output.writeInt(this.probability);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.effect_id = input.readInt();
			this.effect_type = input.readInt();
			this.calc_type = input.readInt();
			this.absolute_or_rate = input.readInt();
			this.value = input.readInt();
			this.value_out_type = input.readInt();
			this.probability = input.readInt();
		}
	}
}
