package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_auto extends Message
	{
		public var id:int = 0;
		public var name:String = "";
		public var mission_id:int = 0;
		public var loop_times:int = 0;
		public var total_time:int = 0;
		public var status:int = 0;
		public var start_time:int = 0;
		public var need_gold:int = 0;
		public function p_mission_auto() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_auto", p_mission_auto);
		}
		public override function getMethodName():String {
			return 'mission_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.mission_id);
			output.writeInt(this.loop_times);
			output.writeInt(this.total_time);
			output.writeInt(this.status);
			output.writeInt(this.start_time);
			output.writeInt(this.need_gold);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readUTF();
			this.mission_id = input.readInt();
			this.loop_times = input.readInt();
			this.total_time = input.readInt();
			this.status = input.readInt();
			this.start_time = input.readInt();
			this.need_gold = input.readInt();
		}
	}
}
