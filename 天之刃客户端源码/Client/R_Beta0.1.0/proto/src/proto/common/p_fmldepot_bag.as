package proto.common {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_fmldepot_bag extends Message
	{
		public var bag_id:int = 0;
		public var goods_list:Array = new Array;
		public function p_fmldepot_bag() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_fmldepot_bag", p_fmldepot_bag);
		}
		public override function getMethodName():String {
			return 'fmldepot';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bag_id);
			var size_goods_list:int = this.goods_list.length;
			output.writeShort(size_goods_list);
			var temp_repeated_byte_goods_list:ByteArray= new ByteArray;
			for(i=0; i<size_goods_list; i++) {
				var t2_goods_list:ByteArray = new ByteArray;
				var tVo_goods_list:p_goods = this.goods_list[i] as p_goods;
				tVo_goods_list.writeToDataOutput(t2_goods_list);
				var len_tVo_goods_list:int = t2_goods_list.length;
				temp_repeated_byte_goods_list.writeInt(len_tVo_goods_list);
				temp_repeated_byte_goods_list.writeBytes(t2_goods_list);
			}
			output.writeInt(temp_repeated_byte_goods_list.length);
			output.writeBytes(temp_repeated_byte_goods_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bag_id = input.readInt();
			var size_goods_list:int = input.readShort();
			var length_goods_list:int = input.readInt();
			if (length_goods_list > 0) {
				var byte_goods_list:ByteArray = new ByteArray; 
				input.readBytes(byte_goods_list, 0, length_goods_list);
				for(i=0; i<size_goods_list; i++) {
					var tmp_goods_list:p_goods = new p_goods;
					var tmp_goods_list_length:int = byte_goods_list.readInt();
					var tmp_goods_list_byte:ByteArray = new ByteArray;
					byte_goods_list.readBytes(tmp_goods_list_byte, 0, tmp_goods_list_length);
					tmp_goods_list.readFromDataOutput(tmp_goods_list_byte);
					this.goods_list.push(tmp_goods_list);
				}
			}
		}
	}
}
