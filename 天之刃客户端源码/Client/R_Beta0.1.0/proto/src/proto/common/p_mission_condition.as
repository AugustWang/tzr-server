package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_condition extends Message
	{
		public var role_id:int = 0;
		public var faction:int = 0;
		public var sex:int = 0;
		public var level:int = 0;
		public var job:int = 0;
		public var has_team:Boolean = true;
		public var has_family:Boolean = false;
		public function p_mission_condition() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_mission_condition", p_mission_condition);
		}
		public override function getMethodName():String {
			return 'mission_condi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.faction);
			output.writeInt(this.sex);
			output.writeInt(this.level);
			output.writeInt(this.job);
			output.writeBoolean(this.has_team);
			output.writeBoolean(this.has_family);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.faction = input.readInt();
			this.sex = input.readInt();
			this.level = input.readInt();
			this.job = input.readInt();
			this.has_team = input.readBoolean();
			this.has_family = input.readBoolean();
		}
	}
}
