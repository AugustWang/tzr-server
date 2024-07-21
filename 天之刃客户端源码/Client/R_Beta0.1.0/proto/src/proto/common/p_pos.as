package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pos extends Message
	{
		public var tx:int = 0;
		public var ty:int = 0;
		public var px:int = 0;
		public var py:int = 0;
		public var dir:int = 0;
		public function p_pos() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pos", p_pos);
		}
		public override function getMethodName():String {
			return '';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.tx);
			output.writeInt(this.ty);
			output.writeInt(this.px);
			output.writeInt(this.py);
			output.writeInt(this.dir);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.tx = input.readInt();
			this.ty = input.readInt();
			this.px = input.readInt();
			this.py = input.readInt();
			this.dir = input.readInt();
		}
	}
}
