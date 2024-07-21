package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_rely_main_tos extends Message
	{
		public var is_rely:Boolean = true;
		public function m_role2_rely_main_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_rely_main_tos", m_role2_rely_main_tos);
		}
		public override function getMethodName():String {
			return 'role2_rely_main';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.is_rely);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.is_rely = input.readBoolean();
		}
	}
}
