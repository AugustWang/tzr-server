package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_auto_data extends Message
	{
		public var title:String = "";
		public var loop_times:int = 0;
		public var start_time:int = 0;
		public var continue_time:int = 0;
		public var cost_gold:int = 0;
		public var cost_silver:int = 0;
		public var cost_silver_bind:int = 0;
		public function p_mission_auto_data() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_auto_data", p_mission_auto_data);
		}
		public override function getMethodName():String {
			return 'mission_auto_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.loop_times);
			output.writeInt(this.start_time);
			output.writeInt(this.continue_time);
			output.writeInt(this.cost_gold);
			output.writeInt(this.cost_silver);
			output.writeInt(this.cost_silver_bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.title = input.readUTF();
			this.loop_times = input.readInt();
			this.start_time = input.readInt();
			this.continue_time = input.readInt();
			this.cost_gold = input.readInt();
			this.cost_silver = input.readInt();
			this.cost_silver_bind = input.readInt();
		}
	}
}
