package proto.line {
	import proto.common.p_map_trap;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trap_enter_toc extends Message
	{
		public var trap_list:Array = new Array;
		public function m_trap_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trap_enter_toc", m_trap_enter_toc);
		}
		public override function getMethodName():String {
			return 'trap_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_trap_list:int = this.trap_list.length;
			output.writeShort(size_trap_list);
			var temp_repeated_byte_trap_list:ByteArray= new ByteArray;
			for(i=0; i<size_trap_list; i++) {
				var t2_trap_list:ByteArray = new ByteArray;
				var tVo_trap_list:p_map_trap = this.trap_list[i] as p_map_trap;
				tVo_trap_list.writeToDataOutput(t2_trap_list);
				var len_tVo_trap_list:int = t2_trap_list.length;
				temp_repeated_byte_trap_list.writeInt(len_tVo_trap_list);
				temp_repeated_byte_trap_list.writeBytes(t2_trap_list);
			}
			output.writeInt(temp_repeated_byte_trap_list.length);
			output.writeBytes(temp_repeated_byte_trap_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_trap_list:int = input.readShort();
			var length_trap_list:int = input.readInt();
			if (length_trap_list > 0) {
				var byte_trap_list:ByteArray = new ByteArray; 
				input.readBytes(byte_trap_list, 0, length_trap_list);
				for(i=0; i<size_trap_list; i++) {
					var tmp_trap_list:p_map_trap = new p_map_trap;
					var tmp_trap_list_length:int = byte_trap_list.readInt();
					var tmp_trap_list_byte:ByteArray = new ByteArray;
					byte_trap_list.readBytes(tmp_trap_list_byte, 0, tmp_trap_list_length);
					tmp_trap_list.readFromDataOutput(tmp_trap_list_byte);
					this.trap_list.push(tmp_trap_list);
				}
			}
		}
	}
}
