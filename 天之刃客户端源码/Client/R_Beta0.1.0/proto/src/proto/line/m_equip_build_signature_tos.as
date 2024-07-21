package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_signature_tos extends Message
	{
		public var equip_id:int = 0;
		public function m_equip_build_signature_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_signature_tos", m_equip_build_signature_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_signature';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equip_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equip_id = input.readInt();
		}
	}
}
