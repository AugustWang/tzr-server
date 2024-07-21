package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_team_nearby extends Message
	{
		public var team_id:int = 0;
		public var cur_team_number:int = 0;
		public var sum_team_number:int = 0;
		public var role_id:int = 0;
		public var sex:int = 0;
		public var faction_id:int = 0;
		public var level:int = 0;
		public var category:int = 0;
		public var skinid:int = 0;
		public var role_name:String = "";
		public var auto_accept_team:Boolean = true;
		public function p_team_nearby() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_team_nearby", p_team_nearby);
		}
		public override function getMethodName():String {
			return 'team_ne';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.team_id);
			output.writeInt(this.cur_team_number);
			output.writeInt(this.sum_team_number);
			output.writeInt(this.role_id);
			output.writeInt(this.sex);
			output.writeInt(this.faction_id);
			output.writeInt(this.level);
			output.writeInt(this.category);
			output.writeInt(this.skinid);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.auto_accept_team);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.team_id = input.readInt();
			this.cur_team_number = input.readInt();
			this.sum_team_number = input.readInt();
			this.role_id = input.readInt();
			this.sex = input.readInt();
			this.faction_id = input.readInt();
			this.level = input.readInt();
			this.category = input.readInt();
			this.skinid = input.readInt();
			this.role_name = input.readUTF();
			this.auto_accept_team = input.readBoolean();
		}
	}
}
