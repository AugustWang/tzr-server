package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_timer_toc extends Message
	{
		public var mission_id:int = 0;
		public var remain_time:int = 0;
		public var action_type:int = 0;
		public var title:String = "";
		public var desc:String = "";
		public function m_mission_timer_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_timer_toc", m_mission_timer_toc);
		}
		public override function getMethodName():String {
			return 'mission_timer';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mission_id);
			output.writeInt(this.remain_time);
			output.writeInt(this.action_type);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			if (this.desc != null) {				output.writeUTF(this.desc.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mission_id = input.readInt();
			this.remain_time = input.readInt();
			this.action_type = input.readInt();
			this.title = input.readUTF();
			this.desc = input.readUTF();
		}
	}
}
