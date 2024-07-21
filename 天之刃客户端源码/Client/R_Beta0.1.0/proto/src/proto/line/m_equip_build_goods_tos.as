package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_goods_tos extends Message
	{
		public var material:int = 0;
		public function m_equip_build_goods_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_goods_tos", m_equip_build_goods_tos);
		}
		public override function getMethodName():String {
			return 'equip_build_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.material);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.material = input.readInt();
		}
	}
}
