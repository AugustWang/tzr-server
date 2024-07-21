package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_rely_main_toc extends Message
	{
		public var succ:Boolean = true;
		public function m_role2_rely_main_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_rely_main_toc", m_role2_rely_main_toc);
		}
		public override function getMethodName():String {
			return 'role2_rely_main';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
		}
	}
}
