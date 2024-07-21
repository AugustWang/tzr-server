package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_convene_tos extends Message
	{
		public var convene_type:int = 0;
		public function m_waroffaction_convene_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_convene_tos", m_waroffaction_convene_tos);
		}
		public override function getMethodName():String {
			return 'waroffaction_convene';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.convene_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.convene_type = input.readInt();
		}
	}
}
