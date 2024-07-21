package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect_goods extends Message
	{
		public var goods_type:int = 0;
		public var goods_typeid:int = 0;
		public var goods_start_time:int = 0;
		public var goods_end_time:int = 0;
		public var goods_num:int = 0;
		public var goods_bind:Boolean = true;
		public var rate:int = 0;
		public var is_broadcast:int = 0;
		public function p_collect_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_collect_goods", p_collect_goods);
		}
		public override function getMethodName():String {
			return 'collect_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_type);
			output.writeInt(this.goods_typeid);
			output.writeInt(this.goods_start_time);
			output.writeInt(this.goods_end_time);
			output.writeInt(this.goods_num);
			output.writeBoolean(this.goods_bind);
			output.writeInt(this.rate);
			output.writeInt(this.is_broadcast);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_type = input.readInt();
			this.goods_typeid = input.readInt();
			this.goods_start_time = input.readInt();
			this.goods_end_time = input.readInt();
			this.goods_num = input.readInt();
			this.goods_bind = input.readBoolean();
			this.rate = input.readInt();
			this.is_broadcast = input.readInt();
		}
	}
}
