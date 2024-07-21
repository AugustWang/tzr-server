package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_skill extends Message
	{
		public var skill_id:int = 0;
		public var cur_level:int = 0;
		public function p_role_skill() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_role_skill", p_role_skill);
		}
		public override function getMethodName():String {
			return 'role_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
			output.writeInt(this.cur_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
			this.cur_level = input.readInt();
		}
	}
}
