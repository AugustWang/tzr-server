package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_reinforce_equip_tos extends Message
	{
		public var bagid:int = 0;
		public var equipid:int = 0;
		public function m_refining_reinforce_equip_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_reinforce_equip_tos", m_refining_reinforce_equip_tos);
		}
		public override function getMethodName():String {
			return 'refining_reinforce_equip';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bagid);
			output.writeInt(this.equipid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bagid = input.readInt();
			this.equipid = input.readInt();
		}
	}
}
