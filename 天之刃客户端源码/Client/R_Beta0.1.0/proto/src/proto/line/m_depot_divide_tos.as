package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_depot_divide_tos extends Message
	{
		public var id:int = 0;
		public var num:int = 0;
		public var bagid:int = 0;
		public var position:int = 0;
		public function m_depot_divide_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_depot_divide_tos", m_depot_divide_tos);
		}
		public override function getMethodName():String {
			return 'depot_divide';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.num);
			output.writeInt(this.bagid);
			output.writeInt(this.position);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.num = input.readInt();
			this.bagid = input.readInt();
			this.position = input.readInt();
		}
	}
}
