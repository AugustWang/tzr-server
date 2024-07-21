package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_gift_item_query_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var cur_goods:Array = new Array;
		public var award_role_level:int = 0;
		public function m_gift_item_query_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_gift_item_query_toc", m_gift_item_query_toc);
		}
		public override function getMethodName():String {
			return 'gift_item_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_cur_goods:int = this.cur_goods.length;
			output.writeShort(size_cur_goods);
			var temp_repeated_byte_cur_goods:ByteArray= new ByteArray;
			for(i=0; i<size_cur_goods; i++) {
				var t2_cur_goods:ByteArray = new ByteArray;
				var tVo_cur_goods:p_goods = this.cur_goods[i] as p_goods;
				tVo_cur_goods.writeToDataOutput(t2_cur_goods);
				var len_tVo_cur_goods:int = t2_cur_goods.length;
				temp_repeated_byte_cur_goods.writeInt(len_tVo_cur_goods);
				temp_repeated_byte_cur_goods.writeBytes(t2_cur_goods);
			}
			output.writeInt(temp_repeated_byte_cur_goods.length);
			output.writeBytes(temp_repeated_byte_cur_goods);
			output.writeInt(this.award_role_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_cur_goods:int = input.readShort();
			var length_cur_goods:int = input.readInt();
			if (length_cur_goods > 0) {
				var byte_cur_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_cur_goods, 0, length_cur_goods);
				for(i=0; i<size_cur_goods; i++) {
					var tmp_cur_goods:p_goods = new p_goods;
					var tmp_cur_goods_length:int = byte_cur_goods.readInt();
					var tmp_cur_goods_byte:ByteArray = new ByteArray;
					byte_cur_goods.readBytes(tmp_cur_goods_byte, 0, tmp_cur_goods_length);
					tmp_cur_goods.readFromDataOutput(tmp_cur_goods_byte);
					this.cur_goods.push(tmp_cur_goods);
				}
			}
			this.award_role_level = input.readInt();
		}
	}
}
