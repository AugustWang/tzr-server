package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_combine_tos extends Message
	{
		public var confirm:Boolean = true;
		public var request_role_id:int = 0;
		public function m_family_combine_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_combine_tos", m_family_combine_tos);
		}
		public override function getMethodName():String {
			return 'family_combine';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.confirm);
			output.writeInt(this.request_role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.confirm = input.readBoolean();
			this.request_role_id = input.readInt();
		}
	}
}
