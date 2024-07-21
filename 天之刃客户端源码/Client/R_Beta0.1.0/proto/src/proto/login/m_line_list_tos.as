package proto.login {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_line_list_tos extends Message
	{
		public var roleid:int = 0;
		public function m_line_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.login.m_line_list_tos", m_line_list_tos);
		}
		public override function getMethodName():String {
			return 'line_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
		}
	}
}
