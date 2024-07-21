package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_unload_tos extends Message
	{
		public var equipid:int = 0;
		public var bagid:int = 0;
		public var position:int = 0;
		public function m_equip_unload_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_unload_tos", m_equip_unload_tos);
		}
		public override function getMethodName():String {
			return 'equip_unload';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equipid);
			output.writeInt(this.bagid);
			output.writeInt(this.position);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equipid = input.readInt();
			this.bagid = input.readInt();
			this.position = input.readInt();
		}
	}
}
