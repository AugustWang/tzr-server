package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skill_time extends Message
	{
		public var skill_id:int = 0;
		public var last_use_time:int = 0;
		public function p_skill_time() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_skill_time", p_skill_time);
		}
		public override function getMethodName():String {
			return 'skill_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
			output.writeInt(this.last_use_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
			this.last_use_time = input.readInt();
		}
	}
}
