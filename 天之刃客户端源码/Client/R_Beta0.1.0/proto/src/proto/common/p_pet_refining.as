package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_refining extends Message
	{
		public var id:int = 0;
		public var exp:Number = 1;
		public function p_pet_refining() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_refining", p_pet_refining);
		}
		public override function getMethodName():String {
			return 'pet_refi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeDouble(this.exp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.exp = input.readDouble();
		}
	}
}
