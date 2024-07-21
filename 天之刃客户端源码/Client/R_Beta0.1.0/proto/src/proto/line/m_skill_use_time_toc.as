package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_skill_use_time_toc extends Message
	{
		public var skill_time:Array = new Array;
		public var server_time:int = 0;
		public function m_skill_use_time_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_skill_use_time_toc", m_skill_use_time_toc);
		}
		public override function getMethodName():String {
			return 'skill_use_time';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_skill_time:int = this.skill_time.length;
			output.writeShort(size_skill_time);
			var temp_repeated_byte_skill_time:ByteArray= new ByteArray;
			for(i=0; i<size_skill_time; i++) {
				var t2_skill_time:ByteArray = new ByteArray;
				var tVo_skill_time:p_skill_time = this.skill_time[i] as p_skill_time;
				tVo_skill_time.writeToDataOutput(t2_skill_time);
				var len_tVo_skill_time:int = t2_skill_time.length;
				temp_repeated_byte_skill_time.writeInt(len_tVo_skill_time);
				temp_repeated_byte_skill_time.writeBytes(t2_skill_time);
			}
			output.writeInt(temp_repeated_byte_skill_time.length);
			output.writeBytes(temp_repeated_byte_skill_time);
			output.writeInt(this.server_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_skill_time:int = input.readShort();
			var length_skill_time:int = input.readInt();
			if (length_skill_time > 0) {
				var byte_skill_time:ByteArray = new ByteArray; 
				input.readBytes(byte_skill_time, 0, length_skill_time);
				for(i=0; i<size_skill_time; i++) {
					var tmp_skill_time:p_skill_time = new p_skill_time;
					var tmp_skill_time_length:int = byte_skill_time.readInt();
					var tmp_skill_time_byte:ByteArray = new ByteArray;
					byte_skill_time.readBytes(tmp_skill_time_byte, 0, tmp_skill_time_length);
					tmp_skill_time.readFromDataOutput(tmp_skill_time_byte);
					this.skill_time.push(tmp_skill_time);
				}
			}
			this.server_time = input.readInt();
		}
	}
}
