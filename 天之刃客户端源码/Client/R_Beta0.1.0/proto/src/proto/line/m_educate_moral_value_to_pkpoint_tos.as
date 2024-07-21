package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_moral_value_to_pkpoint_tos extends Message
	{
		public var moral_value:int = 0;
		public function m_educate_moral_value_to_pkpoint_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_moral_value_to_pkpoint_tos", m_educate_moral_value_to_pkpoint_tos);
		}
		public override function getMethodName():String {
			return 'educate_moral_value_to_pkpoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.moral_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.moral_value = input.readInt();
		}
	}
}
