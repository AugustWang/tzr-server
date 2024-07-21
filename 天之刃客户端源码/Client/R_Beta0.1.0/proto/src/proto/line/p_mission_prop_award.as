package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_prop_award extends Message
	{
		public var bind:Boolean = true;
		public var prop_type:int = 0;
		public var prop_id:int = 0;
		public var prop_num:int = 0;
		public function p_mission_prop_award() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_prop_award", p_mission_prop_award);
		}
		public override function getMethodName():String {
			return 'mission_prop_a';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.bind);
			output.writeInt(this.prop_type);
			output.writeInt(this.prop_id);
			output.writeInt(this.prop_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bind = input.readBoolean();
			this.prop_type = input.readInt();
			this.prop_id = input.readInt();
			this.prop_num = input.readInt();
		}
	}
}
