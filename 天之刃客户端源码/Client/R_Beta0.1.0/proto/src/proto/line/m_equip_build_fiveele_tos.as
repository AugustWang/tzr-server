package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_fiveele_tos extends Message
	{
		public var type:int = 0;
		public var equip_id:int = 0;
		public var good_type_id:int = 0;
		public function m_equip_build_fiveele_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_fiveele_tos", m_equip_build_fiveele_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_fiveele';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.equip_id);
			output.writeInt(this.good_type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.equip_id = input.readInt();
			this.good_type_id = input.readInt();
		}
	}
}
