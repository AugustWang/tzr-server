package proto.line {
	import proto.line.p_bank_sheet;
	import proto.line.p_bank_sheet;
	import proto.line.p_bank_simple_sheet;
	import proto.line.p_bank_simple_sheet;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bank_undo_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var self_sell:Array = new Array;
		public var self_buy:Array = new Array;
		public var bank_sell:Array = new Array;
		public var bank_buy:Array = new Array;
		public var return_back:int = 0;
		public function m_bank_undo_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bank_undo_toc", m_bank_undo_toc);
		}
		public override function getMethodName():String {
			return 'bank_undo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_self_sell:int = this.self_sell.length;
			output.writeShort(size_self_sell);
			var temp_repeated_byte_self_sell:ByteArray= new ByteArray;
			for(i=0; i<size_self_sell; i++) {
				var t2_self_sell:ByteArray = new ByteArray;
				var tVo_self_sell:p_bank_sheet = this.self_sell[i] as p_bank_sheet;
				tVo_self_sell.writeToDataOutput(t2_self_sell);
				var len_tVo_self_sell:int = t2_self_sell.length;
				temp_repeated_byte_self_sell.writeInt(len_tVo_self_sell);
				temp_repeated_byte_self_sell.writeBytes(t2_self_sell);
			}
			output.writeInt(temp_repeated_byte_self_sell.length);
			output.writeBytes(temp_repeated_byte_self_sell);
			var size_self_buy:int = this.self_buy.length;
			output.writeShort(size_self_buy);
			var temp_repeated_byte_self_buy:ByteArray= new ByteArray;
			for(i=0; i<size_self_buy; i++) {
				var t2_self_buy:ByteArray = new ByteArray;
				var tVo_self_buy:p_bank_sheet = this.self_buy[i] as p_bank_sheet;
				tVo_self_buy.writeToDataOutput(t2_self_buy);
				var len_tVo_self_buy:int = t2_self_buy.length;
				temp_repeated_byte_self_buy.writeInt(len_tVo_self_buy);
				temp_repeated_byte_self_buy.writeBytes(t2_self_buy);
			}
			output.writeInt(temp_repeated_byte_self_buy.length);
			output.writeBytes(temp_repeated_byte_self_buy);
			var size_bank_sell:int = this.bank_sell.length;
			output.writeShort(size_bank_sell);
			var temp_repeated_byte_bank_sell:ByteArray= new ByteArray;
			for(i=0; i<size_bank_sell; i++) {
				var t2_bank_sell:ByteArray = new ByteArray;
				var tVo_bank_sell:p_bank_simple_sheet = this.bank_sell[i] as p_bank_simple_sheet;
				tVo_bank_sell.writeToDataOutput(t2_bank_sell);
				var len_tVo_bank_sell:int = t2_bank_sell.length;
				temp_repeated_byte_bank_sell.writeInt(len_tVo_bank_sell);
				temp_repeated_byte_bank_sell.writeBytes(t2_bank_sell);
			}
			output.writeInt(temp_repeated_byte_bank_sell.length);
			output.writeBytes(temp_repeated_byte_bank_sell);
			var size_bank_buy:int = this.bank_buy.length;
			output.writeShort(size_bank_buy);
			var temp_repeated_byte_bank_buy:ByteArray= new ByteArray;
			for(i=0; i<size_bank_buy; i++) {
				var t2_bank_buy:ByteArray = new ByteArray;
				var tVo_bank_buy:p_bank_simple_sheet = this.bank_buy[i] as p_bank_simple_sheet;
				tVo_bank_buy.writeToDataOutput(t2_bank_buy);
				var len_tVo_bank_buy:int = t2_bank_buy.length;
				temp_repeated_byte_bank_buy.writeInt(len_tVo_bank_buy);
				temp_repeated_byte_bank_buy.writeBytes(t2_bank_buy);
			}
			output.writeInt(temp_repeated_byte_bank_buy.length);
			output.writeBytes(temp_repeated_byte_bank_buy);
			output.writeInt(this.return_back);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_self_sell:int = input.readShort();
			var length_self_sell:int = input.readInt();
			if (length_self_sell > 0) {
				var byte_self_sell:ByteArray = new ByteArray; 
				input.readBytes(byte_self_sell, 0, length_self_sell);
				for(i=0; i<size_self_sell; i++) {
					var tmp_self_sell:p_bank_sheet = new p_bank_sheet;
					var tmp_self_sell_length:int = byte_self_sell.readInt();
					var tmp_self_sell_byte:ByteArray = new ByteArray;
					byte_self_sell.readBytes(tmp_self_sell_byte, 0, tmp_self_sell_length);
					tmp_self_sell.readFromDataOutput(tmp_self_sell_byte);
					this.self_sell.push(tmp_self_sell);
				}
			}
			var size_self_buy:int = input.readShort();
			var length_self_buy:int = input.readInt();
			if (length_self_buy > 0) {
				var byte_self_buy:ByteArray = new ByteArray; 
				input.readBytes(byte_self_buy, 0, length_self_buy);
				for(i=0; i<size_self_buy; i++) {
					var tmp_self_buy:p_bank_sheet = new p_bank_sheet;
					var tmp_self_buy_length:int = byte_self_buy.readInt();
					var tmp_self_buy_byte:ByteArray = new ByteArray;
					byte_self_buy.readBytes(tmp_self_buy_byte, 0, tmp_self_buy_length);
					tmp_self_buy.readFromDataOutput(tmp_self_buy_byte);
					this.self_buy.push(tmp_self_buy);
				}
			}
			var size_bank_sell:int = input.readShort();
			var length_bank_sell:int = input.readInt();
			if (length_bank_sell > 0) {
				var byte_bank_sell:ByteArray = new ByteArray; 
				input.readBytes(byte_bank_sell, 0, length_bank_sell);
				for(i=0; i<size_bank_sell; i++) {
					var tmp_bank_sell:p_bank_simple_sheet = new p_bank_simple_sheet;
					var tmp_bank_sell_length:int = byte_bank_sell.readInt();
					var tmp_bank_sell_byte:ByteArray = new ByteArray;
					byte_bank_sell.readBytes(tmp_bank_sell_byte, 0, tmp_bank_sell_length);
					tmp_bank_sell.readFromDataOutput(tmp_bank_sell_byte);
					this.bank_sell.push(tmp_bank_sell);
				}
			}
			var size_bank_buy:int = input.readShort();
			var length_bank_buy:int = input.readInt();
			if (length_bank_buy > 0) {
				var byte_bank_buy:ByteArray = new ByteArray; 
				input.readBytes(byte_bank_buy, 0, length_bank_buy);
				for(i=0; i<size_bank_buy; i++) {
					var tmp_bank_buy:p_bank_simple_sheet = new p_bank_simple_sheet;
					var tmp_bank_buy_length:int = byte_bank_buy.readInt();
					var tmp_bank_buy_byte:ByteArray = new ByteArray;
					byte_bank_buy.readBytes(tmp_bank_buy_byte, 0, tmp_bank_buy_length);
					tmp_bank_buy.readFromDataOutput(tmp_bank_buy_byte);
					this.bank_buy.push(tmp_bank_buy);
				}
			}
			this.return_back = input.readInt();
		}
	}
}
