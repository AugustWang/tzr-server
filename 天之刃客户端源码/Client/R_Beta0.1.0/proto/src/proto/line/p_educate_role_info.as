package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_educate_role_info extends Message
	{
		public var roleid:int = 0;
		public var level:int = 0;
		public var sex:int = 0;
		public var title:int = 0;
		public var name:String = "";
		public var moral_values:int = 0;
		public var student_num:int = 0;
		public var student_max_num:int = 0;
		public var exp_gifts1:int = 0;
		public var exp_grfts2:int = 0;
		public var teacher:int = 0;
		public var teacher_name:String = "";
		public var exp_devote1:int = 0;
		public var exp_devote2:int = 0;
		public var online:Boolean = true;
		public var apprentice_level:int = 0;
		public var rel_admissions:Boolean = true;
		public var rel_adm_msg:String = "";
		public var rel_adm_time:int = 0;
		public var rel_apprentice:Boolean = true;
		public var rel_app_msg:String = "";
		public var rel_app_time:int = 0;
		public var relation:int = 0;
		public function p_educate_role_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_educate_role_info", p_educate_role_info);
		}
		public override function getMethodName():String {
			return 'educate_role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			output.writeInt(this.level);
			output.writeInt(this.sex);
			output.writeInt(this.title);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.moral_values);
			output.writeInt(this.student_num);
			output.writeInt(this.student_max_num);
			output.writeInt(this.exp_gifts1);
			output.writeInt(this.exp_grfts2);
			output.writeInt(this.teacher);
			if (this.teacher_name != null) {				output.writeUTF(this.teacher_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.exp_devote1);
			output.writeInt(this.exp_devote2);
			output.writeBoolean(this.online);
			output.writeInt(this.apprentice_level);
			output.writeBoolean(this.rel_admissions);
			if (this.rel_adm_msg != null) {				output.writeUTF(this.rel_adm_msg.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.rel_adm_time);
			output.writeBoolean(this.rel_apprentice);
			if (this.rel_app_msg != null) {				output.writeUTF(this.rel_app_msg.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.rel_app_time);
			output.writeInt(this.relation);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.level = input.readInt();
			this.sex = input.readInt();
			this.title = input.readInt();
			this.name = input.readUTF();
			this.moral_values = input.readInt();
			this.student_num = input.readInt();
			this.student_max_num = input.readInt();
			this.exp_gifts1 = input.readInt();
			this.exp_grfts2 = input.readInt();
			this.teacher = input.readInt();
			this.teacher_name = input.readUTF();
			this.exp_devote1 = input.readInt();
			this.exp_devote2 = input.readInt();
			this.online = input.readBoolean();
			this.apprentice_level = input.readInt();
			this.rel_admissions = input.readBoolean();
			this.rel_adm_msg = input.readUTF();
			this.rel_adm_time = input.readInt();
			this.rel_apprentice = input.readBoolean();
			this.rel_app_msg = input.readUTF();
			this.rel_app_time = input.readInt();
			this.relation = input.readInt();
		}
	}
}
