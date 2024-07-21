package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_tutorial_data extends Message
	{
		public var type:int = 1;
		public var id:int = 0;
		public var num:int = 0;
		public function p_mission_tutorial_data() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_tutorial_data", p_mission_tutorial_data);
		}
		public override function getMethodName():String {
			return 'mission_tutorial_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.id);
			output.writeInt(this.num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.id = input.readInt();
			this.num = input.readInt();
		}
	}
}
