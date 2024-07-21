package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_gift_goods extends Message
	{
		public var id:int = 0;
		public var type:int = 0;
		public var typeid:int = 0;
		public var bind:Boolean = true;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public var num:int = 0;
		public var rate:int = 0;
		public var color:int = 0;
		public function p_gift_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_gift_goods", p_gift_goods);
		}
		public override function getMethodName():String {
			return 'gift_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.type);
			output.writeInt(this.typeid);
			output.writeBoolean(this.bind);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
			output.writeInt(this.num);
			output.writeInt(this.rate);
			output.writeInt(this.color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.type = input.readInt();
			this.typeid = input.readInt();
			this.bind = input.readBoolean();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
			this.num = input.readInt();
			this.rate = input.readInt();
			this.color = input.readInt();
		}
	}
}
