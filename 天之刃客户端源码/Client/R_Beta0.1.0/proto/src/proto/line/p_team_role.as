package proto.line {
	import proto.common.p_skin;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_team_role extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var sex:int = 0;
		public var skin:p_skin = null;
		public var map_id:int = 0;
		public var map_name:String = "";
		public var tx:int = 0;
		public var ty:int = 0;
		public var hp:int = 0;
		public var mp:int = 0;
		public var max_hp:int = 0;
		public var max_mp:int = 0;
		public var level:int = 0;
		public var is_leader:Boolean = false;
		public var is_follow:Boolean = false;
		public var is_offline:Boolean = false;
		public var offline_time:int = 0;
		public var five_ele_attr:int = 0;
		public var five_ele_attr_level:int = 0;
		public var add_hp:int = 0;
		public var add_mp:int = 0;
		public var add_phy_attack:int = 0;
		public var add_magic_attack:int = 0;
		public var category:int = 0;
		public var faction_id:int = 0;
		public function p_team_role() {
			super();
			this.skin = new p_skin;

			flash.net.registerClassAlias("copy.proto.line.p_team_role", p_team_role);
		}
		public override function getMethodName():String {
			return 'team_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			var tmp_skin:ByteArray = new ByteArray;
			this.skin.writeToDataOutput(tmp_skin);
			var size_tmp_skin:int = tmp_skin.length;
			output.writeInt(size_tmp_skin);
			output.writeBytes(tmp_skin);
			output.writeInt(this.map_id);
			if (this.map_name != null) {				output.writeUTF(this.map_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.tx);
			output.writeInt(this.ty);
			output.writeInt(this.hp);
			output.writeInt(this.mp);
			output.writeInt(this.max_hp);
			output.writeInt(this.max_mp);
			output.writeInt(this.level);
			output.writeBoolean(this.is_leader);
			output.writeBoolean(this.is_follow);
			output.writeBoolean(this.is_offline);
			output.writeInt(this.offline_time);
			output.writeInt(this.five_ele_attr);
			output.writeInt(this.five_ele_attr_level);
			output.writeInt(this.add_hp);
			output.writeInt(this.add_mp);
			output.writeInt(this.add_phy_attack);
			output.writeInt(this.add_magic_attack);
			output.writeInt(this.category);
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.sex = input.readInt();
			var byte_skin_size:int = input.readInt();
			if (byte_skin_size > 0) {				this.skin = new p_skin;
				var byte_skin:ByteArray = new ByteArray;
				input.readBytes(byte_skin, 0, byte_skin_size);
				this.skin.readFromDataOutput(byte_skin);
			}
			this.map_id = input.readInt();
			this.map_name = input.readUTF();
			this.tx = input.readInt();
			this.ty = input.readInt();
			this.hp = input.readInt();
			this.mp = input.readInt();
			this.max_hp = input.readInt();
			this.max_mp = input.readInt();
			this.level = input.readInt();
			this.is_leader = input.readBoolean();
			this.is_follow = input.readBoolean();
			this.is_offline = input.readBoolean();
			this.offline_time = input.readInt();
			this.five_ele_attr = input.readInt();
			this.five_ele_attr_level = input.readInt();
			this.add_hp = input.readInt();
			this.add_mp = input.readInt();
			this.add_phy_attack = input.readInt();
			this.add_magic_attack = input.readInt();
			this.category = input.readInt();
			this.faction_id = input.readInt();
		}
	}
}
