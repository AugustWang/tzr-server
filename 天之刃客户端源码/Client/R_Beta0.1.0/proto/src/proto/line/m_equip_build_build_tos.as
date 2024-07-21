package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_build_tos extends Message
	{
		public var build_level:int = 1;
		public var equip_type_id:int = 0;
		public var base_type_id:int = 0;
		public var add_type_id:int = 0;
		public function m_equip_build_build_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_build_tos", m_equip_build_build_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_build';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.build_level);
			output.writeInt(this.equip_type_id);
			output.writeInt(this.base_type_id);
			output.writeInt(this.add_type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.build_level = input.readInt();
			this.equip_type_id = input.readInt();
			this.base_type_id = input.readInt();
			this.add_type_id = input.readInt();
		}
	}
}
