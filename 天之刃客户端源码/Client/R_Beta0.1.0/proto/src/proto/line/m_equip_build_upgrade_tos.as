package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_upgrade_tos extends Message
	{
		public var equip_id:int = 0;
		public var new_type_id:int = 0;
		public var base_type_id:int = 0;
		public var quality_type_id:int = 0;
		public var reinforce_type_id:int = 0;
		public var five_ele_type_id:int = 0;
		public var bind_attr_type_id:int = 0;
		public function m_equip_build_upgrade_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_upgrade_tos", m_equip_build_upgrade_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_upgrade';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equip_id);
			output.writeInt(this.new_type_id);
			output.writeInt(this.base_type_id);
			output.writeInt(this.quality_type_id);
			output.writeInt(this.reinforce_type_id);
			output.writeInt(this.five_ele_type_id);
			output.writeInt(this.bind_attr_type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equip_id = input.readInt();
			this.new_type_id = input.readInt();
			this.base_type_id = input.readInt();
			this.quality_type_id = input.readInt();
			this.reinforce_type_id = input.readInt();
			this.five_ele_type_id = input.readInt();
			this.bind_attr_type_id = input.readInt();
		}
	}
}
