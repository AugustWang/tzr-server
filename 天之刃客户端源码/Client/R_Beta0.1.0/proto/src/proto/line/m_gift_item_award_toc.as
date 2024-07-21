package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_gift_item_award_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var award_goods:Array = new Array;
		public var next_goods:Array = new Array;
		public var award_role_level:int = 0;
		public function m_gift_item_award_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_gift_item_award_toc", m_gift_item_award_toc);
		}
		public override function getMethodName():String {
			return 'gift_item_award';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_award_goods:int = this.award_goods.length;
			output.writeShort(size_award_goods);
			var temp_repeated_byte_award_goods:ByteArray= new ByteArray;
			for(i=0; i<size_award_goods; i++) {
				var t2_award_goods:ByteArray = new ByteArray;
				var tVo_award_goods:p_goods = this.award_goods[i] as p_goods;
				tVo_award_goods.writeToDataOutput(t2_award_goods);
				var len_tVo_award_goods:int = t2_award_goods.length;
				temp_repeated_byte_award_goods.writeInt(len_tVo_award_goods);
				temp_repeated_byte_award_goods.writeBytes(t2_award_goods);
			}
			output.writeInt(temp_repeated_byte_award_goods.length);
			output.writeBytes(temp_repeated_byte_award_goods);
			var size_next_goods:int = this.next_goods.length;
			output.writeShort(size_next_goods);
			var temp_repeated_byte_next_goods:ByteArray= new ByteArray;
			for(i=0; i<size_next_goods; i++) {
				var t2_next_goods:ByteArray = new ByteArray;
				var tVo_next_goods:p_goods = this.next_goods[i] as p_goods;
				tVo_next_goods.writeToDataOutput(t2_next_goods);
				var len_tVo_next_goods:int = t2_next_goods.length;
				temp_repeated_byte_next_goods.writeInt(len_tVo_next_goods);
				temp_repeated_byte_next_goods.writeBytes(t2_next_goods);
			}
			output.writeInt(temp_repeated_byte_next_goods.length);
			output.writeBytes(temp_repeated_byte_next_goods);
			output.writeInt(this.award_role_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_award_goods:int = input.readShort();
			var length_award_goods:int = input.readInt();
			if (length_award_goods > 0) {
				var byte_award_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_award_goods, 0, length_award_goods);
				for(i=0; i<size_award_goods; i++) {
					var tmp_award_goods:p_goods = new p_goods;
					var tmp_award_goods_length:int = byte_award_goods.readInt();
					var tmp_award_goods_byte:ByteArray = new ByteArray;
					byte_award_goods.readBytes(tmp_award_goods_byte, 0, tmp_award_goods_length);
					tmp_award_goods.readFromDataOutput(tmp_award_goods_byte);
					this.award_goods.push(tmp_award_goods);
				}
			}
			var size_next_goods:int = input.readShort();
			var length_next_goods:int = input.readInt();
			if (length_next_goods > 0) {
				var byte_next_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_next_goods, 0, length_next_goods);
				for(i=0; i<size_next_goods; i++) {
					var tmp_next_goods:p_goods = new p_goods;
					var tmp_next_goods_length:int = byte_next_goods.readInt();
					var tmp_next_goods_byte:ByteArray = new ByteArray;
					byte_next_goods.readBytes(tmp_next_goods_byte, 0, tmp_next_goods_length);
					tmp_next_goods.readFromDataOutput(tmp_next_goods_byte);
					this.next_goods.push(tmp_next_goods);
				}
			}
			this.award_role_level = input.readInt();
		}
	}
}
