package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_auto_tos extends Message
	{
		public var type:Boolean = true;
		public function m_personybc_auto_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_auto_tos", m_personybc_auto_tos);
		}
		public override function getMethodName():String {
			return 'personybc_auto';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readBoolean();
		}
	}
}
