package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_mount_renewal extends Message
	{
		public var type_id:int = 0;
		public var renewal_type:int = 0;
		public var renewal_days:int = 0;
		public var renewal_fee:int = 0;
		public function p_equip_mount_renewal() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_mount_renewal", p_equip_mount_renewal);
		}
		public override function getMethodName():String {
			return 'equip_mount_ren';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			output.writeInt(this.renewal_type);
			output.writeInt(this.renewal_days);
			output.writeInt(this.renewal_fee);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.renewal_type = input.readInt();
			this.renewal_days = input.readInt();
			this.renewal_fee = input.readInt();
		}
	}
}
