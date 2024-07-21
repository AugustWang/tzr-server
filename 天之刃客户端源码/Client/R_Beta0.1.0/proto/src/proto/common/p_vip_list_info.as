package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_vip_list_info extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var skin_id:int = 0;
		public var level:int = 0;
		public var faction_id:int = 0;
		public var family_name:String = "";
		public var total_time:int = 0;
		public var is_online:Boolean = true;
		public function p_vip_list_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_vip_list_info", p_vip_list_info);
		}
		public override function getMethodName():String {
			return 'vip_list_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.skin_id);
			output.writeInt(this.level);
			output.writeInt(this.faction_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.total_time);
			output.writeBoolean(this.is_online);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.skin_id = input.readInt();
			this.level = input.readInt();
			this.faction_id = input.readInt();
			this.family_name = input.readUTF();
			this.total_time = input.readInt();
			this.is_online = input.readBoolean();
		}
	}
}
