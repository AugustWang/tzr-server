package proto.line {
	import proto.line.p_shortcut;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shortcut_update_tos extends Message
	{
		public var shortcut_list:Array = new Array;
		public var selected:int = 0;
		public function m_shortcut_update_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shortcut_update_tos", m_shortcut_update_tos);
		}
		public override function getMethodName():String {
			return 'shortcut_update';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_shortcut_list:int = this.shortcut_list.length;
			output.writeShort(size_shortcut_list);
			var temp_repeated_byte_shortcut_list:ByteArray= new ByteArray;
			for(i=0; i<size_shortcut_list; i++) {
				var t2_shortcut_list:ByteArray = new ByteArray;
				var tVo_shortcut_list:p_shortcut = this.shortcut_list[i] as p_shortcut;
				tVo_shortcut_list.writeToDataOutput(t2_shortcut_list);
				var len_tVo_shortcut_list:int = t2_shortcut_list.length;
				temp_repeated_byte_shortcut_list.writeInt(len_tVo_shortcut_list);
				temp_repeated_byte_shortcut_list.writeBytes(t2_shortcut_list);
			}
			output.writeInt(temp_repeated_byte_shortcut_list.length);
			output.writeBytes(temp_repeated_byte_shortcut_list);
			output.writeInt(this.selected);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_shortcut_list:int = input.readShort();
			var length_shortcut_list:int = input.readInt();
			if (length_shortcut_list > 0) {
				var byte_shortcut_list:ByteArray = new ByteArray; 
				input.readBytes(byte_shortcut_list, 0, length_shortcut_list);
				for(i=0; i<size_shortcut_list; i++) {
					var tmp_shortcut_list:p_shortcut = new p_shortcut;
					var tmp_shortcut_list_length:int = byte_shortcut_list.readInt();
					var tmp_shortcut_list_byte:ByteArray = new ByteArray;
					byte_shortcut_list.readBytes(tmp_shortcut_list_byte, 0, tmp_shortcut_list_length);
					tmp_shortcut_list.readFromDataOutput(tmp_shortcut_list_byte);
					this.shortcut_list.push(tmp_shortcut_list);
				}
			}
			this.selected = input.readInt();
		}
	}
}
