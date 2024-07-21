package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_zazen_tos extends Message
	{
		public var status:Boolean = true;
		public function m_role2_zazen_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_zazen_tos", m_role2_zazen_tos);
		}
		public override function getMethodName():String {
			return 'role2_zazen';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.status = input.readBoolean();
		}
	}
}
