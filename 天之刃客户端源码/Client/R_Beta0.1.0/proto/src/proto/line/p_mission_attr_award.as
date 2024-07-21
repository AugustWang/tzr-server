package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_attr_award extends Message
	{
		public var attr_type:int = 0;
		public var attr_num:int = 0;
		public function p_mission_attr_award() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_attr_award", p_mission_attr_award);
		}
		public override function getMethodName():String {
			return 'mission_attr_a';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.attr_type);
			output.writeInt(this.attr_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.attr_type = input.readInt();
			this.attr_num = input.readInt();
		}
	}
}
