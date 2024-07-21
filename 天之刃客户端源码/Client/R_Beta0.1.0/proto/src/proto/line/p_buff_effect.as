package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_buff_effect extends Message
	{
		public var effect_type:int = 0;
		public var effect_value:int = 0;
		public var buff_type:int = 0;
		public function p_buff_effect() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_buff_effect", p_buff_effect);
		}
		public override function getMethodName():String {
			return 'buff_ef';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.effect_type);
			output.writeInt(this.effect_value);
			output.writeInt(this.buff_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.effect_type = input.readInt();
			this.effect_value = input.readInt();
			this.buff_type = input.readInt();
		}
	}
}
