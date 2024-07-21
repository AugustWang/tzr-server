package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_skill_learn_tos extends Message
	{
		public var skill_id:int = 0;
		public function m_skill_learn_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_skill_learn_tos", m_skill_learn_tos);
		}
		public override function getMethodName():String {
			return 'skill_learn';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skill_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skill_id = input.readInt();
		}
	}
}
