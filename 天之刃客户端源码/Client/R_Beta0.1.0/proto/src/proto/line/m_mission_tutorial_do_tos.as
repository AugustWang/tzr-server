package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_tutorial_do_tos extends Message
	{
		public var id:int = 0;
		public var int_data:int = 0;
		public var str_data:String = "";
		public function m_mission_tutorial_do_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_tutorial_do_tos", m_mission_tutorial_do_tos);
		}
		public override function getMethodName():String {
			return 'mission_tutorial_do';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.int_data);
			if (this.str_data != null) {				output.writeUTF(this.str_data.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.int_data = input.readInt();
			this.str_data = input.readUTF();
		}
	}
}
