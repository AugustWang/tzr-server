package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_divide_tos extends Message
	{
		public var id:int = 0;
		public var num:int = 0;
		public var bagposition:int = 0;
		public var bagid:int = 0;
		public function m_refining_divide_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_divide_tos", m_refining_divide_tos);
		}
		public override function getMethodName():String {
			return 'refining_divide';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.num);
			output.writeInt(this.bagposition);
			output.writeInt(this.bagid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.num = input.readInt();
			this.bagposition = input.readInt();
			this.bagid = input.readInt();
		}
	}
}
