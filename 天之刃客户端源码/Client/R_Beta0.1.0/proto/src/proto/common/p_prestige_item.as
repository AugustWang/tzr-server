package proto.common {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_prestige_item extends Message
	{
		public var group_id:int = 0;
		public var class_id:int = 0;
		public var key:int = 0;
		public var need_prestige:int = 0;
		public var min_level:int = 0;
		public var max_level:int = 0;
		public var item:p_goods = null;
		public function p_prestige_item() {
			super();
			this.item = new p_goods;

			flash.net.registerClassAlias("copy.proto.common.p_prestige_item", p_prestige_item);
		}
		public override function getMethodName():String {
			return 'prestige_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.group_id);
			output.writeInt(this.class_id);
			output.writeInt(this.key);
			output.writeInt(this.need_prestige);
			output.writeInt(this.min_level);
			output.writeInt(this.max_level);
			var tmp_item:ByteArray = new ByteArray;
			this.item.writeToDataOutput(tmp_item);
			var size_tmp_item:int = tmp_item.length;
			output.writeInt(size_tmp_item);
			output.writeBytes(tmp_item);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.group_id = input.readInt();
			this.class_id = input.readInt();
			this.key = input.readInt();
			this.need_prestige = input.readInt();
			this.min_level = input.readInt();
			this.max_level = input.readInt();
			var byte_item_size:int = input.readInt();
			if (byte_item_size > 0) {				this.item = new p_goods;
				var byte_item:ByteArray = new ByteArray;
				input.readBytes(byte_item, 0, byte_item_size);
				this.item.readFromDataOutput(byte_item);
			}
		}
	}
}
