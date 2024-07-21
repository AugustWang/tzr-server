package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_fix_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var equip_list:Array = new Array;
		public var silver:int = 0;
		public var bind_silver:int = 0;
		public function m_equip_fix_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_fix_toc", m_equip_fix_toc);
		}
		public override function getMethodName():String {
			return 'equip_fix';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_equip_list:int = this.equip_list.length;
			output.writeShort(size_equip_list);
			var temp_repeated_byte_equip_list:ByteArray= new ByteArray;
			for(i=0; i<size_equip_list; i++) {
				var t2_equip_list:ByteArray = new ByteArray;
				var tVo_equip_list:p_equip_endurance_info = this.equip_list[i] as p_equip_endurance_info;
				tVo_equip_list.writeToDataOutput(t2_equip_list);
				var len_tVo_equip_list:int = t2_equip_list.length;
				temp_repeated_byte_equip_list.writeInt(len_tVo_equip_list);
				temp_repeated_byte_equip_list.writeBytes(t2_equip_list);
			}
			output.writeInt(temp_repeated_byte_equip_list.length);
			output.writeBytes(temp_repeated_byte_equip_list);
			output.writeInt(this.silver);
			output.writeInt(this.bind_silver);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_equip_list:int = input.readShort();
			var length_equip_list:int = input.readInt();
			if (length_equip_list > 0) {
				var byte_equip_list:ByteArray = new ByteArray; 
				input.readBytes(byte_equip_list, 0, length_equip_list);
				for(i=0; i<size_equip_list; i++) {
					var tmp_equip_list:p_equip_endurance_info = new p_equip_endurance_info;
					var tmp_equip_list_length:int = byte_equip_list.readInt();
					var tmp_equip_list_byte:ByteArray = new ByteArray;
					byte_equip_list.readBytes(tmp_equip_list_byte, 0, tmp_equip_list_length);
					tmp_equip_list.readFromDataOutput(tmp_equip_list_byte);
					this.equip_list.push(tmp_equip_list);
				}
			}
			this.silver = input.readInt();
			this.bind_silver = input.readInt();
		}
	}
}
