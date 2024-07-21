package proto.line {
	import proto.common.p_goods;
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_fiveele_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var equip:p_goods = null;
		public var five_good:p_equip_build_goods = null;
		public var add_list:Array = new Array;
		public var used_good:p_equip_build_goods = null;
		public function m_equip_build_fiveele_toc() {
			super();
			this.equip = new p_goods;
			this.five_good = new p_equip_build_goods;
			this.used_good = new p_equip_build_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_fiveele_toc", m_equip_build_fiveele_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_fiveele';
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
			var tmp_five_good:ByteArray = new ByteArray;
			this.five_good.writeToDataOutput(tmp_five_good);
			var size_tmp_five_good:int = tmp_five_good.length;
			output.writeInt(size_tmp_five_good);
			output.writeBytes(tmp_five_good);
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
			var tmp_used_good:ByteArray = new ByteArray;
			this.used_good.writeToDataOutput(tmp_used_good);
			var size_tmp_used_good:int = tmp_used_good.length;
			output.writeInt(size_tmp_used_good);
			output.writeBytes(tmp_used_good);
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
			var byte_five_good_size:int = input.readInt();
			if (byte_five_good_size > 0) {				this.five_good = new p_equip_build_goods;
				var byte_five_good:ByteArray = new ByteArray;
				input.readBytes(byte_five_good, 0, byte_five_good_size);
				this.five_good.readFromDataOutput(byte_five_good);
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
			var byte_used_good_size:int = input.readInt();
			if (byte_used_good_size > 0) {				this.used_good = new p_equip_build_goods;
				var byte_used_good:ByteArray = new ByteArray;
				input.readBytes(byte_used_good, 0, byte_used_good_size);
				this.used_good.readFromDataOutput(byte_used_good);
			}
		}
	}
}
