package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bonfire_rm_toc extends Message
	{
		public var id:int = 0;
		public function m_bonfire_rm_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bonfire_rm_toc", m_bonfire_rm_toc);
		}
		public override function getMethodName():String {
			return 'bonfire_rm';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
		}
	}
}
