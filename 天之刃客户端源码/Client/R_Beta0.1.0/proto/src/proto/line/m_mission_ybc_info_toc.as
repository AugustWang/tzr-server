package proto.line {
	import proto.line.p_mission_ybc_award_attr;
	import proto.line.p_mission_ybc_award_prop;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_ybc_info_toc extends Message
	{
		public var mission_id:int = 0;
		public var status:int = 0;
		public var color:int = 0;
		public var remain_time:int = 0;
		public var attr_award:Array = new Array;
		public var prop_award:Array = new Array;
		public function m_mission_ybc_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_ybc_info_toc", m_mission_ybc_info_toc);
		}
		public override function getMethodName():String {
			return 'mission_ybc_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mission_id);
			output.writeInt(this.status);
			output.writeInt(this.color);
			output.writeInt(this.remain_time);
			var size_attr_award:int = this.attr_award.length;
			output.writeShort(size_attr_award);
			var temp_repeated_byte_attr_award:ByteArray= new ByteArray;
			for(i=0; i<size_attr_award; i++) {
				var t2_attr_award:ByteArray = new ByteArray;
				var tVo_attr_award:p_mission_ybc_award_attr = this.attr_award[i] as p_mission_ybc_award_attr;
				tVo_attr_award.writeToDataOutput(t2_attr_award);
				var len_tVo_attr_award:int = t2_attr_award.length;
				temp_repeated_byte_attr_award.writeInt(len_tVo_attr_award);
				temp_repeated_byte_attr_award.writeBytes(t2_attr_award);
			}
			output.writeInt(temp_repeated_byte_attr_award.length);
			output.writeBytes(temp_repeated_byte_attr_award);
			var size_prop_award:int = this.prop_award.length;
			output.writeShort(size_prop_award);
			var temp_repeated_byte_prop_award:ByteArray= new ByteArray;
			for(i=0; i<size_prop_award; i++) {
				var t2_prop_award:ByteArray = new ByteArray;
				var tVo_prop_award:p_mission_ybc_award_prop = this.prop_award[i] as p_mission_ybc_award_prop;
				tVo_prop_award.writeToDataOutput(t2_prop_award);
				var len_tVo_prop_award:int = t2_prop_award.length;
				temp_repeated_byte_prop_award.writeInt(len_tVo_prop_award);
				temp_repeated_byte_prop_award.writeBytes(t2_prop_award);
			}
			output.writeInt(temp_repeated_byte_prop_award.length);
			output.writeBytes(temp_repeated_byte_prop_award);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mission_id = input.readInt();
			this.status = input.readInt();
			this.color = input.readInt();
			this.remain_time = input.readInt();
			var size_attr_award:int = input.readShort();
			var length_attr_award:int = input.readInt();
			if (length_attr_award > 0) {
				var byte_attr_award:ByteArray = new ByteArray; 
				input.readBytes(byte_attr_award, 0, length_attr_award);
				for(i=0; i<size_attr_award; i++) {
					var tmp_attr_award:p_mission_ybc_award_attr = new p_mission_ybc_award_attr;
					var tmp_attr_award_length:int = byte_attr_award.readInt();
					var tmp_attr_award_byte:ByteArray = new ByteArray;
					byte_attr_award.readBytes(tmp_attr_award_byte, 0, tmp_attr_award_length);
					tmp_attr_award.readFromDataOutput(tmp_attr_award_byte);
					this.attr_award.push(tmp_attr_award);
				}
			}
			var size_prop_award:int = input.readShort();
			var length_prop_award:int = input.readInt();
			if (length_prop_award > 0) {
				var byte_prop_award:ByteArray = new ByteArray; 
				input.readBytes(byte_prop_award, 0, length_prop_award);
				for(i=0; i<size_prop_award; i++) {
					var tmp_prop_award:p_mission_ybc_award_prop = new p_mission_ybc_award_prop;
					var tmp_prop_award_length:int = byte_prop_award.readInt();
					var tmp_prop_award_byte:ByteArray = new ByteArray;
					byte_prop_award.readBytes(tmp_prop_award_byte, 0, tmp_prop_award_length);
					tmp_prop_award.readFromDataOutput(tmp_prop_award_byte);
					this.prop_award.push(tmp_prop_award);
				}
			}
		}
	}
}
