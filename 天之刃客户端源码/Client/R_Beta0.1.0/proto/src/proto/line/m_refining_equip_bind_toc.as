package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_equip_bind_toc extends Message
	{
		public var succ:Boolean = true;
		public var type:int = 0;
		public var reason:String = "";
		public var equip_goods:p_goods = null;
		public var bind_goods:Array = new Array;
		public var depletion_goods:p_goods = null;
		public function m_refining_equip_bind_toc() {
			super();
			this.equip_goods = new p_goods;
			this.depletion_goods = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_refining_equip_bind_toc", m_refining_equip_bind_toc);
		}
		public override function getMethodName():String {
			return 'refining_equip_bind';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_equip_goods:ByteArray = new ByteArray;
			this.equip_goods.writeToDataOutput(tmp_equip_goods);
			var size_tmp_equip_goods:int = tmp_equip_goods.length;
			output.writeInt(size_tmp_equip_goods);
			output.writeBytes(tmp_equip_goods);
			var size_bind_goods:int = this.bind_goods.length;
			output.writeShort(size_bind_goods);
			var temp_repeated_byte_bind_goods:ByteArray= new ByteArray;
			for(i=0; i<size_bind_goods; i++) {
				var t2_bind_goods:ByteArray = new ByteArray;
				var tVo_bind_goods:p_goods = this.bind_goods[i] as p_goods;
				tVo_bind_goods.writeToDataOutput(t2_bind_goods);
				var len_tVo_bind_goods:int = t2_bind_goods.length;
				temp_repeated_byte_bind_goods.writeInt(len_tVo_bind_goods);
				temp_repeated_byte_bind_goods.writeBytes(t2_bind_goods);
			}
			output.writeInt(temp_repeated_byte_bind_goods.length);
			output.writeBytes(temp_repeated_byte_bind_goods);
			var tmp_depletion_goods:ByteArray = new ByteArray;
			this.depletion_goods.writeToDataOutput(tmp_depletion_goods);
			var size_tmp_depletion_goods:int = tmp_depletion_goods.length;
			output.writeInt(size_tmp_depletion_goods);
			output.writeBytes(tmp_depletion_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.type = input.readInt();
			this.reason = input.readUTF();
			var byte_equip_goods_size:int = input.readInt();
			if (byte_equip_goods_size > 0) {				this.equip_goods = new p_goods;
				var byte_equip_goods:ByteArray = new ByteArray;
				input.readBytes(byte_equip_goods, 0, byte_equip_goods_size);
				this.equip_goods.readFromDataOutput(byte_equip_goods);
			}
			var size_bind_goods:int = input.readShort();
			var length_bind_goods:int = input.readInt();
			if (length_bind_goods > 0) {
				var byte_bind_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_bind_goods, 0, length_bind_goods);
				for(i=0; i<size_bind_goods; i++) {
					var tmp_bind_goods:p_goods = new p_goods;
					var tmp_bind_goods_length:int = byte_bind_goods.readInt();
					var tmp_bind_goods_byte:ByteArray = new ByteArray;
					byte_bind_goods.readBytes(tmp_bind_goods_byte, 0, tmp_bind_goods_length);
					tmp_bind_goods.readFromDataOutput(tmp_bind_goods_byte);
					this.bind_goods.push(tmp_bind_goods);
				}
			}
			var byte_depletion_goods_size:int = input.readInt();
			if (byte_depletion_goods_size > 0) {				this.depletion_goods = new p_goods;
				var byte_depletion_goods:ByteArray = new ByteArray;
				input.readBytes(byte_depletion_goods, 0, byte_depletion_goods_size);
				this.depletion_goods.readFromDataOutput(byte_depletion_goods);
			}
		}
	}
}
