package proto.line {
	import proto.common.p_educate_fb_item;
	import proto.common.p_educate_fb_item;
	import proto.common.p_goods;
	import proto.common.p_educate_fb_award;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_fb_query_toc extends Message
	{
		public var succ:Boolean = true;
		public var op_type:int = 0;
		public var reason:String = "";
		public var times:int = 0;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public var status:int = 0;
		public var count:int = 0;
		public var fb_items:Array = new Array;
		public var lucky_count:int = 0;
		public var goods_id:int = 0;
		public var item_id:int = 0;
		public var use_role_id:int = 0;
		public var use_role_name:String = "";
		public var use_tx:int = 0;
		public var use_ty:int = 0;
		public var return_self:Boolean = true;
		public var all_fb_items:Array = new Array;
		public var leader_role_id:int = 0;
		public var max_lucky_count:int = 0;
		public var award_goods:Array = new Array;
		public var fb_award_config:Array = new Array;
		public function m_educate_fb_query_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_fb_query_toc", m_educate_fb_query_toc);
		}
		public override function getMethodName():String {
			return 'educate_fb_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.op_type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.times);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
			output.writeInt(this.status);
			output.writeInt(this.count);
			var size_fb_items:int = this.fb_items.length;
			output.writeShort(size_fb_items);
			var temp_repeated_byte_fb_items:ByteArray= new ByteArray;
			for(i=0; i<size_fb_items; i++) {
				var t2_fb_items:ByteArray = new ByteArray;
				var tVo_fb_items:p_educate_fb_item = this.fb_items[i] as p_educate_fb_item;
				tVo_fb_items.writeToDataOutput(t2_fb_items);
				var len_tVo_fb_items:int = t2_fb_items.length;
				temp_repeated_byte_fb_items.writeInt(len_tVo_fb_items);
				temp_repeated_byte_fb_items.writeBytes(t2_fb_items);
			}
			output.writeInt(temp_repeated_byte_fb_items.length);
			output.writeBytes(temp_repeated_byte_fb_items);
			output.writeInt(this.lucky_count);
			output.writeInt(this.goods_id);
			output.writeInt(this.item_id);
			output.writeInt(this.use_role_id);
			if (this.use_role_name != null) {				output.writeUTF(this.use_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.use_tx);
			output.writeInt(this.use_ty);
			output.writeBoolean(this.return_self);
			var size_all_fb_items:int = this.all_fb_items.length;
			output.writeShort(size_all_fb_items);
			var temp_repeated_byte_all_fb_items:ByteArray= new ByteArray;
			for(i=0; i<size_all_fb_items; i++) {
				var t2_all_fb_items:ByteArray = new ByteArray;
				var tVo_all_fb_items:p_educate_fb_item = this.all_fb_items[i] as p_educate_fb_item;
				tVo_all_fb_items.writeToDataOutput(t2_all_fb_items);
				var len_tVo_all_fb_items:int = t2_all_fb_items.length;
				temp_repeated_byte_all_fb_items.writeInt(len_tVo_all_fb_items);
				temp_repeated_byte_all_fb_items.writeBytes(t2_all_fb_items);
			}
			output.writeInt(temp_repeated_byte_all_fb_items.length);
			output.writeBytes(temp_repeated_byte_all_fb_items);
			output.writeInt(this.leader_role_id);
			output.writeInt(this.max_lucky_count);
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
			var size_fb_award_config:int = this.fb_award_config.length;
			output.writeShort(size_fb_award_config);
			var temp_repeated_byte_fb_award_config:ByteArray= new ByteArray;
			for(i=0; i<size_fb_award_config; i++) {
				var t2_fb_award_config:ByteArray = new ByteArray;
				var tVo_fb_award_config:p_educate_fb_award = this.fb_award_config[i] as p_educate_fb_award;
				tVo_fb_award_config.writeToDataOutput(t2_fb_award_config);
				var len_tVo_fb_award_config:int = t2_fb_award_config.length;
				temp_repeated_byte_fb_award_config.writeInt(len_tVo_fb_award_config);
				temp_repeated_byte_fb_award_config.writeBytes(t2_fb_award_config);
			}
			output.writeInt(temp_repeated_byte_fb_award_config.length);
			output.writeBytes(temp_repeated_byte_fb_award_config);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.op_type = input.readInt();
			this.reason = input.readUTF();
			this.times = input.readInt();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
			this.status = input.readInt();
			this.count = input.readInt();
			var size_fb_items:int = input.readShort();
			var length_fb_items:int = input.readInt();
			if (length_fb_items > 0) {
				var byte_fb_items:ByteArray = new ByteArray; 
				input.readBytes(byte_fb_items, 0, length_fb_items);
				for(i=0; i<size_fb_items; i++) {
					var tmp_fb_items:p_educate_fb_item = new p_educate_fb_item;
					var tmp_fb_items_length:int = byte_fb_items.readInt();
					var tmp_fb_items_byte:ByteArray = new ByteArray;
					byte_fb_items.readBytes(tmp_fb_items_byte, 0, tmp_fb_items_length);
					tmp_fb_items.readFromDataOutput(tmp_fb_items_byte);
					this.fb_items.push(tmp_fb_items);
				}
			}
			this.lucky_count = input.readInt();
			this.goods_id = input.readInt();
			this.item_id = input.readInt();
			this.use_role_id = input.readInt();
			this.use_role_name = input.readUTF();
			this.use_tx = input.readInt();
			this.use_ty = input.readInt();
			this.return_self = input.readBoolean();
			var size_all_fb_items:int = input.readShort();
			var length_all_fb_items:int = input.readInt();
			if (length_all_fb_items > 0) {
				var byte_all_fb_items:ByteArray = new ByteArray; 
				input.readBytes(byte_all_fb_items, 0, length_all_fb_items);
				for(i=0; i<size_all_fb_items; i++) {
					var tmp_all_fb_items:p_educate_fb_item = new p_educate_fb_item;
					var tmp_all_fb_items_length:int = byte_all_fb_items.readInt();
					var tmp_all_fb_items_byte:ByteArray = new ByteArray;
					byte_all_fb_items.readBytes(tmp_all_fb_items_byte, 0, tmp_all_fb_items_length);
					tmp_all_fb_items.readFromDataOutput(tmp_all_fb_items_byte);
					this.all_fb_items.push(tmp_all_fb_items);
				}
			}
			this.leader_role_id = input.readInt();
			this.max_lucky_count = input.readInt();
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
			var size_fb_award_config:int = input.readShort();
			var length_fb_award_config:int = input.readInt();
			if (length_fb_award_config > 0) {
				var byte_fb_award_config:ByteArray = new ByteArray; 
				input.readBytes(byte_fb_award_config, 0, length_fb_award_config);
				for(i=0; i<size_fb_award_config; i++) {
					var tmp_fb_award_config:p_educate_fb_award = new p_educate_fb_award;
					var tmp_fb_award_config_length:int = byte_fb_award_config.readInt();
					var tmp_fb_award_config_byte:ByteArray = new ByteArray;
					byte_fb_award_config.readBytes(tmp_fb_award_config_byte, 0, tmp_fb_award_config_length);
					tmp_fb_award_config.readFromDataOutput(tmp_fb_award_config_byte);
					this.fb_award_config.push(tmp_fb_award_config);
				}
			}
		}
	}
}
