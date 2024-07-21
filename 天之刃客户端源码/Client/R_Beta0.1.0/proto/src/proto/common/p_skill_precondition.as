package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skill_precondition extends Message
	{
		public var skill_id:int = 0;
		public var skill_level:int = 0;
		public function p_skill_precondition() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_skill_precondition", p_skill_precondition);
		}
		public override function getMethodName():String {
			return 'skill_precondi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
			output.writeInt(this.skill_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
			this.skill_level = input.readInt();
		}
	}
}
