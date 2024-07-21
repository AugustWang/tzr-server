package proto.line {
	import proto.common.p_gift_goods;
	import proto.common.p_goods;
	import proto.common.p_gift_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_pay_gift_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var pay_first_type_id:int = 0;
		public var pay_first_goods_list:Array = new Array;
		public var has_get_pay_first_gift:Boolean = true;
		public var accumulate_pay_goods_info:p_goods = null;
		public var has_get_accumulate_pay_gift:Boolean = true;
		public var happy_gift_goods_list:Array = new Array;
		public var has_get_happy_gift:Boolean = false;
		public function m_activity_pay_gift_info_toc() {
			super();
			this.accumulate_pay_goods_info = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_activity_pay_gift_info_toc", m_activity_pay_gift_info_toc);
		}
		public override function getMethodName():String {
			return 'activity_pay_gift_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pay_first_type_id);
			var size_pay_first_goods_list:int = this.pay_first_goods_list.length;
			output.writeShort(size_pay_first_goods_list);
			var temp_repeated_byte_pay_first_goods_list:ByteArray= new ByteArray;
			for(i=0; i<size_pay_first_goods_list; i++) {
				var t2_pay_first_goods_list:ByteArray = new ByteArray;
				var tVo_pay_first_goods_list:p_gift_goods = this.pay_first_goods_list[i] as p_gift_goods;
				tVo_pay_first_goods_list.writeToDataOutput(t2_pay_first_goods_list);
				var len_tVo_pay_first_goods_list:int = t2_pay_first_goods_list.length;
				temp_repeated_byte_pay_first_goods_list.writeInt(len_tVo_pay_first_goods_list);
				temp_repeated_byte_pay_first_goods_list.writeBytes(t2_pay_first_goods_list);
			}
			output.writeInt(temp_repeated_byte_pay_first_goods_list.length);
			output.writeBytes(temp_repeated_byte_pay_first_goods_list);
			output.writeBoolean(this.has_get_pay_first_gift);
			var tmp_accumulate_pay_goods_info:ByteArray = new ByteArray;
			this.accumulate_pay_goods_info.writeToDataOutput(tmp_accumulate_pay_goods_info);
			var size_tmp_accumulate_pay_goods_info:int = tmp_accumulate_pay_goods_info.length;
			output.writeInt(size_tmp_accumulate_pay_goods_info);
			output.writeBytes(tmp_accumulate_pay_goods_info);
			output.writeBoolean(this.has_get_accumulate_pay_gift);
			var size_happy_gift_goods_list:int = this.happy_gift_goods_list.length;
			output.writeShort(size_happy_gift_goods_list);
			var temp_repeated_byte_happy_gift_goods_list:ByteArray= new ByteArray;
			for(i=0; i<size_happy_gift_goods_list; i++) {
				var t2_happy_gift_goods_list:ByteArray = new ByteArray;
				var tVo_happy_gift_goods_list:p_gift_goods = this.happy_gift_goods_list[i] as p_gift_goods;
				tVo_happy_gift_goods_list.writeToDataOutput(t2_happy_gift_goods_list);
				var len_tVo_happy_gift_goods_list:int = t2_happy_gift_goods_list.length;
				temp_repeated_byte_happy_gift_goods_list.writeInt(len_tVo_happy_gift_goods_list);
				temp_repeated_byte_happy_gift_goods_list.writeBytes(t2_happy_gift_goods_list);
			}
			output.writeInt(temp_repeated_byte_happy_gift_goods_list.length);
			output.writeBytes(temp_repeated_byte_happy_gift_goods_list);
			output.writeBoolean(this.has_get_happy_gift);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.pay_first_type_id = input.readInt();
			var size_pay_first_goods_list:int = input.readShort();
			var length_pay_first_goods_list:int = input.readInt();
			if (length_pay_first_goods_list > 0) {
				var byte_pay_first_goods_list:ByteArray = new ByteArray; 
				input.readBytes(byte_pay_first_goods_list, 0, length_pay_first_goods_list);
				for(i=0; i<size_pay_first_goods_list; i++) {
					var tmp_pay_first_goods_list:p_gift_goods = new p_gift_goods;
					var tmp_pay_first_goods_list_length:int = byte_pay_first_goods_list.readInt();
					var tmp_pay_first_goods_list_byte:ByteArray = new ByteArray;
					byte_pay_first_goods_list.readBytes(tmp_pay_first_goods_list_byte, 0, tmp_pay_first_goods_list_length);
					tmp_pay_first_goods_list.readFromDataOutput(tmp_pay_first_goods_list_byte);
					this.pay_first_goods_list.push(tmp_pay_first_goods_list);
				}
			}
			this.has_get_pay_first_gift = input.readBoolean();
			var byte_accumulate_pay_goods_info_size:int = input.readInt();
			if (byte_accumulate_pay_goods_info_size > 0) {				this.accumulate_pay_goods_info = new p_goods;
				var byte_accumulate_pay_goods_info:ByteArray = new ByteArray;
				input.readBytes(byte_accumulate_pay_goods_info, 0, byte_accumulate_pay_goods_info_size);
				this.accumulate_pay_goods_info.readFromDataOutput(byte_accumulate_pay_goods_info);
			}
			this.has_get_accumulate_pay_gift = input.readBoolean();
			var size_happy_gift_goods_list:int = input.readShort();
			var length_happy_gift_goods_list:int = input.readInt();
			if (length_happy_gift_goods_list > 0) {
				var byte_happy_gift_goods_list:ByteArray = new ByteArray; 
				input.readBytes(byte_happy_gift_goods_list, 0, length_happy_gift_goods_list);
				for(i=0; i<size_happy_gift_goods_list; i++) {
					var tmp_happy_gift_goods_list:p_gift_goods = new p_gift_goods;
					var tmp_happy_gift_goods_list_length:int = byte_happy_gift_goods_list.readInt();
					var tmp_happy_gift_goods_list_byte:ByteArray = new ByteArray;
					byte_happy_gift_goods_list.readBytes(tmp_happy_gift_goods_list_byte, 0, tmp_happy_gift_goods_list_length);
					tmp_happy_gift_goods_list.readFromDataOutput(tmp_happy_gift_goods_list_byte);
					this.happy_gift_goods_list.push(tmp_happy_gift_goods_list);
				}
			}
			this.has_get_happy_gift = input.readBoolean();
		}
	}
}
