package proto.line {
	import proto.line.p_bank_sheet;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bank_buy_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var num:int = 0;
		public var price:int = 0;
		public var silver:int = 0;
		public var gold:int = 0;
		public var sheet:p_bank_sheet = null;
		public function m_bank_buy_toc() {
			super();
			this.sheet = new p_bank_sheet;

			flash.net.registerClassAlias("copy.proto.line.m_bank_buy_toc", m_bank_buy_toc);
		}
		public override function getMethodName():String {
			return 'bank_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.num);
			output.writeInt(this.price);
			output.writeInt(this.silver);
			output.writeInt(this.gold);
			var tmp_sheet:ByteArray = new ByteArray;
			this.sheet.writeToDataOutput(tmp_sheet);
			var size_tmp_sheet:int = tmp_sheet.length;
			output.writeInt(size_tmp_sheet);
			output.writeBytes(tmp_sheet);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.num = input.readInt();
			this.price = input.readInt();
			this.silver = input.readInt();
			this.gold = input.readInt();
			var byte_sheet_size:int = input.readInt();
			if (byte_sheet_size > 0) {				this.sheet = new p_bank_sheet;
				var byte_sheet:ByteArray = new ByteArray;
				input.readBytes(byte_sheet, 0, byte_sheet_size);
				this.sheet.readFromDataOutput(byte_sheet);
			}
		}
	}
}
