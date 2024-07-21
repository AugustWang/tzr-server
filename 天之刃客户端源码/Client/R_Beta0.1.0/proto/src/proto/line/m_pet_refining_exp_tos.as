package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_refining_exp_tos extends Message
	{
		public var pet_id:int = 0;
		public function m_pet_refining_exp_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_refining_exp_tos", m_pet_refining_exp_tos);
		}
		public override function getMethodName():String {
			return 'pet_refining_exp';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
		}
	}
}
