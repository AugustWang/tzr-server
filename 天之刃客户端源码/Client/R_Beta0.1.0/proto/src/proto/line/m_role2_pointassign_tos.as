package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_pointassign_tos extends Message
	{
		public var type:int = 0;
		public var value:int = 0;
		public function m_role2_pointassign_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_pointassign_tos", m_role2_pointassign_tos);
		}
		public override function getMethodName():String {
			return 'role2_pointassign';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.value = input.readInt();
		}
	}
}
