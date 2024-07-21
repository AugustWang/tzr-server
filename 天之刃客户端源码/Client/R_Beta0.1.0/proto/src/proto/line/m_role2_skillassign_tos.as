package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_skillassign_tos extends Message
	{
		public var skillid:int = 0;
		public var points:int = 0;
		public function m_role2_skillassign_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_skillassign_tos", m_role2_skillassign_tos);
		}
		public override function getMethodName():String {
			return 'role2_skillassign';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skillid);
			output.writeInt(this.points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skillid = input.readInt();
			this.points = input.readInt();
		}
	}
}
