package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_vip extends Message
	{
		public var role_id:int = 0;
		public var end_time:int = 0;
		public var total_time:int = 0;
		public var vip_level:int = 0;
		public var multi_exp_times:int = 0;
		public var accumulate_exp_times:int = 0;
		public var mission_transfer_times:int = 0;
		public var is_transfer_notice_free:Boolean = true;
		public var is_transfer_notice:Boolean = true;
		public var last_reset_time:int = 0;
		public var is_expire:Boolean = true;
		public var pet_training_times:int = 0;
		public var remote_depot_num:int = 0;
		public function p_role_vip() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_vip", p_role_vip);
		}
		public override function getMethodName():String {
			return 'role';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.end_time);
			output.writeInt(this.total_time);
			output.writeInt(this.vip_level);
			output.writeInt(this.multi_exp_times);
			output.writeInt(this.accumulate_exp_times);
			output.writeInt(this.mission_transfer_times);
			output.writeBoolean(this.is_transfer_notice_free);
			output.writeBoolean(this.is_transfer_notice);
			output.writeInt(this.last_reset_time);
			output.writeBoolean(this.is_expire);
			output.writeInt(this.pet_training_times);
			output.writeInt(this.remote_depot_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.end_time = input.readInt();
			this.total_time = input.readInt();
			this.vip_level = input.readInt();
			this.multi_exp_times = input.readInt();
			this.accumulate_exp_times = input.readInt();
			this.mission_transfer_times = input.readInt();
			this.is_transfer_notice_free = input.readBoolean();
			this.is_transfer_notice = input.readBoolean();
			this.last_reset_time = input.readInt();
			this.is_expire = input.readBoolean();
			this.pet_training_times = input.readInt();
			this.remote_depot_num = input.readInt();
		}
	}
}
