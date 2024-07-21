package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_skill extends Message
	{
		public var skill_id:int = 0;
		public var skill_type:int = 0;
		public var skill_level:int = 1;
		public function p_pet_skill() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_skill", p_pet_skill);
		}
		public override function getMethodName():String {
			return 'pet_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
			output.writeInt(this.skill_type);
			output.writeInt(this.skill_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
			this.skill_type = input.readInt();
			this.skill_level = input.readInt();
		}
	}
}
