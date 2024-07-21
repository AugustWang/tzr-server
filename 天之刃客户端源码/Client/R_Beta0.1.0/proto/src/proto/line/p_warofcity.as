package proto.line {
	import proto.line.p_warofcity_apply_family;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_warofcity extends Message
	{
		public var map_id:int = 0;
		public var family_id:int = 0;
		public var family_name:String = "";
		public var last_day:int = 0;
		public var rewards:Array = new Array;
		public var apply_family_list:Array = new Array;
		public var sum_apply_cost:int = 0;
		public var gained_rewards:Array = new Array;
		public function p_warofcity() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_warofcity", p_warofcity);
		}
		public override function getMethodName():String {
			return 'warof';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.map_id);
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.last_day);
			var size_rewards:int = this.rewards.length;
			output.writeShort(size_rewards);
			var temp_repeated_byte_rewards:ByteArray= new ByteArray;
			for(i=0; i<size_rewards; i++) {
				var t2_rewards:ByteArray = new ByteArray;
				var tVo_rewards:p_warofcity_reward = this.rewards[i] as p_warofcity_reward;
				tVo_rewards.writeToDataOutput(t2_rewards);
				var len_tVo_rewards:int = t2_rewards.length;
				temp_repeated_byte_rewards.writeInt(len_tVo_rewards);
				temp_repeated_byte_rewards.writeBytes(t2_rewards);
			}
			output.writeInt(temp_repeated_byte_rewards.length);
			output.writeBytes(temp_repeated_byte_rewards);
			var size_apply_family_list:int = this.apply_family_list.length;
			output.writeShort(size_apply_family_list);
			var temp_repeated_byte_apply_family_list:ByteArray= new ByteArray;
			for(i=0; i<size_apply_family_list; i++) {
				var t2_apply_family_list:ByteArray = new ByteArray;
				var tVo_apply_family_list:p_warofcity_apply_family = this.apply_family_list[i] as p_warofcity_apply_family;
				tVo_apply_family_list.writeToDataOutput(t2_apply_family_list);
				var len_tVo_apply_family_list:int = t2_apply_family_list.length;
				temp_repeated_byte_apply_family_list.writeInt(len_tVo_apply_family_list);
				temp_repeated_byte_apply_family_list.writeBytes(t2_apply_family_list);
			}
			output.writeInt(temp_repeated_byte_apply_family_list.length);
			output.writeBytes(temp_repeated_byte_apply_family_list);
			output.writeInt(this.sum_apply_cost);
			var size_gained_rewards:int = this.gained_rewards.length;
			output.writeShort(size_gained_rewards);
			var temp_repeated_byte_gained_rewards:ByteArray= new ByteArray;
			for(i=0; i<size_gained_rewards; i++) {
				temp_repeated_byte_gained_rewards.writeInt(this.gained_rewards[i]);
			}
			output.writeInt(temp_repeated_byte_gained_rewards.length);
			output.writeBytes(temp_repeated_byte_gained_rewards);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.map_id = input.readInt();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.last_day = input.readInt();
			var size_rewards:int = input.readShort();
			var length_rewards:int = input.readInt();
			if (length_rewards > 0) {
				var byte_rewards:ByteArray = new ByteArray; 
				input.readBytes(byte_rewards, 0, length_rewards);
				for(i=0; i<size_rewards; i++) {
					var tmp_rewards:p_warofcity_reward = new p_warofcity_reward;
					var tmp_rewards_length:int = byte_rewards.readInt();
					var tmp_rewards_byte:ByteArray = new ByteArray;
					byte_rewards.readBytes(tmp_rewards_byte, 0, tmp_rewards_length);
					tmp_rewards.readFromDataOutput(tmp_rewards_byte);
					this.rewards.push(tmp_rewards);
				}
			}
			var size_apply_family_list:int = input.readShort();
			var length_apply_family_list:int = input.readInt();
			if (length_apply_family_list > 0) {
				var byte_apply_family_list:ByteArray = new ByteArray; 
				input.readBytes(byte_apply_family_list, 0, length_apply_family_list);
				for(i=0; i<size_apply_family_list; i++) {
					var tmp_apply_family_list:p_warofcity_apply_family = new p_warofcity_apply_family;
					var tmp_apply_family_list_length:int = byte_apply_family_list.readInt();
					var tmp_apply_family_list_byte:ByteArray = new ByteArray;
					byte_apply_family_list.readBytes(tmp_apply_family_list_byte, 0, tmp_apply_family_list_length);
					tmp_apply_family_list.readFromDataOutput(tmp_apply_family_list_byte);
					this.apply_family_list.push(tmp_apply_family_list);
				}
			}
			this.sum_apply_cost = input.readInt();
			var size_gained_rewards:int = input.readShort();
			var length_gained_rewards:int = input.readInt();
			var byte_gained_rewards:ByteArray = new ByteArray; 
			if (size_gained_rewards > 0) {
				input.readBytes(byte_gained_rewards, 0, size_gained_rewards * 4);
				for(i=0; i<size_gained_rewards; i++) {
					var tmp_gained_rewards:int = byte_gained_rewards.readInt();
					this.gained_rewards.push(tmp_gained_rewards);
				}
			}
		}
	}
}
