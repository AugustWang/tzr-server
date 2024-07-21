package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_mount_renewal_tos extends Message
	{
		public var op_type:int = 0;
		public var mount_id:int = 0;
		public var mount_type_id:int = 0;
		public var mount_pos:int = 0;
		public var renewal_type:int = 0;
		public function m_equip_mount_renewal_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_mount_renewal_tos", m_equip_mount_renewal_tos);
		}
		public override function getMethodName():String {
			return 'equip_mount_renewal';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.mount_id);
			output.writeInt(this.mount_type_id);
			output.writeInt(this.mount_pos);
			output.writeInt(this.renewal_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.mount_id = input.readInt();
			this.mount_type_id = input.readInt();
			this.mount_pos = input.readInt();
			this.renewal_type = input.readInt();
		}
	}
}
