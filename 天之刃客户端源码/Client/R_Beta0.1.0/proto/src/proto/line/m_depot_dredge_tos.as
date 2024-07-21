package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_depot_dredge_tos extends Message
	{
		public var bagid:int = 0;
		public function m_depot_dredge_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_depot_dredge_tos", m_depot_dredge_tos);
		}
		public override function getMethodName():String {
			return 'depot_dredge';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bagid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bagid = input.readInt();
		}
	}
}
