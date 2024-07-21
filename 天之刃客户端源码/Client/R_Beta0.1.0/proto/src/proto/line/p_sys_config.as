package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_sys_config extends Message
	{
		public var scence_vol:int = 30;
		public var game_vol:int = 30;
		public var back_sound:Boolean = false;
		public var game_sound:Boolean = false;
		public var image_quality:int = 2;
		public var private_chat:Boolean = true;
		public var nation_chat:Boolean = true;
		public var family_chat:Boolean = true;
		public var world_chat:Boolean = true;
		public var team_chat:Boolean = true;
		public var center_broadcast:Boolean = true;
		public var skill_effect:Boolean = true;
		public var show_cloth:Boolean = true;
		public var by_find:Boolean = true;
		public var show_title:Boolean = true;
		public var show_family:Boolean = true;
		public var show_name:Boolean = true;
		public var show_faction:Boolean = true;
		public var auto_fight:Boolean = false;
		public var auto_use_hp:Boolean = true;
		public var hp_below:int = 50;
		public var auto_use_mp:Boolean = true;
		public var mp_below:int = 50;
		public var auto_buy:Boolean = false;
		public var auto_return_home:Boolean = false;
		public var auto_pick_equip:Boolean = true;
		public var auto_pick_stone:Boolean = true;
		public var auto_pick_drug:Boolean = true;
		public var auto_pick_other:Boolean = true;
		public var pick_equip_color:Array = new Array;
		public var pick_other_color:Array = new Array;
		public var auto_use_skill:Boolean = true;
		public var skill_list:Array = new Array;
		public var auto_search:Boolean = true;
		public var auto_team:Boolean = true;
		public var auto_accept:Boolean = true;
		public var hook_time:int = 60;
		public var time_level:int = 60;
		public var show_dropgoods_name:Boolean = true;
		public var show_equip_compare:Boolean = true;
		public var by_hp_typeid:int = 10200003;
		public var by_mp_typeid:int = 10200007;
		public var other_faction:Boolean = false;
		public var accept_friend_request:Boolean = true;
		public var pet_auto_use_hp:Boolean = true;
		public var pet_hp_below:int = 50;
		public var pet_by_hp_typeid:int = 12300101;
		public var pet_auto_use_skill:Boolean = true;
		public var use_hp_item_type:int = 1;
		public var use_mp_item_type:int = 1;
		public var use_pet_item_type:int = 1;
		public function p_sys_config() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_sys_config", p_sys_config);
		}
		public override function getMethodName():String {
			return 'sys_co';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.scence_vol);
			output.writeInt(this.game_vol);
			output.writeBoolean(this.back_sound);
			output.writeBoolean(this.game_sound);
			output.writeInt(this.image_quality);
			output.writeBoolean(this.private_chat);
			output.writeBoolean(this.nation_chat);
			output.writeBoolean(this.family_chat);
			output.writeBoolean(this.world_chat);
			output.writeBoolean(this.team_chat);
			output.writeBoolean(this.center_broadcast);
			output.writeBoolean(this.skill_effect);
			output.writeBoolean(this.show_cloth);
			output.writeBoolean(this.by_find);
			output.writeBoolean(this.show_title);
			output.writeBoolean(this.show_family);
			output.writeBoolean(this.show_name);
			output.writeBoolean(this.show_faction);
			output.writeBoolean(this.auto_fight);
			output.writeBoolean(this.auto_use_hp);
			output.writeInt(this.hp_below);
			output.writeBoolean(this.auto_use_mp);
			output.writeInt(this.mp_below);
			output.writeBoolean(this.auto_buy);
			output.writeBoolean(this.auto_return_home);
			output.writeBoolean(this.auto_pick_equip);
			output.writeBoolean(this.auto_pick_stone);
			output.writeBoolean(this.auto_pick_drug);
			output.writeBoolean(this.auto_pick_other);
			var size_pick_equip_color:int = this.pick_equip_color.length;
			output.writeShort(size_pick_equip_color);
			var temp_repeated_byte_pick_equip_color:ByteArray= new ByteArray;
			for(i=0; i<size_pick_equip_color; i++) {
				temp_repeated_byte_pick_equip_color.writeBoolean(this.pick_equip_color[i]);
			}
			output.writeInt(temp_repeated_byte_pick_equip_color.length);
			output.writeBytes(temp_repeated_byte_pick_equip_color);
			var size_pick_other_color:int = this.pick_other_color.length;
			output.writeShort(size_pick_other_color);
			var temp_repeated_byte_pick_other_color:ByteArray= new ByteArray;
			for(i=0; i<size_pick_other_color; i++) {
				temp_repeated_byte_pick_other_color.writeBoolean(this.pick_other_color[i]);
			}
			output.writeInt(temp_repeated_byte_pick_other_color.length);
			output.writeBytes(temp_repeated_byte_pick_other_color);
			output.writeBoolean(this.auto_use_skill);
			var size_skill_list:int = this.skill_list.length;
			output.writeShort(size_skill_list);
			var temp_repeated_byte_skill_list:ByteArray= new ByteArray;
			for(i=0; i<size_skill_list; i++) {
				temp_repeated_byte_skill_list.writeInt(this.skill_list[i]);
			}
			output.writeInt(temp_repeated_byte_skill_list.length);
			output.writeBytes(temp_repeated_byte_skill_list);
			output.writeBoolean(this.auto_search);
			output.writeBoolean(this.auto_team);
			output.writeBoolean(this.auto_accept);
			output.writeInt(this.hook_time);
			output.writeInt(this.time_level);
			output.writeBoolean(this.show_dropgoods_name);
			output.writeBoolean(this.show_equip_compare);
			output.writeInt(this.by_hp_typeid);
			output.writeInt(this.by_mp_typeid);
			output.writeBoolean(this.other_faction);
			output.writeBoolean(this.accept_friend_request);
			output.writeBoolean(this.pet_auto_use_hp);
			output.writeInt(this.pet_hp_below);
			output.writeInt(this.pet_by_hp_typeid);
			output.writeBoolean(this.pet_auto_use_skill);
			output.writeInt(this.use_hp_item_type);
			output.writeInt(this.use_mp_item_type);
			output.writeInt(this.use_pet_item_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.scence_vol = input.readInt();
			this.game_vol = input.readInt();
			this.back_sound = input.readBoolean();
			this.game_sound = input.readBoolean();
			this.image_quality = input.readInt();
			this.private_chat = input.readBoolean();
			this.nation_chat = input.readBoolean();
			this.family_chat = input.readBoolean();
			this.world_chat = input.readBoolean();
			this.team_chat = input.readBoolean();
			this.center_broadcast = input.readBoolean();
			this.skill_effect = input.readBoolean();
			this.show_cloth = input.readBoolean();
			this.by_find = input.readBoolean();
			this.show_title = input.readBoolean();
			this.show_family = input.readBoolean();
			this.show_name = input.readBoolean();
			this.show_faction = input.readBoolean();
			this.auto_fight = input.readBoolean();
			this.auto_use_hp = input.readBoolean();
			this.hp_below = input.readInt();
			this.auto_use_mp = input.readBoolean();
			this.mp_below = input.readInt();
			this.auto_buy = input.readBoolean();
			this.auto_return_home = input.readBoolean();
			this.auto_pick_equip = input.readBoolean();
			this.auto_pick_stone = input.readBoolean();
			this.auto_pick_drug = input.readBoolean();
			this.auto_pick_other = input.readBoolean();
			var size_pick_equip_color:int = input.readShort();
			var length_pick_equip_color:int = input.readInt();
			var byte_pick_equip_color:ByteArray = new ByteArray; 
			if (size_pick_equip_color > 0) {
				input.readBytes(byte_pick_equip_color, 0, size_pick_equip_color);
				for(i=0; i<size_pick_equip_color; i++) {
					var tmp_pick_equip_color:Boolean = byte_pick_equip_color.readBoolean();					this.pick_equip_color.push(tmp_pick_equip_color);
				}
			}
			var size_pick_other_color:int = input.readShort();
			var length_pick_other_color:int = input.readInt();
			var byte_pick_other_color:ByteArray = new ByteArray; 
			if (size_pick_other_color > 0) {
				input.readBytes(byte_pick_other_color, 0, size_pick_other_color);
				for(i=0; i<size_pick_other_color; i++) {
					var tmp_pick_other_color:Boolean = byte_pick_other_color.readBoolean();					this.pick_other_color.push(tmp_pick_other_color);
				}
			}
			this.auto_use_skill = input.readBoolean();
			var size_skill_list:int = input.readShort();
			var length_skill_list:int = input.readInt();
			var byte_skill_list:ByteArray = new ByteArray; 
			if (size_skill_list > 0) {
				input.readBytes(byte_skill_list, 0, size_skill_list * 4);
				for(i=0; i<size_skill_list; i++) {
					var tmp_skill_list:int = byte_skill_list.readInt();
					this.skill_list.push(tmp_skill_list);
				}
			}
			this.auto_search = input.readBoolean();
			this.auto_team = input.readBoolean();
			this.auto_accept = input.readBoolean();
			this.hook_time = input.readInt();
			this.time_level = input.readInt();
			this.show_dropgoods_name = input.readBoolean();
			this.show_equip_compare = input.readBoolean();
			this.by_hp_typeid = input.readInt();
			this.by_mp_typeid = input.readInt();
			this.other_faction = input.readBoolean();
			this.accept_friend_request = input.readBoolean();
			this.pet_auto_use_hp = input.readBoolean();
			this.pet_hp_below = input.readInt();
			this.pet_by_hp_typeid = input.readInt();
			this.pet_auto_use_skill = input.readBoolean();
			this.use_hp_item_type = input.readInt();
			this.use_mp_item_type = input.readInt();
			this.use_pet_item_type = input.readInt();
		}
	}
}
