package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_ybc_award_prop extends Message
	{
		public var color:int = 0;
		public var prop_type:int = 0;
		public var prop_num:int = 0;
		public function p_mission_ybc_award_prop() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_ybc_award_prop", p_mission_ybc_award_prop);
		}
		public override function getMethodName():String {
			return 'mission_ybc_award_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.color);
			output.writeInt(this.prop_type);
			output.writeInt(this.prop_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.color = input.readInt();
			this.prop_type = input.readInt();
			this.prop_num = input.readInt();
		}
	}
}
