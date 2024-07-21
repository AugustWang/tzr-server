package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_active_tos extends Message
	{
		public var vip_type:int = 0;
		public function m_vip_active_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vip_active_tos", m_vip_active_tos);
		}
		public override function getMethodName():String {
			return 'vip_active';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.vip_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.vip_type = input.readInt();
		}
	}
}
