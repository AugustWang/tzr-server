package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_training_request_tos extends Message
	{
		public var op_type:int = 0;
		public var pet_id:int = 0;
		public var training_hours:int = 0;
		public var training_mode:int = 0;
		public function m_pet_training_request_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_training_request_tos", m_pet_training_request_tos);
		}
		public override function getMethodName():String {
			return 'pet_training_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.pet_id);
			output.writeInt(this.training_hours);
			output.writeInt(this.training_mode);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.pet_id = input.readInt();
			this.training_hours = input.readInt();
			this.training_mode = input.readInt();
		}
	}
}
