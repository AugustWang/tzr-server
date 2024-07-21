package proto.common {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_onekey_info extends Message
	{
		public var equips_id:int = 0;
		public var equips_name:String = "";
		public var equips_list:Array = new Array;
		public var equips_id_list:Array = new Array;
		public function p_equip_onekey_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_onekey_info", p_equip_onekey_info);
		}
		public override function getMethodName():String {
			return 'equip_onekey_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equips_id);
			if (this.equips_name != null) {				output.writeUTF(this.equips_name.toString());
			} else {
				output.writeUTF("");
			}
			var size_equips_list:int = this.equips_list.length;
			output.writeShort(size_equips_list);
			var temp_repeated_byte_equips_list:ByteArray= new ByteArray;
			for(i=0; i<size_equips_list; i++) {
				var t2_equips_list:ByteArray = new ByteArray;
				var tVo_equips_list:p_goods = this.equips_list[i] as p_goods;
				tVo_equips_list.writeToDataOutput(t2_equips_list);
				var len_tVo_equips_list:int = t2_equips_list.length;
				temp_repeated_byte_equips_list.writeInt(len_tVo_equips_list);
				temp_repeated_byte_equips_list.writeBytes(t2_equips_list);
			}
			output.writeInt(temp_repeated_byte_equips_list.length);
			output.writeBytes(temp_repeated_byte_equips_list);
			var size_equips_id_list:int = this.equips_id_list.length;
			output.writeShort(size_equips_id_list);
			var temp_repeated_byte_equips_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_equips_id_list; i++) {
				var t2_equips_id_list:ByteArray = new ByteArray;
				var tVo_equips_id_list:p_equip_onekey_simple = this.equips_id_list[i] as p_equip_onekey_simple;
				tVo_equips_id_list.writeToDataOutput(t2_equips_id_list);
				var len_tVo_equips_id_list:int = t2_equips_id_list.length;
				temp_repeated_byte_equips_id_list.writeInt(len_tVo_equips_id_list);
				temp_repeated_byte_equips_id_list.writeBytes(t2_equips_id_list);
			}
			output.writeInt(temp_repeated_byte_equips_id_list.length);
			output.writeBytes(temp_repeated_byte_equips_id_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equips_id = input.readInt();
			this.equips_name = input.readUTF();
			var size_equips_list:int = input.readShort();
			var length_equips_list:int = input.readInt();
			if (length_equips_list > 0) {
				var byte_equips_list:ByteArray = new ByteArray; 
				input.readBytes(byte_equips_list, 0, length_equips_list);
				for(i=0; i<size_equips_list; i++) {
					var tmp_equips_list:p_goods = new p_goods;
					var tmp_equips_list_length:int = byte_equips_list.readInt();
					var tmp_equips_list_byte:ByteArray = new ByteArray;
					byte_equips_list.readBytes(tmp_equips_list_byte, 0, tmp_equips_list_length);
					tmp_equips_list.readFromDataOutput(tmp_equips_list_byte);
					this.equips_list.push(tmp_equips_list);
				}
			}
			var size_equips_id_list:int = input.readShort();
			var length_equips_id_list:int = input.readInt();
			if (length_equips_id_list > 0) {
				var byte_equips_id_list:ByteArray = new ByteArray; 
				input.readBytes(byte_equips_id_list, 0, length_equips_id_list);
				for(i=0; i<size_equips_id_list; i++) {
					var tmp_equips_id_list:p_equip_onekey_simple = new p_equip_onekey_simple;
					var tmp_equips_id_list_length:int = byte_equips_id_list.readInt();
					var tmp_equips_id_list_byte:ByteArray = new ByteArray;
					byte_equips_id_list.readBytes(tmp_equips_id_list_byte, 0, tmp_equips_id_list_length);
					tmp_equips_id_list.readFromDataOutput(tmp_equips_id_list_byte);
					this.equips_id_list.push(tmp_equips_id_list);
				}
			}
		}
	}
}
