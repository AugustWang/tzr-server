package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_list_tos extends Message
	{
		public var build_level:int = 1;
		public function m_equip_build_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_list_tos", m_equip_build_list_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.build_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.build_level = input.readInt();
		}
	}
}
