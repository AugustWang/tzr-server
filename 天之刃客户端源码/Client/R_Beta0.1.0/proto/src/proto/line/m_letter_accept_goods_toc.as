package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_accept_goods_toc extends Message
	{
		public var succ:Boolean = true;
		public var goods_list:Array = new Array;
		public var goods_take:Array = new Array;
		public var reason:String = "";
		public function m_letter_accept_goods_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_accept_goods_toc", m_letter_accept_goods_toc);
		}
		public override function getMethodName():String {
			return 'letter_accept_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
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
			var size_goods_take:int = this.goods_take.length;
			output.writeShort(size_goods_take);
			var temp_repeated_byte_goods_take:ByteArray= new ByteArray;
			for(i=0; i<size_goods_take; i++) {
				var t2_goods_take:ByteArray = new ByteArray;
				var tVo_goods_take:p_goods = this.goods_take[i] as p_goods;
				tVo_goods_take.writeToDataOutput(t2_goods_take);
				var len_tVo_goods_take:int = t2_goods_take.length;
				temp_repeated_byte_goods_take.writeInt(len_tVo_goods_take);
				temp_repeated_byte_goods_take.writeBytes(t2_goods_take);
			}
			output.writeInt(temp_repeated_byte_goods_take.length);
			output.writeBytes(temp_repeated_byte_goods_take);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
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
			var size_goods_take:int = input.readShort();
			var length_goods_take:int = input.readInt();
			if (length_goods_take > 0) {
				var byte_goods_take:ByteArray = new ByteArray; 
				input.readBytes(byte_goods_take, 0, length_goods_take);
				for(i=0; i<size_goods_take; i++) {
					var tmp_goods_take:p_goods = new p_goods;
					var tmp_goods_take_length:int = byte_goods_take.readInt();
					var tmp_goods_take_byte:ByteArray = new ByteArray;
					byte_goods_take.readBytes(tmp_goods_take_byte, 0, tmp_goods_take_length);
					tmp_goods_take.readFromDataOutput(tmp_goods_take_byte);
					this.goods_take.push(tmp_goods_take);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
