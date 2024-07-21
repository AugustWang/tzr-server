package proto.line {
	import proto.line.p_mission_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_update_toc extends Message
	{
		public var del_mission_list:Array = new Array;
		public var update_mission_list:Array = new Array;
		public function m_mission_update_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_update_toc", m_mission_update_toc);
		}
		public override function getMethodName():String {
			return 'mission_update';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_del_mission_list:int = this.del_mission_list.length;
			output.writeShort(size_del_mission_list);
			var temp_repeated_byte_del_mission_list:ByteArray= new ByteArray;
			for(i=0; i<size_del_mission_list; i++) {
				temp_repeated_byte_del_mission_list.writeInt(this.del_mission_list[i]);
			}
			output.writeInt(temp_repeated_byte_del_mission_list.length);
			output.writeBytes(temp_repeated_byte_del_mission_list);
			var size_update_mission_list:int = this.update_mission_list.length;
			output.writeShort(size_update_mission_list);
			var temp_repeated_byte_update_mission_list:ByteArray= new ByteArray;
			for(i=0; i<size_update_mission_list; i++) {
				var t2_update_mission_list:ByteArray = new ByteArray;
				var tVo_update_mission_list:p_mission_info = this.update_mission_list[i] as p_mission_info;
				tVo_update_mission_list.writeToDataOutput(t2_update_mission_list);
				var len_tVo_update_mission_list:int = t2_update_mission_list.length;
				temp_repeated_byte_update_mission_list.writeInt(len_tVo_update_mission_list);
				temp_repeated_byte_update_mission_list.writeBytes(t2_update_mission_list);
			}
			output.writeInt(temp_repeated_byte_update_mission_list.length);
			output.writeBytes(temp_repeated_byte_update_mission_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_del_mission_list:int = input.readShort();
			var length_del_mission_list:int = input.readInt();
			var byte_del_mission_list:ByteArray = new ByteArray; 
			if (size_del_mission_list > 0) {
				input.readBytes(byte_del_mission_list, 0, size_del_mission_list * 4);
				for(i=0; i<size_del_mission_list; i++) {
					var tmp_del_mission_list:int = byte_del_mission_list.readInt();
					this.del_mission_list.push(tmp_del_mission_list);
				}
			}
			var size_update_mission_list:int = input.readShort();
			var length_update_mission_list:int = input.readInt();
			if (length_update_mission_list > 0) {
				var byte_update_mission_list:ByteArray = new ByteArray; 
				input.readBytes(byte_update_mission_list, 0, length_update_mission_list);
				for(i=0; i<size_update_mission_list; i++) {
					var tmp_update_mission_list:p_mission_info = new p_mission_info;
					var tmp_update_mission_list_length:int = byte_update_mission_list.readInt();
					var tmp_update_mission_list_byte:ByteArray = new ByteArray;
					byte_update_mission_list.readBytes(tmp_update_mission_list_byte, 0, tmp_update_mission_list_length);
					tmp_update_mission_list.readFromDataOutput(tmp_update_mission_list_byte);
					this.update_mission_list.push(tmp_update_mission_list);
				}
			}
		}
	}
}
