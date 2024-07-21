package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_list_tos extends Message
	{
		public var page_id:int = 0;
		public function m_vip_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vip_list_tos", m_vip_list_tos);
		}
		public override function getMethodName():String {
			return 'vip_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.page_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.page_id = input.readInt();
		}
	}
}
