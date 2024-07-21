package proto.line {
	import proto.line.p_mission_auto;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_list_auto_toc extends Message
	{
		public var list:Array = new Array;
		public function m_mission_list_auto_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_list_auto_toc", m_mission_list_auto_toc);
		}
		public override function getMethodName():String {
			return 'mission_list_auto';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_list:int = this.list.length;
			output.writeShort(size_list);
			var temp_repeated_byte_list:ByteArray= new ByteArray;
			for(i=0; i<size_list; i++) {
				var t2_list:ByteArray = new ByteArray;
				var tVo_list:p_mission_auto = this.list[i] as p_mission_auto;
				tVo_list.writeToDataOutput(t2_list);
				var len_tVo_list:int = t2_list.length;
				temp_repeated_byte_list.writeInt(len_tVo_list);
				temp_repeated_byte_list.writeBytes(t2_list);
			}
			output.writeInt(temp_repeated_byte_list.length);
			output.writeBytes(temp_repeated_byte_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_list:int = input.readShort();
			var length_list:int = input.readInt();
			if (length_list > 0) {
				var byte_list:ByteArray = new ByteArray; 
				input.readBytes(byte_list, 0, length_list);
				for(i=0; i<size_list; i++) {
					var tmp_list:p_mission_auto = new p_mission_auto;
					var tmp_list_length:int = byte_list.readInt();
					var tmp_list_byte:ByteArray = new ByteArray;
					byte_list.readBytes(tmp_list_byte, 0, tmp_list_length);
					tmp_list.readFromDataOutput(tmp_list_byte);
					this.list.push(tmp_list);
				}
			}
		}
	}
}
