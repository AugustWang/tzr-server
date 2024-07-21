package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_member_enter_map_tos extends Message
	{
		public var call_type:int = 1;
		public function m_family_member_enter_map_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_member_enter_map_tos", m_family_member_enter_map_tos);
		}
		public override function getMethodName():String {
			return 'family_member_enter_map';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.call_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.call_type = input.readInt();
		}
	}
}
