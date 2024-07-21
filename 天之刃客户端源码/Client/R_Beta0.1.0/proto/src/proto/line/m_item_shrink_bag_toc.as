package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_shrink_bag_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var item:p_goods = null;
		public var bagid:int = 0;
		public var rows:int = 0;
		public var columns:int = 0;
		public var grid_number:int = 0;
		public function m_item_shrink_bag_toc() {
			super();
			this.item = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_item_shrink_bag_toc", m_item_shrink_bag_toc);
		}
		public override function getMethodName():String {
			return 'item_shrink_bag';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_item:ByteArray = new ByteArray;
			this.item.writeToDataOutput(tmp_item);
			var size_tmp_item:int = tmp_item.length;
			output.writeInt(size_tmp_item);
			output.writeBytes(tmp_item);
			output.writeInt(this.bagid);
			output.writeInt(this.rows);
			output.writeInt(this.columns);
			output.writeInt(this.grid_number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_item_size:int = input.readInt();
			if (byte_item_size > 0) {				this.item = new p_goods;
				var byte_item:ByteArray = new ByteArray;
				input.readBytes(byte_item, 0, byte_item_size);
				this.item.readFromDataOutput(byte_item);
			}
			this.bagid = input.readInt();
			this.rows = input.readInt();
			this.columns = input.readInt();
			this.grid_number = input.readInt();
		}
	}
}
