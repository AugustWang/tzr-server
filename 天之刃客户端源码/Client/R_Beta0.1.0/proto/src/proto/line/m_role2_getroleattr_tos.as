package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_getroleattr_tos extends Message
	{
		public var role_id:int = 0;
		public var is_check:Boolean = false;
		public function m_role2_getroleattr_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_getroleattr_tos", m_role2_getroleattr_tos);
		}
		public override function getMethodName():String {
			return 'role2_getroleattr';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeBoolean(this.is_check);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.is_check = input.readBoolean();
		}
	}
}
