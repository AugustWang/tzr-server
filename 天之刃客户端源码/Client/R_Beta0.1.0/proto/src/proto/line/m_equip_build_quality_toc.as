package proto.line {
	import proto.common.p_goods;
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_quality_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var equip:p_goods = null;
		public var add_list:Array = new Array;
		public var add_goods:p_equip_build_goods = null;
		public function m_equip_build_quality_toc() {
			super();
			this.equip = new p_goods;
			this.add_goods = new p_equip_build_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_quality_toc", m_equip_build_quality_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_quality';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_equip:ByteArray = new ByteArray;
			this.equip.writeToDataOutput(tmp_equip);
			var size_tmp_equip:int = tmp_equip.length;
			output.writeInt(size_tmp_equip);
			output.writeBytes(tmp_equip);
			var size_add_list:int = this.add_list.length;
			output.writeShort(size_add_list);
			var temp_repeated_byte_add_list:ByteArray= new ByteArray;
			for(i=0; i<size_add_list; i++) {
				var t2_add_list:ByteArray = new ByteArray;
				var tVo_add_list:p_equip_build_goods = this.add_list[i] as p_equip_build_goods;
				tVo_add_list.writeToDataOutput(t2_add_list);
				var len_tVo_add_list:int = t2_add_list.length;
				temp_repeated_byte_add_list.writeInt(len_tVo_add_list);
				temp_repeated_byte_add_list.writeBytes(t2_add_list);
			}
			output.writeInt(temp_repeated_byte_add_list.length);
			output.writeBytes(temp_repeated_byte_add_list);
			var tmp_add_goods:ByteArray = new ByteArray;
			this.add_goods.writeToDataOutput(tmp_add_goods);
			var size_tmp_add_goods:int = tmp_add_goods.length;
			output.writeInt(size_tmp_add_goods);
			output.writeBytes(tmp_add_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_equip_size:int = input.readInt();
			if (byte_equip_size > 0) {				this.equip = new p_goods;
				var byte_equip:ByteArray = new ByteArray;
				input.readBytes(byte_equip, 0, byte_equip_size);
				this.equip.readFromDataOutput(byte_equip);
			}
			var size_add_list:int = input.readShort();
			var length_add_list:int = input.readInt();
			if (length_add_list > 0) {
				var byte_add_list:ByteArray = new ByteArray; 
				input.readBytes(byte_add_list, 0, length_add_list);
				for(i=0; i<size_add_list; i++) {
					var tmp_add_list:p_equip_build_goods = new p_equip_build_goods;
					var tmp_add_list_length:int = byte_add_list.readInt();
					var tmp_add_list_byte:ByteArray = new ByteArray;
					byte_add_list.readBytes(tmp_add_list_byte, 0, tmp_add_list_length);
					tmp_add_list.readFromDataOutput(tmp_add_list_byte);
					this.add_list.push(tmp_add_list);
				}
			}
			var byte_add_goods_size:int = input.readInt();
			if (byte_add_goods_size > 0) {				this.add_goods = new p_equip_build_goods;
				var byte_add_goods:ByteArray = new ByteArray;
				input.readBytes(byte_add_goods, 0, byte_add_goods_size);
				this.add_goods.readFromDataOutput(byte_add_goods);
			}
		}
	}
}
