package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_boss_ai_skill extends Message
	{
		public var skill_id:int = 0;
		public var skill_level:int = 0;
		public var weight:int = 0;
		public var parm:int = 0;
		public var reset_attacktime:Boolean = true;
		public function p_boss_ai_skill() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_boss_ai_skill", p_boss_ai_skill);
		}
		public override function getMethodName():String {
			return 'boss_ai_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
			output.writeInt(this.skill_level);
			output.writeInt(this.weight);
			output.writeInt(this.parm);
			output.writeBoolean(this.reset_attacktime);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
			this.skill_level = input.readInt();
			this.weight = input.readInt();
			this.parm = input.readInt();
			this.reset_attacktime = input.readBoolean();
		}
	}
}
