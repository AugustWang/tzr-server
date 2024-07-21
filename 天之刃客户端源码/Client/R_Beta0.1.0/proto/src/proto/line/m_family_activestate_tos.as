package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_activestate_tos extends Message
	{
		public var family_id:int = 0;
		public function m_family_activestate_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_activestate_tos", m_family_activestate_tos);
		}
		public override function getMethodName():String {
			return 'family_activestate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
		}
	}
}
