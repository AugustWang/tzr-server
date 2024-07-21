package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_pet_rank extends Message
	{
		public var pet_id:int = 0;
		public var pet_type_name:String = "";
		public var role_id:int = 0;
		public var ranking:int = 0;
		public var role_name:String = "";
		public var level:int = 0;
		public var color:int = 0;
		public var understanding:int = 0;
		public var score:int = 0;
		public var faction_id:int = 0;
		public var title:String = "";
		public function p_role_pet_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_pet_rank", p_role_pet_rank);
		}
		public override function getMethodName():String {
			return 'role_pet_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			if (this.pet_type_name != null) {				output.writeUTF(this.pet_type_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			output.writeInt(this.ranking);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeInt(this.color);
			output.writeInt(this.understanding);
			output.writeInt(this.score);
			output.writeInt(this.faction_id);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.pet_type_name = input.readUTF();
			this.role_id = input.readInt();
			this.ranking = input.readInt();
			this.role_name = input.readUTF();
			this.level = input.readInt();
			this.color = input.readInt();
			this.understanding = input.readInt();
			this.score = input.readInt();
			this.faction_id = input.readInt();
			this.title = input.readUTF();
		}
	}
}
