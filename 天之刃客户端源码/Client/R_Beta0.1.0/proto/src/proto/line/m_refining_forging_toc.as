package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_forging_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var goods_list:Array = new Array;
		public var depletion_goods:Array = new Array;
		public function m_refining_forging_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_forging_toc", m_refining_forging_toc);
		}
		public override function getMethodName():String {
			return 'refining_forging';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
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
			var size_depletion_goods:int = this.depletion_goods.length;
			output.writeShort(size_depletion_goods);
			var temp_repeated_byte_depletion_goods:ByteArray= new ByteArray;
			for(i=0; i<size_depletion_goods; i++) {
				var t2_depletion_goods:ByteArray = new ByteArray;
				var tVo_depletion_goods:p_goods = this.depletion_goods[i] as p_goods;
				tVo_depletion_goods.writeToDataOutput(t2_depletion_goods);
				var len_tVo_depletion_goods:int = t2_depletion_goods.length;
				temp_repeated_byte_depletion_goods.writeInt(len_tVo_depletion_goods);
				temp_repeated_byte_depletion_goods.writeBytes(t2_depletion_goods);
			}
			output.writeInt(temp_repeated_byte_depletion_goods.length);
			output.writeBytes(temp_repeated_byte_depletion_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
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
			var size_depletion_goods:int = input.readShort();
			var length_depletion_goods:int = input.readInt();
			if (length_depletion_goods > 0) {
				var byte_depletion_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_depletion_goods, 0, length_depletion_goods);
				for(i=0; i<size_depletion_goods; i++) {
					var tmp_depletion_goods:p_goods = new p_goods;
					var tmp_depletion_goods_length:int = byte_depletion_goods.readInt();
					var tmp_depletion_goods_byte:ByteArray = new ByteArray;
					byte_depletion_goods.readBytes(tmp_depletion_goods_byte, 0, tmp_depletion_goods_length);
					tmp_depletion_goods.readFromDataOutput(tmp_depletion_goods_byte);
					this.depletion_goods.push(tmp_depletion_goods);
				}
			}
		}
	}
}
