package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmlskill_research_tos extends Message
	{
		public var skill_id:int = 0;
		public function m_fmlskill_research_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmlskill_research_tos", m_fmlskill_research_tos);
		}
		public override function getMethodName():String {
			return 'fmlskill_research';
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
