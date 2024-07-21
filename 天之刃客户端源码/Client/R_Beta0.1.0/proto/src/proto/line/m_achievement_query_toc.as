package proto.line {
	import proto.common.p_achievement_info;
	import proto.common.p_achievement_info;
	import proto.common.p_achievement_stat_info;
	import proto.common.p_achievement_info;
	import proto.common.p_achievement_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_achievement_query_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var op_type:int = 0;
		public var group_id:int = 0;
		public var achieve_ids:Array = new Array;
		public var achievements:Array = new Array;
		public var total_points:int = 0;
		public var lately_achievements:Array = new Array;
		public var stat_info:Array = new Array;
		public var group_achievement:p_achievement_info = null;
		public var rank_achievements:Array = new Array;
		public function m_achievement_query_toc() {
			super();
			this.group_achievement = new p_achievement_info;

			flash.net.registerClassAlias("copy.proto.line.m_achievement_query_toc", m_achievement_query_toc);
		}
		public override function getMethodName():String {
			return 'achievement_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.op_type);
			output.writeInt(this.group_id);
			var size_achieve_ids:int = this.achieve_ids.length;
			output.writeShort(size_achieve_ids);
			var temp_repeated_byte_achieve_ids:ByteArray= new ByteArray;
			for(i=0; i<size_achieve_ids; i++) {
				temp_repeated_byte_achieve_ids.writeInt(this.achieve_ids[i]);
			}
			output.writeInt(temp_repeated_byte_achieve_ids.length);
			output.writeBytes(temp_repeated_byte_achieve_ids);
			var size_achievements:int = this.achievements.length;
			output.writeShort(size_achievements);
			var temp_repeated_byte_achievements:ByteArray= new ByteArray;
			for(i=0; i<size_achievements; i++) {
				var t2_achievements:ByteArray = new ByteArray;
				var tVo_achievements:p_achievement_info = this.achievements[i] as p_achievement_info;
				tVo_achievements.writeToDataOutput(t2_achievements);
				var len_tVo_achievements:int = t2_achievements.length;
				temp_repeated_byte_achievements.writeInt(len_tVo_achievements);
				temp_repeated_byte_achievements.writeBytes(t2_achievements);
			}
			output.writeInt(temp_repeated_byte_achievements.length);
			output.writeBytes(temp_repeated_byte_achievements);
			output.writeInt(this.total_points);
			var size_lately_achievements:int = this.lately_achievements.length;
			output.writeShort(size_lately_achievements);
			var temp_repeated_byte_lately_achievements:ByteArray= new ByteArray;
			for(i=0; i<size_lately_achievements; i++) {
				var t2_lately_achievements:ByteArray = new ByteArray;
				var tVo_lately_achievements:p_achievement_info = this.lately_achievements[i] as p_achievement_info;
				tVo_lately_achievements.writeToDataOutput(t2_lately_achievements);
				var len_tVo_lately_achievements:int = t2_lately_achievements.length;
				temp_repeated_byte_lately_achievements.writeInt(len_tVo_lately_achievements);
				temp_repeated_byte_lately_achievements.writeBytes(t2_lately_achievements);
			}
			output.writeInt(temp_repeated_byte_lately_achievements.length);
			output.writeBytes(temp_repeated_byte_lately_achievements);
			var size_stat_info:int = this.stat_info.length;
			output.writeShort(size_stat_info);
			var temp_repeated_byte_stat_info:ByteArray= new ByteArray;
			for(i=0; i<size_stat_info; i++) {
				var t2_stat_info:ByteArray = new ByteArray;
				var tVo_stat_info:p_achievement_stat_info = this.stat_info[i] as p_achievement_stat_info;
				tVo_stat_info.writeToDataOutput(t2_stat_info);
				var len_tVo_stat_info:int = t2_stat_info.length;
				temp_repeated_byte_stat_info.writeInt(len_tVo_stat_info);
				temp_repeated_byte_stat_info.writeBytes(t2_stat_info);
			}
			output.writeInt(temp_repeated_byte_stat_info.length);
			output.writeBytes(temp_repeated_byte_stat_info);
			var tmp_group_achievement:ByteArray = new ByteArray;
			this.group_achievement.writeToDataOutput(tmp_group_achievement);
			var size_tmp_group_achievement:int = tmp_group_achievement.length;
			output.writeInt(size_tmp_group_achievement);
			output.writeBytes(tmp_group_achievement);
			var size_rank_achievements:int = this.rank_achievements.length;
			output.writeShort(size_rank_achievements);
			var temp_repeated_byte_rank_achievements:ByteArray= new ByteArray;
			for(i=0; i<size_rank_achievements; i++) {
				var t2_rank_achievements:ByteArray = new ByteArray;
				var tVo_rank_achievements:p_achievement_info = this.rank_achievements[i] as p_achievement_info;
				tVo_rank_achievements.writeToDataOutput(t2_rank_achievements);
				var len_tVo_rank_achievements:int = t2_rank_achievements.length;
				temp_repeated_byte_rank_achievements.writeInt(len_tVo_rank_achievements);
				temp_repeated_byte_rank_achievements.writeBytes(t2_rank_achievements);
			}
			output.writeInt(temp_repeated_byte_rank_achievements.length);
			output.writeBytes(temp_repeated_byte_rank_achievements);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.op_type = input.readInt();
			this.group_id = input.readInt();
			var size_achieve_ids:int = input.readShort();
			var length_achieve_ids:int = input.readInt();
			var byte_achieve_ids:ByteArray = new ByteArray; 
			if (size_achieve_ids > 0) {
				input.readBytes(byte_achieve_ids, 0, size_achieve_ids * 4);
				for(i=0; i<size_achieve_ids; i++) {
					var tmp_achieve_ids:int = byte_achieve_ids.readInt();
					this.achieve_ids.push(tmp_achieve_ids);
				}
			}
			var size_achievements:int = input.readShort();
			var length_achievements:int = input.readInt();
			if (length_achievements > 0) {
				var byte_achievements:ByteArray = new ByteArray; 
				input.readBytes(byte_achievements, 0, length_achievements);
				for(i=0; i<size_achievements; i++) {
					var tmp_achievements:p_achievement_info = new p_achievement_info;
					var tmp_achievements_length:int = byte_achievements.readInt();
					var tmp_achievements_byte:ByteArray = new ByteArray;
					byte_achievements.readBytes(tmp_achievements_byte, 0, tmp_achievements_length);
					tmp_achievements.readFromDataOutput(tmp_achievements_byte);
					this.achievements.push(tmp_achievements);
				}
			}
			this.total_points = input.readInt();
			var size_lately_achievements:int = input.readShort();
			var length_lately_achievements:int = input.readInt();
			if (length_lately_achievements > 0) {
				var byte_lately_achievements:ByteArray = new ByteArray; 
				input.readBytes(byte_lately_achievements, 0, length_lately_achievements);
				for(i=0; i<size_lately_achievements; i++) {
					var tmp_lately_achievements:p_achievement_info = new p_achievement_info;
					var tmp_lately_achievements_length:int = byte_lately_achievements.readInt();
					var tmp_lately_achievements_byte:ByteArray = new ByteArray;
					byte_lately_achievements.readBytes(tmp_lately_achievements_byte, 0, tmp_lately_achievements_length);
					tmp_lately_achievements.readFromDataOutput(tmp_lately_achievements_byte);
					this.lately_achievements.push(tmp_lately_achievements);
				}
			}
			var size_stat_info:int = input.readShort();
			var length_stat_info:int = input.readInt();
			if (length_stat_info > 0) {
				var byte_stat_info:ByteArray = new ByteArray; 
				input.readBytes(byte_stat_info, 0, length_stat_info);
				for(i=0; i<size_stat_info; i++) {
					var tmp_stat_info:p_achievement_stat_info = new p_achievement_stat_info;
					var tmp_stat_info_length:int = byte_stat_info.readInt();
					var tmp_stat_info_byte:ByteArray = new ByteArray;
					byte_stat_info.readBytes(tmp_stat_info_byte, 0, tmp_stat_info_length);
					tmp_stat_info.readFromDataOutput(tmp_stat_info_byte);
					this.stat_info.push(tmp_stat_info);
				}
			}
			var byte_group_achievement_size:int = input.readInt();
			if (byte_group_achievement_size > 0) {				this.group_achievement = new p_achievement_info;
				var byte_group_achievement:ByteArray = new ByteArray;
				input.readBytes(byte_group_achievement, 0, byte_group_achievement_size);
				this.group_achievement.readFromDataOutput(byte_group_achievement);
			}
			var size_rank_achievements:int = input.readShort();
			var length_rank_achievements:int = input.readInt();
			if (length_rank_achievements > 0) {
				var byte_rank_achievements:ByteArray = new ByteArray; 
				input.readBytes(byte_rank_achievements, 0, length_rank_achievements);
				for(i=0; i<size_rank_achievements; i++) {
					var tmp_rank_achievements:p_achievement_info = new p_achievement_info;
					var tmp_rank_achievements_length:int = byte_rank_achievements.readInt();
					var tmp_rank_achievements_byte:ByteArray = new ByteArray;
					byte_rank_achievements.readBytes(tmp_rank_achievements_byte, 0, tmp_rank_achievements_length);
					tmp_rank_achievements.readFromDataOutput(tmp_rank_achievements_byte);
					this.rank_achievements.push(tmp_rank_achievements);
				}
			}
		}
	}
}
