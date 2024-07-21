package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_skilllearn_tos extends Message
	{
		public var skillid:int = 0;
		public function m_role2_skilllearn_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_skilllearn_tos", m_role2_skilllearn_tos);
		}
		public override function getMethodName():String {
			return 'role2_skilllearn';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skillid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skillid = input.readInt();
		}
	}
}
