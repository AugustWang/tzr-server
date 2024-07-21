package proto.common {
	import proto.common.p_scene_war_fb_role_info;
	import proto.common.p_scene_war_fb_role_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_scene_war_fb_team_info extends Message
	{
		public var teamid:int = 0;
		public var leader:p_scene_war_fb_role_info = null;
		public var members:Array = new Array;
		public var fb_type:int = 0;
		public var fb_level:int = 0;
		public var faction:int = 0;
		public var creator:int = 0;
		public function p_scene_war_fb_team_info() {
			super();
			this.leader = new p_scene_war_fb_role_info;

			flash.net.registerClassAlias("copy.proto.common.p_scene_war_fb_team_info", p_scene_war_fb_team_info);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_team_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.teamid);
			var tmp_leader:ByteArray = new ByteArray;
			this.leader.writeToDataOutput(tmp_leader);
			var size_tmp_leader:int = tmp_leader.length;
			output.writeInt(size_tmp_leader);
			output.writeBytes(tmp_leader);
			var size_members:int = this.members.length;
			output.writeShort(size_members);
			var temp_repeated_byte_members:ByteArray= new ByteArray;
			for(i=0; i<size_members; i++) {
				var t2_members:ByteArray = new ByteArray;
				var tVo_members:p_scene_war_fb_role_info = this.members[i] as p_scene_war_fb_role_info;
				tVo_members.writeToDataOutput(t2_members);
				var len_tVo_members:int = t2_members.length;
				temp_repeated_byte_members.writeInt(len_tVo_members);
				temp_repeated_byte_members.writeBytes(t2_members);
			}
			output.writeInt(temp_repeated_byte_members.length);
			output.writeBytes(temp_repeated_byte_members);
			output.writeInt(this.fb_type);
			output.writeInt(this.fb_level);
			output.writeInt(this.faction);
			output.writeInt(this.creator);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.teamid = input.readInt();
			var byte_leader_size:int = input.readInt();
			if (byte_leader_size > 0) {				this.leader = new p_scene_war_fb_role_info;
				var byte_leader:ByteArray = new ByteArray;
				input.readBytes(byte_leader, 0, byte_leader_size);
				this.leader.readFromDataOutput(byte_leader);
			}
			var size_members:int = input.readShort();
			var length_members:int = input.readInt();
			if (length_members > 0) {
				var byte_members:ByteArray = new ByteArray; 
				input.readBytes(byte_members, 0, length_members);
				for(i=0; i<size_members; i++) {
					var tmp_members:p_scene_war_fb_role_info = new p_scene_war_fb_role_info;
					var tmp_members_length:int = byte_members.readInt();
					var tmp_members_byte:ByteArray = new ByteArray;
					byte_members.readBytes(tmp_members_byte, 0, tmp_members_length);
					tmp_members.readFromDataOutput(tmp_members_byte);
					this.members.push(tmp_members);
				}
			}
			this.fb_type = input.readInt();
			this.fb_level = input.readInt();
			this.faction = input.readInt();
			this.creator = input.readInt();
		}
	}
}
