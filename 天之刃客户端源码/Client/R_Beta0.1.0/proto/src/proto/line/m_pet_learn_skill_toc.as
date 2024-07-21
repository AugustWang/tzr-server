package proto.line {
	import proto.common.p_pet_skill;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_learn_skill_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var succ2:Boolean = true;
		public var pet_id:int = 0;
		public var skills:Array = new Array;
		public function m_pet_learn_skill_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_learn_skill_toc", m_pet_learn_skill_toc);
		}
		public override function getMethodName():String {
			return 'pet_learn_skill';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.succ2);
			output.writeInt(this.pet_id);
			var size_skills:int = this.skills.length;
			output.writeShort(size_skills);
			var temp_repeated_byte_skills:ByteArray= new ByteArray;
			for(i=0; i<size_skills; i++) {
				var t2_skills:ByteArray = new ByteArray;
				var tVo_skills:p_pet_skill = this.skills[i] as p_pet_skill;
				tVo_skills.writeToDataOutput(t2_skills);
				var len_tVo_skills:int = t2_skills.length;
				temp_repeated_byte_skills.writeInt(len_tVo_skills);
				temp_repeated_byte_skills.writeBytes(t2_skills);
			}
			output.writeInt(temp_repeated_byte_skills.length);
			output.writeBytes(temp_repeated_byte_skills);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.succ2 = input.readBoolean();
			this.pet_id = input.readInt();
			var size_skills:int = input.readShort();
			var length_skills:int = input.readInt();
			if (length_skills > 0) {
				var byte_skills:ByteArray = new ByteArray; 
				input.readBytes(byte_skills, 0, length_skills);
				for(i=0; i<size_skills; i++) {
					var tmp_skills:p_pet_skill = new p_pet_skill;
					var tmp_skills_length:int = byte_skills.readInt();
					var tmp_skills_byte:ByteArray = new ByteArray;
					byte_skills.readBytes(tmp_skills_byte, 0, tmp_skills_length);
					tmp_skills.readFromDataOutput(tmp_skills_byte);
					this.skills.push(tmp_skills);
				}
			}
		}
	}
}
