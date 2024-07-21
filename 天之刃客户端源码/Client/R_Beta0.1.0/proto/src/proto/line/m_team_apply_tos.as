package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_apply_tos extends Message
	{
		public var role_id:int = 0;
		public var op_type:int = 0;
		public var apply_id:int = 0;
		public function m_team_apply_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_apply_tos", m_team_apply_tos);
		}
		public override function getMethodName():String {
			return 'team_apply';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.op_type);
			output.writeInt(this.apply_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.op_type = input.readInt();
			this.apply_id = input.readInt();
		}
	}
}
