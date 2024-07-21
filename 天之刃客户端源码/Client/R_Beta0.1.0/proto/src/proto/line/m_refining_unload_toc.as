package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_unload_toc extends Message
	{
		public var succ:Boolean = true;
		public var equip:p_goods = null;
		public var deplete_symbol:Array = new Array;
		public var delete_symbol:Array = new Array;
		public var stones:Array = new Array;
		public var delete_stones:Array = new Array;
		public var reason:String = "";
		public function m_refining_unload_toc() {
			super();
			this.equip = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_refining_unload_toc", m_refining_unload_toc);
		}
		public override function getMethodName():String {
			return 'refining_unload';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_equip:ByteArray = new ByteArray;
			this.equip.writeToDataOutput(tmp_equip);
			var size_tmp_equip:int = tmp_equip.length;
			output.writeInt(size_tmp_equip);
			output.writeBytes(tmp_equip);
			var size_deplete_symbol:int = this.deplete_symbol.length;
			output.writeShort(size_deplete_symbol);
			var temp_repeated_byte_deplete_symbol:ByteArray= new ByteArray;
			for(i=0; i<size_deplete_symbol; i++) {
				var t2_deplete_symbol:ByteArray = new ByteArray;
				var tVo_deplete_symbol:p_goods = this.deplete_symbol[i] as p_goods;
				tVo_deplete_symbol.writeToDataOutput(t2_deplete_symbol);
				var len_tVo_deplete_symbol:int = t2_deplete_symbol.length;
				temp_repeated_byte_deplete_symbol.writeInt(len_tVo_deplete_symbol);
				temp_repeated_byte_deplete_symbol.writeBytes(t2_deplete_symbol);
			}
			output.writeInt(temp_repeated_byte_deplete_symbol.length);
			output.writeBytes(temp_repeated_byte_deplete_symbol);
			var size_delete_symbol:int = this.delete_symbol.length;
			output.writeShort(size_delete_symbol);
			var temp_repeated_byte_delete_symbol:ByteArray= new ByteArray;
			for(i=0; i<size_delete_symbol; i++) {
				var t2_delete_symbol:ByteArray = new ByteArray;
				var tVo_delete_symbol:p_goods = this.delete_symbol[i] as p_goods;
				tVo_delete_symbol.writeToDataOutput(t2_delete_symbol);
				var len_tVo_delete_symbol:int = t2_delete_symbol.length;
				temp_repeated_byte_delete_symbol.writeInt(len_tVo_delete_symbol);
				temp_repeated_byte_delete_symbol.writeBytes(t2_delete_symbol);
			}
			output.writeInt(temp_repeated_byte_delete_symbol.length);
			output.writeBytes(temp_repeated_byte_delete_symbol);
			var size_stones:int = this.stones.length;
			output.writeShort(size_stones);
			var temp_repeated_byte_stones:ByteArray= new ByteArray;
			for(i=0; i<size_stones; i++) {
				var t2_stones:ByteArray = new ByteArray;
				var tVo_stones:p_goods = this.stones[i] as p_goods;
				tVo_stones.writeToDataOutput(t2_stones);
				var len_tVo_stones:int = t2_stones.length;
				temp_repeated_byte_stones.writeInt(len_tVo_stones);
				temp_repeated_byte_stones.writeBytes(t2_stones);
			}
			output.writeInt(temp_repeated_byte_stones.length);
			output.writeBytes(temp_repeated_byte_stones);
			var size_delete_stones:int = this.delete_stones.length;
			output.writeShort(size_delete_stones);
			var temp_repeated_byte_delete_stones:ByteArray= new ByteArray;
			for(i=0; i<size_delete_stones; i++) {
				var t2_delete_stones:ByteArray = new ByteArray;
				var tVo_delete_stones:p_goods = this.delete_stones[i] as p_goods;
				tVo_delete_stones.writeToDataOutput(t2_delete_stones);
				var len_tVo_delete_stones:int = t2_delete_stones.length;
				temp_repeated_byte_delete_stones.writeInt(len_tVo_delete_stones);
				temp_repeated_byte_delete_stones.writeBytes(t2_delete_stones);
			}
			output.writeInt(temp_repeated_byte_delete_stones.length);
			output.writeBytes(temp_repeated_byte_delete_stones);
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
			var size_deplete_symbol:int = input.readShort();
			var length_deplete_symbol:int = input.readInt();
			if (length_deplete_symbol > 0) {
				var byte_deplete_symbol:ByteArray = new ByteArray; 
				input.readBytes(byte_deplete_symbol, 0, length_deplete_symbol);
				for(i=0; i<size_deplete_symbol; i++) {
					var tmp_deplete_symbol:p_goods = new p_goods;
					var tmp_deplete_symbol_length:int = byte_deplete_symbol.readInt();
					var tmp_deplete_symbol_byte:ByteArray = new ByteArray;
					byte_deplete_symbol.readBytes(tmp_deplete_symbol_byte, 0, tmp_deplete_symbol_length);
					tmp_deplete_symbol.readFromDataOutput(tmp_deplete_symbol_byte);
					this.deplete_symbol.push(tmp_deplete_symbol);
				}
			}
			var size_delete_symbol:int = input.readShort();
			var length_delete_symbol:int = input.readInt();
			if (length_delete_symbol > 0) {
				var byte_delete_symbol:ByteArray = new ByteArray; 
				input.readBytes(byte_delete_symbol, 0, length_delete_symbol);
				for(i=0; i<size_delete_symbol; i++) {
					var tmp_delete_symbol:p_goods = new p_goods;
					var tmp_delete_symbol_length:int = byte_delete_symbol.readInt();
					var tmp_delete_symbol_byte:ByteArray = new ByteArray;
					byte_delete_symbol.readBytes(tmp_delete_symbol_byte, 0, tmp_delete_symbol_length);
					tmp_delete_symbol.readFromDataOutput(tmp_delete_symbol_byte);
					this.delete_symbol.push(tmp_delete_symbol);
				}
			}
			var size_stones:int = input.readShort();
			var length_stones:int = input.readInt();
			if (length_stones > 0) {
				var byte_stones:ByteArray = new ByteArray; 
				input.readBytes(byte_stones, 0, length_stones);
				for(i=0; i<size_stones; i++) {
					var tmp_stones:p_goods = new p_goods;
					var tmp_stones_length:int = byte_stones.readInt();
					var tmp_stones_byte:ByteArray = new ByteArray;
					byte_stones.readBytes(tmp_stones_byte, 0, tmp_stones_length);
					tmp_stones.readFromDataOutput(tmp_stones_byte);
					this.stones.push(tmp_stones);
				}
			}
			var size_delete_stones:int = input.readShort();
			var length_delete_stones:int = input.readInt();
			if (length_delete_stones > 0) {
				var byte_delete_stones:ByteArray = new ByteArray; 
				input.readBytes(byte_delete_stones, 0, length_delete_stones);
				for(i=0; i<size_delete_stones; i++) {
					var tmp_delete_stones:p_goods = new p_goods;
					var tmp_delete_stones_length:int = byte_delete_stones.readInt();
					var tmp_delete_stones_byte:ByteArray = new ByteArray;
					byte_delete_stones.readBytes(tmp_delete_stones_byte, 0, tmp_delete_stones_length);
					tmp_delete_stones.readFromDataOutput(tmp_delete_stones_byte);
					this.delete_stones.push(tmp_delete_stones);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
