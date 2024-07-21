package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_panel_tos extends Message
	{
		public var num_per_page:int = 0;
		public function m_family_panel_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_panel_tos", m_family_panel_tos);
		}
		public override function getMethodName():String {
			return 'family_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.num_per_page);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.num_per_page = input.readInt();
		}
	}
}
