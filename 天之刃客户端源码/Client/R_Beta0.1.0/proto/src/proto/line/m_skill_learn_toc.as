package proto.line {
	import proto.line.p_role_skill;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_skill_learn_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var skill:p_role_skill = null;
		public function m_skill_learn_toc() {
			super();
			this.skill = new p_role_skill;

			flash.net.registerClassAlias("copy.proto.line.m_skill_learn_toc", m_skill_learn_toc);
		}
		public override function getMethodName():String {
			return 'skill_learn';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_skill:ByteArray = new ByteArray;
			this.skill.writeToDataOutput(tmp_skill);
			var size_tmp_skill:int = tmp_skill.length;
			output.writeInt(size_tmp_skill);
			output.writeBytes(tmp_skill);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_skill_size:int = input.readInt();
			if (byte_skill_size > 0) {				this.skill = new p_role_skill;
				var byte_skill:ByteArray = new ByteArray;
				input.readBytes(byte_skill, 0, byte_skill_size);
				this.skill.readFromDataOutput(byte_skill);
			}
		}
	}
}
