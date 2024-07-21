package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skill_pos extends Message
	{
		public var pos:int = 0;
		public var skill_id:int = 0;
		public function p_skill_pos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_skill_pos", p_skill_pos);
		}
		public override function getMethodName():String {
			return 'skill';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pos);
			output.writeInt(this.skill_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pos = input.readInt();
			this.skill_id = input.readInt();
		}
	}
}
