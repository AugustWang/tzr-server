package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_change_map_tos extends Message
	{
		public var mapid:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public function m_map_change_map_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_change_map_tos", m_map_change_map_tos);
		}
		public override function getMethodName():String {
			return 'map_change_map';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mapid);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mapid = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
		}
	}
}
