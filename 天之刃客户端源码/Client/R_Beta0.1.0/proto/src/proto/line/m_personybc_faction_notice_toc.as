package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_faction_notice_toc extends Message
	{
		public var type:int = 0;
		public var last_time:int = 0;
		public function m_personybc_faction_notice_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_faction_notice_toc", m_personybc_faction_notice_toc);
		}
		public override function getMethodName():String {
			return 'personybc_faction_notice';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.last_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.last_time = input.readInt();
		}
	}
}
