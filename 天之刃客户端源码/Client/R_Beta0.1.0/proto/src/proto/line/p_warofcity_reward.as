package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_warofcity_reward extends Message
	{
		public var type:int = 0;
		public var gain:Boolean = true;
		public function p_warofcity_reward() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_warofcity_reward", p_warofcity_reward);
		}
		public override function getMethodName():String {
			return 'warofcity_re';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeBoolean(this.gain);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.gain = input.readBoolean();
		}
	}
}
