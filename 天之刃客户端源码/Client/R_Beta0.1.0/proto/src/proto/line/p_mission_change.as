package proto.line {
	import proto.line.p_mission_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_change extends Message
	{
		public var mission_id:int = 0;
		public var mission_info:p_mission_info = null;
		public var status:int = 0;
		public function p_mission_change() {
			super();
			this.mission_info = new p_mission_info;

			flash.net.registerClassAlias("copy.proto.line.p_mission_change", p_mission_change);
		}
		public override function getMethodName():String {
			return 'mission_ch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mission_id);
			var tmp_mission_info:ByteArray = new ByteArray;
			this.mission_info.writeToDataOutput(tmp_mission_info);
			var size_tmp_mission_info:int = tmp_mission_info.length;
			output.writeInt(size_tmp_mission_info);
			output.writeBytes(tmp_mission_info);
			output.writeInt(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mission_id = input.readInt();
			var byte_mission_info_size:int = input.readInt();
			if (byte_mission_info_size > 0) {				this.mission_info = new p_mission_info;
				var byte_mission_info:ByteArray = new ByteArray;
				input.readBytes(byte_mission_info, 0, byte_mission_info_size);
				this.mission_info.readFromDataOutput(byte_mission_info);
			}
			this.status = input.readInt();
		}
	}
}
