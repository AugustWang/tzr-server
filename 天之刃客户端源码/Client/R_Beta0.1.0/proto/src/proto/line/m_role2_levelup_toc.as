package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_levelup_toc extends Message
	{
		public var level:int = 0;
		public var attr_points:int = 0;
		public var maxhp:int = 0;
		public var maxmp:int = 0;
		public var msg:String = "";
		public var skill_points:int = 0;
		public var exp:Number = 0;
		public var next_level_exp:Number = 0;
		public var total_add_exp:Number = 0;
		public function m_role2_levelup_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_levelup_toc", m_role2_levelup_toc);
		}
		public override function getMethodName():String {
			return 'role2_levelup';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.level);
			output.writeInt(this.attr_points);
			output.writeInt(this.maxhp);
			output.writeInt(this.maxmp);
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.skill_points);
			output.writeDouble(this.exp);
			output.writeDouble(this.next_level_exp);
			output.writeDouble(this.total_add_exp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.level = input.readInt();
			this.attr_points = input.readInt();
			this.maxhp = input.readInt();
			this.maxmp = input.readInt();
			this.msg = input.readUTF();
			this.skill_points = input.readInt();
			this.exp = input.readDouble();
			this.next_level_exp = input.readDouble();
			this.total_add_exp = input.readDouble();
		}
	}
}
