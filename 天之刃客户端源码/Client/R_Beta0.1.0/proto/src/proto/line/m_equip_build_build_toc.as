package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_build_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var build_level:int = 1;
		public var build_list:Array = new Array;
		public var base_list:Array = new Array;
		public var add_list:Array = new Array;
		public var new_equip:p_equip_build_goods = null;
		public var base_goods:p_equip_build_goods = null;
		public var add_goods:p_equip_build_goods = null;
		public function m_equip_build_build_toc() {
			super();
			this.new_equip = new p_equip_build_goods;
			this.base_goods = new p_equip_build_goods;
			this.add_goods = new p_equip_build_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_build_toc", m_equip_build_build_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_build';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.build_level);
			var size_build_list:int = this.build_list.length;
			output.writeShort(size_build_list);
			var temp_repeated_byte_build_list:ByteArray= new ByteArray;
			for(i=0; i<size_build_list; i++) {
				var t2_build_list:ByteArray = new ByteArray;
				var tVo_build_list:p_equip_build_equip = this.build_list[i] as p_equip_build_equip;
				tVo_build_list.writeToDataOutput(t2_build_list);
				var len_tVo_build_list:int = t2_build_list.length;
				temp_repeated_byte_build_list.writeInt(len_tVo_build_list);
				temp_repeated_byte_build_list.writeBytes(t2_build_list);
			}
			output.writeInt(temp_repeated_byte_build_list.length);
			output.writeBytes(temp_repeated_byte_build_list);
			var size_base_list:int = this.base_list.length;
			output.writeShort(size_base_list);
			var temp_repeated_byte_base_list:ByteArray= new ByteArray;
			for(i=0; i<size_base_list; i++) {
				var t2_base_list:ByteArray = new ByteArray;
				var tVo_base_list:p_equip_build_goods = this.base_list[i] as p_equip_build_goods;
				tVo_base_list.writeToDataOutput(t2_base_list);
				var len_tVo_base_list:int = t2_base_list.length;
				temp_repeated_byte_base_list.writeInt(len_tVo_base_list);
				temp_repeated_byte_base_list.writeBytes(t2_base_list);
			}
			output.writeInt(temp_repeated_byte_base_list.length);
			output.writeBytes(temp_repeated_byte_base_list);
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
			var tmp_new_equip:ByteArray = new ByteArray;
			this.new_equip.writeToDataOutput(tmp_new_equip);
			var size_tmp_new_equip:int = tmp_new_equip.length;
			output.writeInt(size_tmp_new_equip);
			output.writeBytes(tmp_new_equip);
			var tmp_base_goods:ByteArray = new ByteArray;
			this.base_goods.writeToDataOutput(tmp_base_goods);
			var size_tmp_base_goods:int = tmp_base_goods.length;
			output.writeInt(size_tmp_base_goods);
			output.writeBytes(tmp_base_goods);
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
			this.build_level = input.readInt();
			var size_build_list:int = input.readShort();
			var length_build_list:int = input.readInt();
			if (length_build_list > 0) {
				var byte_build_list:ByteArray = new ByteArray; 
				input.readBytes(byte_build_list, 0, length_build_list);
				for(i=0; i<size_build_list; i++) {
					var tmp_build_list:p_equip_build_equip = new p_equip_build_equip;
					var tmp_build_list_length:int = byte_build_list.readInt();
					var tmp_build_list_byte:ByteArray = new ByteArray;
					byte_build_list.readBytes(tmp_build_list_byte, 0, tmp_build_list_length);
					tmp_build_list.readFromDataOutput(tmp_build_list_byte);
					this.build_list.push(tmp_build_list);
				}
			}
			var size_base_list:int = input.readShort();
			var length_base_list:int = input.readInt();
			if (length_base_list > 0) {
				var byte_base_list:ByteArray = new ByteArray; 
				input.readBytes(byte_base_list, 0, length_base_list);
				for(i=0; i<size_base_list; i++) {
					var tmp_base_list:p_equip_build_goods = new p_equip_build_goods;
					var tmp_base_list_length:int = byte_base_list.readInt();
					var tmp_base_list_byte:ByteArray = new ByteArray;
					byte_base_list.readBytes(tmp_base_list_byte, 0, tmp_base_list_length);
					tmp_base_list.readFromDataOutput(tmp_base_list_byte);
					this.base_list.push(tmp_base_list);
				}
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
			var byte_new_equip_size:int = input.readInt();
			if (byte_new_equip_size > 0) {				this.new_equip = new p_equip_build_goods;
				var byte_new_equip:ByteArray = new ByteArray;
				input.readBytes(byte_new_equip, 0, byte_new_equip_size);
				this.new_equip.readFromDataOutput(byte_new_equip);
			}
			var byte_base_goods_size:int = input.readInt();
			if (byte_base_goods_size > 0) {				this.base_goods = new p_equip_build_goods;
				var byte_base_goods:ByteArray = new ByteArray;
				input.readBytes(byte_base_goods, 0, byte_base_goods_size);
				this.base_goods.readFromDataOutput(byte_base_goods);
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
