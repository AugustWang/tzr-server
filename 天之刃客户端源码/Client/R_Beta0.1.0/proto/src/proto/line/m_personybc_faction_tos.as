package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_faction_tos extends Message
	{
		public var type:int = 0;
		public var start_h:int = 0;
		public var start_m:int = 0;
		public function m_personybc_faction_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_faction_tos", m_personybc_faction_tos);
		}
		public override function getMethodName():String {
			return 'personybc_faction';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.start_h);
			output.writeInt(this.start_m);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.start_h = input.readInt();
			this.start_m = input.readInt();
		}
	}
}
