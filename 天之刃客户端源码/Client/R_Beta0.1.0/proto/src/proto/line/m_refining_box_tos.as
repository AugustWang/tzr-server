package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_box_tos extends Message
	{
		public var op_type:int = 0;
		public var op_fee_type:int = 0;
		public var goods_ids:Array = new Array;
		public var page_no:int = 0;
		public var page_type:int = 0;
		public function m_refining_box_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_box_tos", m_refining_box_tos);
		}
		public override function getMethodName():String {
			return 'refining_box';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.op_fee_type);
			var size_goods_ids:int = this.goods_ids.length;
			output.writeShort(size_goods_ids);
			var temp_repeated_byte_goods_ids:ByteArray= new ByteArray;
			for(i=0; i<size_goods_ids; i++) {
				temp_repeated_byte_goods_ids.writeInt(this.goods_ids[i]);
			}
			output.writeInt(temp_repeated_byte_goods_ids.length);
			output.writeBytes(temp_repeated_byte_goods_ids);
			output.writeInt(this.page_no);
			output.writeInt(this.page_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.op_fee_type = input.readInt();
			var size_goods_ids:int = input.readShort();
			var length_goods_ids:int = input.readInt();
			var byte_goods_ids:ByteArray = new ByteArray; 
			if (size_goods_ids > 0) {
				input.readBytes(byte_goods_ids, 0, size_goods_ids * 4);
				for(i=0; i<size_goods_ids; i++) {
					var tmp_goods_ids:int = byte_goods_ids.readInt();
					this.goods_ids.push(tmp_goods_ids);
				}
			}
			this.page_no = input.readInt();
			this.page_type = input.readInt();
		}
	}
}
