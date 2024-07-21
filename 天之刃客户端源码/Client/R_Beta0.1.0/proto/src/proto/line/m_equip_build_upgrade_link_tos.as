package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_upgrade_link_tos extends Message
	{
		public var equip_id:int = 0;
		public var is_quality:Boolean = false;
		public var is_reinforce:Boolean = false;
		public var is_five_ele:Boolean = false;
		public var is_bind_attr:Boolean = false;
		public function m_equip_build_upgrade_link_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_upgrade_link_tos", m_equip_build_upgrade_link_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_upgrade_link';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equip_id);
			output.writeBoolean(this.is_quality);
			output.writeBoolean(this.is_reinforce);
			output.writeBoolean(this.is_five_ele);
			output.writeBoolean(this.is_bind_attr);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equip_id = input.readInt();
			this.is_quality = input.readBoolean();
			this.is_reinforce = input.readBoolean();
			this.is_five_ele = input.readBoolean();
			this.is_bind_attr = input.readBoolean();
		}
	}
}
