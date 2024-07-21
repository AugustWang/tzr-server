package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_plant_show_skill_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var cur_skill_level:int = 0;
		public var cur_proficiency:int = 0;
		public var need_role_level:int = 0;
		public var need_proficiency:int = 0;
		public var need_expr:int = 0;
		public var need_silver:int = 0;
		public function m_plant_show_skill_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_plant_show_skill_toc", m_plant_show_skill_toc);
		}
		public override function getMethodName():String {
			return 'plant_show_skill';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.cur_skill_level);
			output.writeInt(this.cur_proficiency);
			output.writeInt(this.need_role_level);
			output.writeInt(this.need_proficiency);
			output.writeInt(this.need_expr);
			output.writeInt(this.need_silver);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.cur_skill_level = input.readInt();
			this.cur_proficiency = input.readInt();
			this.need_role_level = input.readInt();
			this.need_proficiency = input.readInt();
			this.need_expr = input.readInt();
			this.need_silver = input.readInt();
		}
	}
}
