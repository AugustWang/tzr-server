package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_hero_fb_info extends Message
	{
		public var role_id:int = 0;
		public var last_enter_time:int = 0;
		public var today_count:int = 0;
		public var progress:int = 0;
		public var rewards:Array = new Array;
		public var fb_record:Array = new Array;
		public var max_enter_times:int = 0;
		public var buy_count:int = 0;
		public var enter_mapid:int = 0;
		public var enter_pos:p_pos = null;
		public function p_role_hero_fb_info() {
			super();
			this.enter_pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_role_hero_fb_info", p_role_hero_fb_info);
		}
		public override function getMethodName():String {
			return 'role_hero_fb_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.last_enter_time);
			output.writeInt(this.today_count);
			output.writeInt(this.progress);
			var size_rewards:int = this.rewards.length;
			output.writeShort(size_rewards);
			var temp_repeated_byte_rewards:ByteArray= new ByteArray;
			for(i=0; i<size_rewards; i++) {
				temp_repeated_byte_rewards.writeInt(this.rewards[i]);
			}
			output.writeInt(temp_repeated_byte_rewards.length);
			output.writeBytes(temp_repeated_byte_rewards);
			var size_fb_record:int = this.fb_record.length;
			output.writeShort(size_fb_record);
			var temp_repeated_byte_fb_record:ByteArray= new ByteArray;
			for(i=0; i<size_fb_record; i++) {
				var t2_fb_record:ByteArray = new ByteArray;
				var tVo_fb_record:p_hero_fb_barrier = this.fb_record[i] as p_hero_fb_barrier;
				tVo_fb_record.writeToDataOutput(t2_fb_record);
				var len_tVo_fb_record:int = t2_fb_record.length;
				temp_repeated_byte_fb_record.writeInt(len_tVo_fb_record);
				temp_repeated_byte_fb_record.writeBytes(t2_fb_record);
			}
			output.writeInt(temp_repeated_byte_fb_record.length);
			output.writeBytes(temp_repeated_byte_fb_record);
			output.writeInt(this.max_enter_times);
			output.writeInt(this.buy_count);
			output.writeInt(this.enter_mapid);
			var tmp_enter_pos:ByteArray = new ByteArray;
			this.enter_pos.writeToDataOutput(tmp_enter_pos);
			var size_tmp_enter_pos:int = tmp_enter_pos.length;
			output.writeInt(size_tmp_enter_pos);
			output.writeBytes(tmp_enter_pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.last_enter_time = input.readInt();
			this.today_count = input.readInt();
			this.progress = input.readInt();
			var size_rewards:int = input.readShort();
			var length_rewards:int = input.readInt();
			var byte_rewards:ByteArray = new ByteArray; 
			if (size_rewards > 0) {
				input.readBytes(byte_rewards, 0, size_rewards * 4);
				for(i=0; i<size_rewards; i++) {
					var tmp_rewards:int = byte_rewards.readInt();
					this.rewards.push(tmp_rewards);
				}
			}
			var size_fb_record:int = input.readShort();
			var length_fb_record:int = input.readInt();
			if (length_fb_record > 0) {
				var byte_fb_record:ByteArray = new ByteArray; 
				input.readBytes(byte_fb_record, 0, length_fb_record);
				for(i=0; i<size_fb_record; i++) {
					var tmp_fb_record:p_hero_fb_barrier = new p_hero_fb_barrier;
					var tmp_fb_record_length:int = byte_fb_record.readInt();
					var tmp_fb_record_byte:ByteArray = new ByteArray;
					byte_fb_record.readBytes(tmp_fb_record_byte, 0, tmp_fb_record_length);
					tmp_fb_record.readFromDataOutput(tmp_fb_record_byte);
					this.fb_record.push(tmp_fb_record);
				}
			}
			this.max_enter_times = input.readInt();
			this.buy_count = input.readInt();
			this.enter_mapid = input.readInt();
			var byte_enter_pos_size:int = input.readInt();
			if (byte_enter_pos_size > 0) {				this.enter_pos = new p_pos;
				var byte_enter_pos:ByteArray = new ByteArray;
				input.readBytes(byte_enter_pos, 0, byte_enter_pos_size);
				this.enter_pos.readFromDataOutput(byte_enter_pos);
			}
		}
	}
}
