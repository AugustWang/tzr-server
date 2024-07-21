package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_show_cloth_tos extends Message
	{
		public var show_cloth:Boolean = true;
		public function m_role2_show_cloth_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_show_cloth_tos", m_role2_show_cloth_tos);
		}
		public override function getMethodName():String {
			return 'role2_show_cloth';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.show_cloth);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.show_cloth = input.readBoolean();
		}
	}
}
