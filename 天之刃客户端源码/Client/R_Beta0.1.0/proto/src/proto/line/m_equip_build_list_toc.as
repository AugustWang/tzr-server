package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var build_level:int = 1;
		public var build_list:Array = new Array;
		public function m_equip_build_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_list_toc", m_equip_build_list_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_list';
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
		}
	}
}
