package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_declare_tos extends Message
	{
		public var defence_faction_id:int = 0;
		public function m_waroffaction_declare_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_declare_tos", m_waroffaction_declare_tos);
		}
		public override function getMethodName():String {
			return 'waroffaction_declare';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.defence_faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.defence_faction_id = input.readInt();
		}
	}
}
