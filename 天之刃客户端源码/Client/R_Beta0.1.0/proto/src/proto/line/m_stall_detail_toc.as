package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_detail_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var role_id:int = 0;
		public var role_name:String = "";
		public var goods:Array = new Array;
		public var mode:int = 0;
		public var remain_time:int = 0;
		public var name:String = "";
		public var buy_logs:Array = new Array;
		public var chat_logs:Array = new Array;
		public function m_stall_detail_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_detail_toc", m_stall_detail_toc);
		}
		public override function getMethodName():String {
			return 'stall_detail';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			var size_goods:int = this.goods.length;
			output.writeShort(size_goods);
			var temp_repeated_byte_goods:ByteArray= new ByteArray;
			for(i=0; i<size_goods; i++) {
				var t2_goods:ByteArray = new ByteArray;
				var tVo_goods:p_stall_goods = this.goods[i] as p_stall_goods;
				tVo_goods.writeToDataOutput(t2_goods);
				var len_tVo_goods:int = t2_goods.length;
				temp_repeated_byte_goods.writeInt(len_tVo_goods);
				temp_repeated_byte_goods.writeBytes(t2_goods);
			}
			output.writeInt(temp_repeated_byte_goods.length);
			output.writeBytes(temp_repeated_byte_goods);
			output.writeInt(this.mode);
			output.writeInt(this.remain_time);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			var size_buy_logs:int = this.buy_logs.length;
			output.writeShort(size_buy_logs);
			var temp_repeated_byte_buy_logs:ByteArray= new ByteArray;
			for(i=0; i<size_buy_logs; i++) {
				var t2_buy_logs:ByteArray = new ByteArray;
				var tVo_buy_logs:p_stall_log = this.buy_logs[i] as p_stall_log;
				tVo_buy_logs.writeToDataOutput(t2_buy_logs);
				var len_tVo_buy_logs:int = t2_buy_logs.length;
				temp_repeated_byte_buy_logs.writeInt(len_tVo_buy_logs);
				temp_repeated_byte_buy_logs.writeBytes(t2_buy_logs);
			}
			output.writeInt(temp_repeated_byte_buy_logs.length);
			output.writeBytes(temp_repeated_byte_buy_logs);
			var size_chat_logs:int = this.chat_logs.length;
			output.writeShort(size_chat_logs);
			var temp_repeated_byte_chat_logs:ByteArray= new ByteArray;
			for(i=0; i<size_chat_logs; i++) {
				var t2_chat_logs:ByteArray = new ByteArray;
				var tVo_chat_logs:p_stall_log = this.chat_logs[i] as p_stall_log;
				tVo_chat_logs.writeToDataOutput(t2_chat_logs);
				var len_tVo_chat_logs:int = t2_chat_logs.length;
				temp_repeated_byte_chat_logs.writeInt(len_tVo_chat_logs);
				temp_repeated_byte_chat_logs.writeBytes(t2_chat_logs);
			}
			output.writeInt(temp_repeated_byte_chat_logs.length);
			output.writeBytes(temp_repeated_byte_chat_logs);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			var size_goods:int = input.readShort();
			var length_goods:int = input.readInt();
			if (length_goods > 0) {
				var byte_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_goods, 0, length_goods);
				for(i=0; i<size_goods; i++) {
					var tmp_goods:p_stall_goods = new p_stall_goods;
					var tmp_goods_length:int = byte_goods.readInt();
					var tmp_goods_byte:ByteArray = new ByteArray;
					byte_goods.readBytes(tmp_goods_byte, 0, tmp_goods_length);
					tmp_goods.readFromDataOutput(tmp_goods_byte);
					this.goods.push(tmp_goods);
				}
			}
			this.mode = input.readInt();
			this.remain_time = input.readInt();
			this.name = input.readUTF();
			var size_buy_logs:int = input.readShort();
			var length_buy_logs:int = input.readInt();
			if (length_buy_logs > 0) {
				var byte_buy_logs:ByteArray = new ByteArray; 
				input.readBytes(byte_buy_logs, 0, length_buy_logs);
				for(i=0; i<size_buy_logs; i++) {
					var tmp_buy_logs:p_stall_log = new p_stall_log;
					var tmp_buy_logs_length:int = byte_buy_logs.readInt();
					var tmp_buy_logs_byte:ByteArray = new ByteArray;
					byte_buy_logs.readBytes(tmp_buy_logs_byte, 0, tmp_buy_logs_length);
					tmp_buy_logs.readFromDataOutput(tmp_buy_logs_byte);
					this.buy_logs.push(tmp_buy_logs);
				}
			}
			var size_chat_logs:int = input.readShort();
			var length_chat_logs:int = input.readInt();
			if (length_chat_logs > 0) {
				var byte_chat_logs:ByteArray = new ByteArray; 
				input.readBytes(byte_chat_logs, 0, length_chat_logs);
				for(i=0; i<size_chat_logs; i++) {
					var tmp_chat_logs:p_stall_log = new p_stall_log;
					var tmp_chat_logs_length:int = byte_chat_logs.readInt();
					var tmp_chat_logs_byte:ByteArray = new ByteArray;
					byte_chat_logs.readBytes(tmp_chat_logs_byte, 0, tmp_chat_logs_length);
					tmp_chat_logs.readFromDataOutput(tmp_chat_logs_byte);
					this.chat_logs.push(tmp_chat_logs);
				}
			}
		}
	}
}
