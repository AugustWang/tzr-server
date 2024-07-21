package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_monster_skill extends Message
	{
		public var skillid:int = 0;
		public var level:int = 0;
		public function p_monster_skill() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_monster_skill", p_monster_skill);
		}
		public override function getMethodName():String {
			return 'monster_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skillid);
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skillid = input.readInt();
			this.level = input.readInt();
		}
	}
}
