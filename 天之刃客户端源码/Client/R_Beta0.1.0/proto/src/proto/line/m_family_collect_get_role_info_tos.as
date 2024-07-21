package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_collect_get_role_info_tos extends Message
	{
		public var type_id:int = 0;
		public var role_id:int = 0;
		public function m_family_collect_get_role_info_tos() {
			super();
			
			flash.net.registerClassAlias("copy.proto.line.m_family_collect_get_role_info_tos", m_family_collect_get_role_info_tos);
		}
		public override function getMethodName():String {
			return 'family_collect_get_role_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.role_id = input.readInt();
		}
	}
}
