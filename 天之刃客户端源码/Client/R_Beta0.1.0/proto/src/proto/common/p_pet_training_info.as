package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_training_info extends Message
	{
		public var pet_id:int = 0;
		public var training_start_time:int = 0;
		public var training_end_time:int = 0;
		public var training_mode:int = 1;
		public var fly_cd_end_time:int = 0;
		public var total_get_exp:int = 0;
		public function p_pet_training_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_training_info", p_pet_training_info);
		}
		public override function getMethodName():String {
			return 'pet_training_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			output.writeInt(this.training_start_time);
			output.writeInt(this.training_end_time);
			output.writeInt(this.training_mode);
			output.writeInt(this.fly_cd_end_time);
			output.writeInt(this.total_get_exp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.training_start_time = input.readInt();
			this.training_end_time = input.readInt();
			this.training_mode = input.readInt();
			this.fly_cd_end_time = input.readInt();
			this.total_get_exp = input.readInt();
		}
	}
}
