package proto.line {
	import proto.common.p_equip_onekey_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equiponekey_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var equips_list:Array = new Array;
		public var reason:String = "";
		public function m_equiponekey_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equiponekey_list_toc", m_equiponekey_list_toc);
		}
		public override function getMethodName():String {
			return 'equiponekey_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_equips_list:int = this.equips_list.length;
			output.writeShort(size_equips_list);
			var temp_repeated_byte_equips_list:ByteArray= new ByteArray;
			for(i=0; i<size_equips_list; i++) {
				var t2_equips_list:ByteArray = new ByteArray;
				var tVo_equips_list:p_equip_onekey_info = this.equips_list[i] as p_equip_onekey_info;
				tVo_equips_list.writeToDataOutput(t2_equips_list);
				var len_tVo_equips_list:int = t2_equips_list.length;
				temp_repeated_byte_equips_list.writeInt(len_tVo_equips_list);
				temp_repeated_byte_equips_list.writeBytes(t2_equips_list);
			}
			output.writeInt(temp_repeated_byte_equips_list.length);
			output.writeBytes(temp_repeated_byte_equips_list);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_equips_list:int = input.readShort();
			var length_equips_list:int = input.readInt();
			if (length_equips_list > 0) {
				var byte_equips_list:ByteArray = new ByteArray; 
				input.readBytes(byte_equips_list, 0, length_equips_list);
				for(i=0; i<size_equips_list; i++) {
					var tmp_equips_list:p_equip_onekey_info = new p_equip_onekey_info;
					var tmp_equips_list_length:int = byte_equips_list.readInt();
					var tmp_equips_list_byte:ByteArray = new ByteArray;
					byte_equips_list.readBytes(tmp_equips_list_byte, 0, tmp_equips_list_length);
					tmp_equips_list.readFromDataOutput(tmp_equips_list_byte);
					this.equips_list.push(tmp_equips_list);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
