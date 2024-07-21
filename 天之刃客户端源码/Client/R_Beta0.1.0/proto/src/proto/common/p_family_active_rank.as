package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_active_rank extends Message
	{
		public var family_id:int = 0;
		public var family_name:String = "";
		public var owner_role_name:String = "";
		public var level:int = 0;
		public var ranking:int = 0;
		public var member_count:int = 0;
		public var active:int = 0;
		public var faction_id:int = 0;
		public function p_family_active_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_active_rank", p_family_active_rank);
		}
		public override function getMethodName():String {
			return 'family_active_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.owner_role_name != null) {				output.writeUTF(this.owner_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeInt(this.ranking);
			output.writeInt(this.member_count);
			output.writeInt(this.active);
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.owner_role_name = input.readUTF();
			this.level = input.readInt();
			this.ranking = input.readInt();
			this.member_count = input.readInt();
			this.active = input.readInt();
			this.faction_id = input.readInt();
		}
	}
}
