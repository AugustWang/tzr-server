package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_achievement_info extends Message
	{
		public var achieve_id:int = 0;
		public var status:int = 0;
		public var complete_time:int = 0;
		public var cur_progress:int = 0;
		public var total_progress:int = 0;
		public var points:int = 0;
		public var pop_type:int = 0;
		public var achieve_type:int = 0;
		public var class_id:int = 0;
		public var group_id:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public function p_achievement_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_achievement_info", p_achievement_info);
		}
		public override function getMethodName():String {
			return 'achievement_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.achieve_id);
			output.writeInt(this.status);
			output.writeInt(this.complete_time);
			output.writeInt(this.cur_progress);
			output.writeInt(this.total_progress);
			output.writeInt(this.points);
			output.writeInt(this.pop_type);
			output.writeInt(this.achieve_type);
			output.writeInt(this.class_id);
			output.writeInt(this.group_id);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.achieve_id = input.readInt();
			this.status = input.readInt();
			this.complete_time = input.readInt();
			this.cur_progress = input.readInt();
			this.total_progress = input.readInt();
			this.points = input.readInt();
			this.pop_type = input.readInt();
			this.achieve_type = input.readInt();
			this.class_id = input.readInt();
			this.group_id = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
		}
	}
}
