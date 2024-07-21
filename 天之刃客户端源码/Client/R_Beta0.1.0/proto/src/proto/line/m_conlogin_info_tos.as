package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_conlogin_info_tos extends Message
	{
		public var auto:Boolean = true;
		public function m_conlogin_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_conlogin_info_tos", m_conlogin_info_tos);
		}
		public override function getMethodName():String {
			return 'conlogin_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.auto);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.auto = input.readBoolean();
		}
	}
}
