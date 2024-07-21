package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_pkpoint_rank extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public var family_name:String = "";
		public var ranking:int = 0;
		public var title:String = "";
		public var pk_points:int = 0;
		public function p_role_pkpoint_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_pkpoint_rank", p_role_pkpoint_rank);
		}
		public override function getMethodName():String {
			return 'role_pkpoint_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.ranking);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pk_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
			this.family_name = input.readUTF();
			this.ranking = input.readInt();
			this.title = input.readUTF();
			this.pk_points = input.readInt();
		}
	}
}
