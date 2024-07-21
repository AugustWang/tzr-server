package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_random_show_toc extends Message
	{
		public var mission_id:int = 0;
		public var desc:String = "";
		public function m_mission_random_show_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_random_show_toc", m_mission_random_show_toc);
		}
		public override function getMethodName():String {
			return 'mission_random_show';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mission_id);
			if (this.desc != null) {				output.writeUTF(this.desc.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mission_id = input.readInt();
			this.desc = input.readUTF();
		}
	}
}
