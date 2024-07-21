package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_grow_info extends Message
	{
		public var type:int = 0;
		public var level:int = 1;
		public var need_level:int = 0;
		public var need_silver:int = 0;
		public var add_value:int = 0;
		public var need_tick:int = 0;
		public var cur_add_value:int = 0;
		public function p_grow_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_grow_info", p_grow_info);
		}
		public override function getMethodName():String {
			return 'grow_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.level);
			output.writeInt(this.need_level);
			output.writeInt(this.need_silver);
			output.writeInt(this.add_value);
			output.writeInt(this.need_tick);
			output.writeInt(this.cur_add_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.level = input.readInt();
			this.need_level = input.readInt();
			this.need_silver = input.readInt();
			this.add_value = input.readInt();
			this.need_tick = input.readInt();
			this.cur_add_value = input.readInt();
		}
	}
}
