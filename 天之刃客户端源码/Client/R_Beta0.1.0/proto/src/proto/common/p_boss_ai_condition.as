package proto.common {
	import proto.common.p_boss_ai_skill;
	import proto.common.p_monster_talk;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_boss_ai_condition extends Message
	{
		public var condition_id:int = 0;
		public var rate:int = 0;
		public var parm:int = 0;
		public var total_weight:int = 0;
		public var skills:Array = new Array;
		public var timeout:int = 0;
		public var talks:Array = new Array;
		public function p_boss_ai_condition() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_boss_ai_condition", p_boss_ai_condition);
		}
		public override function getMethodName():String {
			return 'boss_ai_condi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.condition_id);
			output.writeInt(this.rate);
			output.writeInt(this.parm);
			output.writeInt(this.total_weight);
			var size_skills:int = this.skills.length;
			output.writeShort(size_skills);
			var temp_repeated_byte_skills:ByteArray= new ByteArray;
			for(i=0; i<size_skills; i++) {
				var t2_skills:ByteArray = new ByteArray;
				var tVo_skills:p_boss_ai_skill = this.skills[i] as p_boss_ai_skill;
				tVo_skills.writeToDataOutput(t2_skills);
				var len_tVo_skills:int = t2_skills.length;
				temp_repeated_byte_skills.writeInt(len_tVo_skills);
				temp_repeated_byte_skills.writeBytes(t2_skills);
			}
			output.writeInt(temp_repeated_byte_skills.length);
			output.writeBytes(temp_repeated_byte_skills);
			output.writeInt(this.timeout);
			var size_talks:int = this.talks.length;
			output.writeShort(size_talks);
			var temp_repeated_byte_talks:ByteArray= new ByteArray;
			for(i=0; i<size_talks; i++) {
				var t2_talks:ByteArray = new ByteArray;
				var tVo_talks:p_monster_talk = this.talks[i] as p_monster_talk;
				tVo_talks.writeToDataOutput(t2_talks);
				var len_tVo_talks:int = t2_talks.length;
				temp_repeated_byte_talks.writeInt(len_tVo_talks);
				temp_repeated_byte_talks.writeBytes(t2_talks);
			}
			output.writeInt(temp_repeated_byte_talks.length);
			output.writeBytes(temp_repeated_byte_talks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.condition_id = input.readInt();
			this.rate = input.readInt();
			this.parm = input.readInt();
			this.total_weight = input.readInt();
			var size_skills:int = input.readShort();
			var length_skills:int = input.readInt();
			if (length_skills > 0) {
				var byte_skills:ByteArray = new ByteArray; 
				input.readBytes(byte_skills, 0, length_skills);
				for(i=0; i<size_skills; i++) {
					var tmp_skills:p_boss_ai_skill = new p_boss_ai_skill;
					var tmp_skills_length:int = byte_skills.readInt();
					var tmp_skills_byte:ByteArray = new ByteArray;
					byte_skills.readBytes(tmp_skills_byte, 0, tmp_skills_length);
					tmp_skills.readFromDataOutput(tmp_skills_byte);
					this.skills.push(tmp_skills);
				}
			}
			this.timeout = input.readInt();
			var size_talks:int = input.readShort();
			var length_talks:int = input.readInt();
			if (length_talks > 0) {
				var byte_talks:ByteArray = new ByteArray; 
				input.readBytes(byte_talks, 0, length_talks);
				for(i=0; i<size_talks; i++) {
					var tmp_talks:p_monster_talk = new p_monster_talk;
					var tmp_talks_length:int = byte_talks.readInt();
					var tmp_talks_byte:ByteArray = new ByteArray;
					byte_talks.readBytes(tmp_talks_byte, 0, tmp_talks_length);
					tmp_talks.readFromDataOutput(tmp_talks_byte);
					this.talks.push(tmp_talks);
				}
			}
		}
	}
}
