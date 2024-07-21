package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_refining extends Message
	{
		public var firing_type:int = 0;
		public var goods_id:int = 0;
		public var goods_type:int = 0;
		public var goods_type_id:int = 0;
		public var goods_number:int = 0;
		public function p_refining() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_refining", p_refining);
		}
		public override function getMethodName():String {
			return 'refi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.firing_type);
			output.writeInt(this.goods_id);
			output.writeInt(this.goods_type);
			output.writeInt(this.goods_type_id);
			output.writeInt(this.goods_number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.firing_type = input.readInt();
			this.goods_id = input.readInt();
			this.goods_type = input.readInt();
			this.goods_type_id = input.readInt();
			this.goods_number = input.readInt();
		}
	}
}
