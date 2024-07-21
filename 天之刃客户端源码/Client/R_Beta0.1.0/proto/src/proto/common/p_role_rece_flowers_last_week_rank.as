package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_rece_flowers_last_week_rank extends Message
	{
		public var role_id:int = 0;
		public var ranking:int = 0;
		public var role_name:String = "";
		public var level:int = 0;
		public var charm:int = 0;
		public var family_id:int = 0;
		public var family_name:String = "";
		public var faction_id:int = 0;
		public var title:String = "";
		public function p_role_rece_flowers_last_week_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_rece_flowers_last_week_rank", p_role_rece_flowers_last_week_rank);
		}
		public override function getMethodName():String {
			return 'role_rece_flowers_last_week_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.ranking);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeInt(this.charm);
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.ranking = input.readInt();
			this.role_name = input.readUTF();
			this.level = input.readInt();
			this.charm = input.readInt();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.faction_id = input.readInt();
			this.title = input.readUTF();
		}
	}
}
