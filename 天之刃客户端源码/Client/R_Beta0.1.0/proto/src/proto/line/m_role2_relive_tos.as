package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_relive_tos extends Message
	{
		public var type:int = 0;
		public function m_role2_relive_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_relive_tos", m_role2_relive_tos);
		}
		public override function getMethodName():String {
			return 'role2_relive';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
		}
	}
}
