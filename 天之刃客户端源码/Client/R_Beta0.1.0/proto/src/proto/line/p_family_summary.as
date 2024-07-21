package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_summary extends Message
	{
		public var id:int = 0;
		public var name:String = "";
		public var create_role_id:int = 0;
		public var create_role_name:String = "";
		public var owner_role_id:int = 0;
		public var owner_role_name:String = "";
		public var cur_members:int = 0;
		public var faction_id:int = 0;
		public var level:int = 0;
		public var active_points:int = 0;
		public function p_family_summary() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_family_summary", p_family_summary);
		}
		public override function getMethodName():String {
			return 'family_sum';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.create_role_id);
			if (this.create_role_name != null) {				output.writeUTF(this.create_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.owner_role_id);
			if (this.owner_role_name != null) {				output.writeUTF(this.owner_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.cur_members);
			output.writeInt(this.faction_id);
			output.writeInt(this.level);
			output.writeInt(this.active_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readUTF();
			this.create_role_id = input.readInt();
			this.create_role_name = input.readUTF();
			this.owner_role_id = input.readInt();
			this.owner_role_name = input.readUTF();
			this.cur_members = input.readInt();
			this.faction_id = input.readInt();
			this.level = input.readInt();
			this.active_points = input.readInt();
		}
	}
}
