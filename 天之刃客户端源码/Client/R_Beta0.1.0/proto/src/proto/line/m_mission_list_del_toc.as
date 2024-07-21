package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_list_del_toc extends Message
	{
		public var missions:Array = new Array;
		public function m_mission_list_del_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_list_del_toc", m_mission_list_del_toc);
		}
		public override function getMethodName():String {
			return 'mission_list_del';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_missions:int = this.missions.length;
			output.writeShort(size_missions);
			var temp_repeated_byte_missions:ByteArray= new ByteArray;
			for(i=0; i<size_missions; i++) {
				var t2_missions:ByteArray = new ByteArray;
				var tVo_missions:p_mission_change = this.missions[i] as p_mission_change;
				tVo_missions.writeToDataOutput(t2_missions);
				var len_tVo_missions:int = t2_missions.length;
				temp_repeated_byte_missions.writeInt(len_tVo_missions);
				temp_repeated_byte_missions.writeBytes(t2_missions);
			}
			output.writeInt(temp_repeated_byte_missions.length);
			output.writeBytes(temp_repeated_byte_missions);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_missions:int = input.readShort();
			var length_missions:int = input.readInt();
			if (length_missions > 0) {
				var byte_missions:ByteArray = new ByteArray; 
				input.readBytes(byte_missions, 0, length_missions);
				for(i=0; i<size_missions; i++) {
					var tmp_missions:p_mission_change = new p_mission_change;
					var tmp_missions_length:int = byte_missions.readInt();
					var tmp_missions_byte:ByteArray = new ByteArray;
					byte_missions.readBytes(tmp_missions_byte, 0, tmp_missions_length);
					tmp_missions.readFromDataOutput(tmp_missions_byte);
					this.missions.push(tmp_missions);
				}
			}
		}
	}
}
