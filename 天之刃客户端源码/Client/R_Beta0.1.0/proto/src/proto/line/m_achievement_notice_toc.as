package proto.line {
	import proto.common.p_achievement_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_achievement_notice_toc extends Message
	{
		public var type:int = 0;
		public var achievements:Array = new Array;
		public var total_points:int = 0;
		public function m_achievement_notice_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_achievement_notice_toc", m_achievement_notice_toc);
		}
		public override function getMethodName():String {
			return 'achievement_notice';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			var size_achievements:int = this.achievements.length;
			output.writeShort(size_achievements);
			var temp_repeated_byte_achievements:ByteArray= new ByteArray;
			for(i=0; i<size_achievements; i++) {
				var t2_achievements:ByteArray = new ByteArray;
				var tVo_achievements:p_achievement_info = this.achievements[i] as p_achievement_info;
				tVo_achievements.writeToDataOutput(t2_achievements);
				var len_tVo_achievements:int = t2_achievements.length;
				temp_repeated_byte_achievements.writeInt(len_tVo_achievements);
				temp_repeated_byte_achievements.writeBytes(t2_achievements);
			}
			output.writeInt(temp_repeated_byte_achievements.length);
			output.writeBytes(temp_repeated_byte_achievements);
			output.writeInt(this.total_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			var size_achievements:int = input.readShort();
			var length_achievements:int = input.readInt();
			if (length_achievements > 0) {
				var byte_achievements:ByteArray = new ByteArray; 
				input.readBytes(byte_achievements, 0, length_achievements);
				for(i=0; i<size_achievements; i++) {
					var tmp_achievements:p_achievement_info = new p_achievement_info;
					var tmp_achievements_length:int = byte_achievements.readInt();
					var tmp_achievements_byte:ByteArray = new ByteArray;
					byte_achievements.readBytes(tmp_achievements_byte, 0, tmp_achievements_length);
					tmp_achievements.readFromDataOutput(tmp_achievements_byte);
					this.achievements.push(tmp_achievements);
				}
			}
			this.total_points = input.readInt();
		}
	}
}
