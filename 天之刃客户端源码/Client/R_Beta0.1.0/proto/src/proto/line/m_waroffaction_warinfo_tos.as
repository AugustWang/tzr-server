package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_warinfo_tos extends Message
	{
		public var faction_id:int = 0;
		public function m_waroffaction_warinfo_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_warinfo_tos", m_waroffaction_warinfo_tos);
		}
		public override function getMethodName():String {
			return 'waroffaction_warinfo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.faction_id = input.readInt();
		}
	}
}
