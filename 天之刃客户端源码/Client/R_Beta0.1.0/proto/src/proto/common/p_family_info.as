package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_info extends Message
	{
		public var family_id:int = 0;
		public var family_name:String = "";
		public var faction_id:int = 0;
		public var level:int = 0;
		public var create_role_id:int = 0;
		public var create_role_name:String = "";
		public var owner_role_id:int = 0;
		public var owner_role_name:String = "";
		public var second_owners:Array = new Array;
		public var cur_members:int = 0;
		public var active_points:int = 0;
		public var money:int = 0;
		public var request_list:Array = new Array;
		public var invite_list:Array = new Array;
		public var public_notice:String = "";
		public var private_notice:String = "";
		public var members:Array = new Array;
		public var enable_map:Boolean = true;
		public var kill_uplevel_boss:Boolean = true;
		public var uplevel_boss_called:Boolean = true;
		public var gongxun:int = 0;
		public var ybc_status:int = 0;
		public var ybc_begin_time:int = 0;
		public var ybc_role_id_list:Array = new Array;
		public var ybc_type:int = 0;
		public var ybc_creator_id:int = 0;
		public var hour:int = 14;
		public var minute:int = 0;
		public var seconds:int = 0;
		public var interiormanager:int = 0;
		public var leftprotector:int = 0;
		public var rightprotector:int = 0;
		public function p_family_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_info", p_family_info);
		}
		public override function getMethodName():String {
			return 'family_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeInt(this.level);
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
			var size_second_owners:int = this.second_owners.length;
			output.writeShort(size_second_owners);
			var temp_repeated_byte_second_owners:ByteArray= new ByteArray;
			for(i=0; i<size_second_owners; i++) {
				var t2_second_owners:ByteArray = new ByteArray;
				var tVo_second_owners:p_family_second_owner = this.second_owners[i] as p_family_second_owner;
				tVo_second_owners.writeToDataOutput(t2_second_owners);
				var len_tVo_second_owners:int = t2_second_owners.length;
				temp_repeated_byte_second_owners.writeInt(len_tVo_second_owners);
				temp_repeated_byte_second_owners.writeBytes(t2_second_owners);
			}
			output.writeInt(temp_repeated_byte_second_owners.length);
			output.writeBytes(temp_repeated_byte_second_owners);
			output.writeInt(this.cur_members);
			output.writeInt(this.active_points);
			output.writeInt(this.money);
			var size_request_list:int = this.request_list.length;
			output.writeShort(size_request_list);
			var temp_repeated_byte_request_list:ByteArray= new ByteArray;
			for(i=0; i<size_request_list; i++) {
				var t2_request_list:ByteArray = new ByteArray;
				var tVo_request_list:p_family_request = this.request_list[i] as p_family_request;
				tVo_request_list.writeToDataOutput(t2_request_list);
				var len_tVo_request_list:int = t2_request_list.length;
				temp_repeated_byte_request_list.writeInt(len_tVo_request_list);
				temp_repeated_byte_request_list.writeBytes(t2_request_list);
			}
			output.writeInt(temp_repeated_byte_request_list.length);
			output.writeBytes(temp_repeated_byte_request_list);
			var size_invite_list:int = this.invite_list.length;
			output.writeShort(size_invite_list);
			var temp_repeated_byte_invite_list:ByteArray= new ByteArray;
			for(i=0; i<size_invite_list; i++) {
				var t2_invite_list:ByteArray = new ByteArray;
				var tVo_invite_list:p_family_invite = this.invite_list[i] as p_family_invite;
				tVo_invite_list.writeToDataOutput(t2_invite_list);
				var len_tVo_invite_list:int = t2_invite_list.length;
				temp_repeated_byte_invite_list.writeInt(len_tVo_invite_list);
				temp_repeated_byte_invite_list.writeBytes(t2_invite_list);
			}
			output.writeInt(temp_repeated_byte_invite_list.length);
			output.writeBytes(temp_repeated_byte_invite_list);
			if (this.public_notice != null) {				output.writeUTF(this.public_notice.toString());
			} else {
				output.writeUTF("");
			}
			if (this.private_notice != null) {				output.writeUTF(this.private_notice.toString());
			} else {
				output.writeUTF("");
			}
			var size_members:int = this.members.length;
			output.writeShort(size_members);
			var temp_repeated_byte_members:ByteArray= new ByteArray;
			for(i=0; i<size_members; i++) {
				var t2_members:ByteArray = new ByteArray;
				var tVo_members:p_family_member_info = this.members[i] as p_family_member_info;
				tVo_members.writeToDataOutput(t2_members);
				var len_tVo_members:int = t2_members.length;
				temp_repeated_byte_members.writeInt(len_tVo_members);
				temp_repeated_byte_members.writeBytes(t2_members);
			}
			output.writeInt(temp_repeated_byte_members.length);
			output.writeBytes(temp_repeated_byte_members);
			output.writeBoolean(this.enable_map);
			output.writeBoolean(this.kill_uplevel_boss);
			output.writeBoolean(this.uplevel_boss_called);
			output.writeInt(this.gongxun);
			output.writeInt(this.ybc_status);
			output.writeInt(this.ybc_begin_time);
			var size_ybc_role_id_list:int = this.ybc_role_id_list.length;
			output.writeShort(size_ybc_role_id_list);
			var temp_repeated_byte_ybc_role_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_ybc_role_id_list; i++) {
				temp_repeated_byte_ybc_role_id_list.writeInt(this.ybc_role_id_list[i]);
			}
			output.writeInt(temp_repeated_byte_ybc_role_id_list.length);
			output.writeBytes(temp_repeated_byte_ybc_role_id_list);
			output.writeInt(this.ybc_type);
			output.writeInt(this.ybc_creator_id);
			output.writeInt(this.hour);
			output.writeInt(this.minute);
			output.writeInt(this.seconds);
			output.writeInt(this.interiormanager);
			output.writeInt(this.leftprotector);
			output.writeInt(this.rightprotector);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.faction_id = input.readInt();
			this.level = input.readInt();
			this.create_role_id = input.readInt();
			this.create_role_name = input.readUTF();
			this.owner_role_id = input.readInt();
			this.owner_role_name = input.readUTF();
			var size_second_owners:int = input.readShort();
			var length_second_owners:int = input.readInt();
			if (length_second_owners > 0) {
				var byte_second_owners:ByteArray = new ByteArray; 
				input.readBytes(byte_second_owners, 0, length_second_owners);
				for(i=0; i<size_second_owners; i++) {
					var tmp_second_owners:p_family_second_owner = new p_family_second_owner;
					var tmp_second_owners_length:int = byte_second_owners.readInt();
					var tmp_second_owners_byte:ByteArray = new ByteArray;
					byte_second_owners.readBytes(tmp_second_owners_byte, 0, tmp_second_owners_length);
					tmp_second_owners.readFromDataOutput(tmp_second_owners_byte);
					this.second_owners.push(tmp_second_owners);
				}
			}
			this.cur_members = input.readInt();
			this.active_points = input.readInt();
			this.money = input.readInt();
			var size_request_list:int = input.readShort();
			var length_request_list:int = input.readInt();
			if (length_request_list > 0) {
				var byte_request_list:ByteArray = new ByteArray; 
				input.readBytes(byte_request_list, 0, length_request_list);
				for(i=0; i<size_request_list; i++) {
					var tmp_request_list:p_family_request = new p_family_request;
					var tmp_request_list_length:int = byte_request_list.readInt();
					var tmp_request_list_byte:ByteArray = new ByteArray;
					byte_request_list.readBytes(tmp_request_list_byte, 0, tmp_request_list_length);
					tmp_request_list.readFromDataOutput(tmp_request_list_byte);
					this.request_list.push(tmp_request_list);
				}
			}
			var size_invite_list:int = input.readShort();
			var length_invite_list:int = input.readInt();
			if (length_invite_list > 0) {
				var byte_invite_list:ByteArray = new ByteArray; 
				input.readBytes(byte_invite_list, 0, length_invite_list);
				for(i=0; i<size_invite_list; i++) {
					var tmp_invite_list:p_family_invite = new p_family_invite;
					var tmp_invite_list_length:int = byte_invite_list.readInt();
					var tmp_invite_list_byte:ByteArray = new ByteArray;
					byte_invite_list.readBytes(tmp_invite_list_byte, 0, tmp_invite_list_length);
					tmp_invite_list.readFromDataOutput(tmp_invite_list_byte);
					this.invite_list.push(tmp_invite_list);
				}
			}
			this.public_notice = input.readUTF();
			this.private_notice = input.readUTF();
			var size_members:int = input.readShort();
			var length_members:int = input.readInt();
			if (length_members > 0) {
				var byte_members:ByteArray = new ByteArray; 
				input.readBytes(byte_members, 0, length_members);
				for(i=0; i<size_members; i++) {
					var tmp_members:p_family_member_info = new p_family_member_info;
					var tmp_members_length:int = byte_members.readInt();
					var tmp_members_byte:ByteArray = new ByteArray;
					byte_members.readBytes(tmp_members_byte, 0, tmp_members_length);
					tmp_members.readFromDataOutput(tmp_members_byte);
					this.members.push(tmp_members);
				}
			}
			this.enable_map = input.readBoolean();
			this.kill_uplevel_boss = input.readBoolean();
			this.uplevel_boss_called = input.readBoolean();
			this.gongxun = input.readInt();
			this.ybc_status = input.readInt();
			this.ybc_begin_time = input.readInt();
			var size_ybc_role_id_list:int = input.readShort();
			var length_ybc_role_id_list:int = input.readInt();
			var byte_ybc_role_id_list:ByteArray = new ByteArray; 
			if (size_ybc_role_id_list > 0) {
				input.readBytes(byte_ybc_role_id_list, 0, size_ybc_role_id_list * 4);
				for(i=0; i<size_ybc_role_id_list; i++) {
					var tmp_ybc_role_id_list:int = byte_ybc_role_id_list.readInt();
					this.ybc_role_id_list.push(tmp_ybc_role_id_list);
				}
			}
			this.ybc_type = input.readInt();
			this.ybc_creator_id = input.readInt();
			this.hour = input.readInt();
			this.minute = input.readInt();
			this.seconds = input.readInt();
			this.interiormanager = input.readInt();
			this.leftprotector = input.readInt();
			this.rightprotector = input.readInt();
		}
	}
}
