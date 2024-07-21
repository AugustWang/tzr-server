package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_expel_moral_value_tos extends Message
	{
		public var roleid:int = 0;
		public function m_educate_get_expel_moral_value_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_expel_moral_value_tos", m_educate_get_expel_moral_value_tos);
		}
		public override function getMethodName():String {
			return 'educate_get_expel_moral_value';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
		}
	}
}
