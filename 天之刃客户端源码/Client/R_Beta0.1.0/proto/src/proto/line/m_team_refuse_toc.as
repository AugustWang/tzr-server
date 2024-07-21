package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_refuse_toc extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var team_id:int = 0;
		public var type_id:int = 0;
		public function m_team_refuse_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_refuse_toc", m_team_refuse_toc);
		}
		public override function getMethodName():String {
			return 'team_refuse';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.team_id);
			output.writeInt(this.type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.team_id = input.readInt();
			this.type_id = input.readInt();
		}
	}
}
