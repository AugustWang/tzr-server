package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_inlay_toc extends Message
	{
		public var succ:Boolean = true;
		public var equip:p_goods = null;
		public var stone:p_goods = null;
		public var symbol:p_goods = null;
		public var reason:String = "";
		public function m_refining_inlay_toc() {
			super();
			this.equip = new p_goods;
			this.stone = new p_goods;
			this.symbol = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_refining_inlay_toc", m_refining_inlay_toc);
		}
		public override function getMethodName():String {
			return 'refining_inlay';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_equip:ByteArray = new ByteArray;
			this.equip.writeToDataOutput(tmp_equip);
			var size_tmp_equip:int = tmp_equip.length;
			output.writeInt(size_tmp_equip);
			output.writeBytes(tmp_equip);
			var tmp_stone:ByteArray = new ByteArray;
			this.stone.writeToDataOutput(tmp_stone);
			var size_tmp_stone:int = tmp_stone.length;
			output.writeInt(size_tmp_stone);
			output.writeBytes(tmp_stone);
			var tmp_symbol:ByteArray = new ByteArray;
			this.symbol.writeToDataOutput(tmp_symbol);
			var size_tmp_symbol:int = tmp_symbol.length;
			output.writeInt(size_tmp_symbol);
			output.writeBytes(tmp_symbol);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_equip_size:int = input.readInt();
			if (byte_equip_size > 0) {				this.equip = new p_goods;
				var byte_equip:ByteArray = new ByteArray;
				input.readBytes(byte_equip, 0, byte_equip_size);
				this.equip.readFromDataOutput(byte_equip);
			}
			var byte_stone_size:int = input.readInt();
			if (byte_stone_size > 0) {				this.stone = new p_goods;
				var byte_stone:ByteArray = new ByteArray;
				input.readBytes(byte_stone, 0, byte_stone_size);
				this.stone.readFromDataOutput(byte_stone);
			}
			var byte_symbol_size:int = input.readInt();
			if (byte_symbol_size > 0) {				this.symbol = new p_goods;
				var byte_symbol:ByteArray = new ByteArray;
				input.readBytes(byte_symbol, 0, byte_symbol_size);
				this.symbol.readFromDataOutput(byte_symbol);
			}
			this.reason = input.readUTF();
		}
	}
}
