package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_refining_box_log;
	import proto.common.p_refining_box_log;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_box_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var op_type:int = 0;
		public var op_fee_type:int = 0;
		public var goods_ids:Array = new Array;
		public var page_no:int = 0;
		public var page_type:int = 0;
		public var is_open:Boolean = true;
		public var is_free:Boolean = true;
		public var award_time:int = 0;
		public var box_list:Array = new Array;
		public var award_list:Array = new Array;
		public var cur_list:Array = new Array;
		public var award_status:int = 0;
		public var all_log_list:Array = new Array;
		public var self_log_list:Array = new Array;
		public var generate_type:int = 0;
		public var total_pages:int = 0;
		public var is_restore:int = 0;
		public function m_refining_box_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_box_toc", m_refining_box_toc);
		}
		public override function getMethodName():String {
			return 'refining_box';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
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
			output.writeBoolean(this.is_open);
			output.writeBoolean(this.is_free);
			output.writeInt(this.award_time);
			var size_box_list:int = this.box_list.length;
			output.writeShort(size_box_list);
			var temp_repeated_byte_box_list:ByteArray= new ByteArray;
			for(i=0; i<size_box_list; i++) {
				var t2_box_list:ByteArray = new ByteArray;
				var tVo_box_list:p_goods = this.box_list[i] as p_goods;
				tVo_box_list.writeToDataOutput(t2_box_list);
				var len_tVo_box_list:int = t2_box_list.length;
				temp_repeated_byte_box_list.writeInt(len_tVo_box_list);
				temp_repeated_byte_box_list.writeBytes(t2_box_list);
			}
			output.writeInt(temp_repeated_byte_box_list.length);
			output.writeBytes(temp_repeated_byte_box_list);
			var size_award_list:int = this.award_list.length;
			output.writeShort(size_award_list);
			var temp_repeated_byte_award_list:ByteArray= new ByteArray;
			for(i=0; i<size_award_list; i++) {
				var t2_award_list:ByteArray = new ByteArray;
				var tVo_award_list:p_goods = this.award_list[i] as p_goods;
				tVo_award_list.writeToDataOutput(t2_award_list);
				var len_tVo_award_list:int = t2_award_list.length;
				temp_repeated_byte_award_list.writeInt(len_tVo_award_list);
				temp_repeated_byte_award_list.writeBytes(t2_award_list);
			}
			output.writeInt(temp_repeated_byte_award_list.length);
			output.writeBytes(temp_repeated_byte_award_list);
			var size_cur_list:int = this.cur_list.length;
			output.writeShort(size_cur_list);
			var temp_repeated_byte_cur_list:ByteArray= new ByteArray;
			for(i=0; i<size_cur_list; i++) {
				var t2_cur_list:ByteArray = new ByteArray;
				var tVo_cur_list:p_goods = this.cur_list[i] as p_goods;
				tVo_cur_list.writeToDataOutput(t2_cur_list);
				var len_tVo_cur_list:int = t2_cur_list.length;
				temp_repeated_byte_cur_list.writeInt(len_tVo_cur_list);
				temp_repeated_byte_cur_list.writeBytes(t2_cur_list);
			}
			output.writeInt(temp_repeated_byte_cur_list.length);
			output.writeBytes(temp_repeated_byte_cur_list);
			output.writeInt(this.award_status);
			var size_all_log_list:int = this.all_log_list.length;
			output.writeShort(size_all_log_list);
			var temp_repeated_byte_all_log_list:ByteArray= new ByteArray;
			for(i=0; i<size_all_log_list; i++) {
				var t2_all_log_list:ByteArray = new ByteArray;
				var tVo_all_log_list:p_refining_box_log = this.all_log_list[i] as p_refining_box_log;
				tVo_all_log_list.writeToDataOutput(t2_all_log_list);
				var len_tVo_all_log_list:int = t2_all_log_list.length;
				temp_repeated_byte_all_log_list.writeInt(len_tVo_all_log_list);
				temp_repeated_byte_all_log_list.writeBytes(t2_all_log_list);
			}
			output.writeInt(temp_repeated_byte_all_log_list.length);
			output.writeBytes(temp_repeated_byte_all_log_list);
			var size_self_log_list:int = this.self_log_list.length;
			output.writeShort(size_self_log_list);
			var temp_repeated_byte_self_log_list:ByteArray= new ByteArray;
			for(i=0; i<size_self_log_list; i++) {
				var t2_self_log_list:ByteArray = new ByteArray;
				var tVo_self_log_list:p_refining_box_log = this.self_log_list[i] as p_refining_box_log;
				tVo_self_log_list.writeToDataOutput(t2_self_log_list);
				var len_tVo_self_log_list:int = t2_self_log_list.length;
				temp_repeated_byte_self_log_list.writeInt(len_tVo_self_log_list);
				temp_repeated_byte_self_log_list.writeBytes(t2_self_log_list);
			}
			output.writeInt(temp_repeated_byte_self_log_list.length);
			output.writeBytes(temp_repeated_byte_self_log_list);
			output.writeInt(this.generate_type);
			output.writeInt(this.total_pages);
			output.writeInt(this.is_restore);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
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
			this.is_open = input.readBoolean();
			this.is_free = input.readBoolean();
			this.award_time = input.readInt();
			var size_box_list:int = input.readShort();
			var length_box_list:int = input.readInt();
			if (length_box_list > 0) {
				var byte_box_list:ByteArray = new ByteArray; 
				input.readBytes(byte_box_list, 0, length_box_list);
				for(i=0; i<size_box_list; i++) {
					var tmp_box_list:p_goods = new p_goods;
					var tmp_box_list_length:int = byte_box_list.readInt();
					var tmp_box_list_byte:ByteArray = new ByteArray;
					byte_box_list.readBytes(tmp_box_list_byte, 0, tmp_box_list_length);
					tmp_box_list.readFromDataOutput(tmp_box_list_byte);
					this.box_list.push(tmp_box_list);
				}
			}
			var size_award_list:int = input.readShort();
			var length_award_list:int = input.readInt();
			if (length_award_list > 0) {
				var byte_award_list:ByteArray = new ByteArray; 
				input.readBytes(byte_award_list, 0, length_award_list);
				for(i=0; i<size_award_list; i++) {
					var tmp_award_list:p_goods = new p_goods;
					var tmp_award_list_length:int = byte_award_list.readInt();
					var tmp_award_list_byte:ByteArray = new ByteArray;
					byte_award_list.readBytes(tmp_award_list_byte, 0, tmp_award_list_length);
					tmp_award_list.readFromDataOutput(tmp_award_list_byte);
					this.award_list.push(tmp_award_list);
				}
			}
			var size_cur_list:int = input.readShort();
			var length_cur_list:int = input.readInt();
			if (length_cur_list > 0) {
				var byte_cur_list:ByteArray = new ByteArray; 
				input.readBytes(byte_cur_list, 0, length_cur_list);
				for(i=0; i<size_cur_list; i++) {
					var tmp_cur_list:p_goods = new p_goods;
					var tmp_cur_list_length:int = byte_cur_list.readInt();
					var tmp_cur_list_byte:ByteArray = new ByteArray;
					byte_cur_list.readBytes(tmp_cur_list_byte, 0, tmp_cur_list_length);
					tmp_cur_list.readFromDataOutput(tmp_cur_list_byte);
					this.cur_list.push(tmp_cur_list);
				}
			}
			this.award_status = input.readInt();
			var size_all_log_list:int = input.readShort();
			var length_all_log_list:int = input.readInt();
			if (length_all_log_list > 0) {
				var byte_all_log_list:ByteArray = new ByteArray; 
				input.readBytes(byte_all_log_list, 0, length_all_log_list);
				for(i=0; i<size_all_log_list; i++) {
					var tmp_all_log_list:p_refining_box_log = new p_refining_box_log;
					var tmp_all_log_list_length:int = byte_all_log_list.readInt();
					var tmp_all_log_list_byte:ByteArray = new ByteArray;
					byte_all_log_list.readBytes(tmp_all_log_list_byte, 0, tmp_all_log_list_length);
					tmp_all_log_list.readFromDataOutput(tmp_all_log_list_byte);
					this.all_log_list.push(tmp_all_log_list);
				}
			}
			var size_self_log_list:int = input.readShort();
			var length_self_log_list:int = input.readInt();
			if (length_self_log_list > 0) {
				var byte_self_log_list:ByteArray = new ByteArray; 
				input.readBytes(byte_self_log_list, 0, length_self_log_list);
				for(i=0; i<size_self_log_list; i++) {
					var tmp_self_log_list:p_refining_box_log = new p_refining_box_log;
					var tmp_self_log_list_length:int = byte_self_log_list.readInt();
					var tmp_self_log_list_byte:ByteArray = new ByteArray;
					byte_self_log_list.readBytes(tmp_self_log_list_byte, 0, tmp_self_log_list_length);
					tmp_self_log_list.readFromDataOutput(tmp_self_log_list_byte);
					this.self_log_list.push(tmp_self_log_list);
				}
			}
			this.generate_type = input.readInt();
			this.total_pages = input.readInt();
			this.is_restore = input.readInt();
		}
	}
}
