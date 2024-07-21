package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_prop_reward extends Message
	{
		public var prop_id:int = 0;
		public var prop_type:int = 0;
		public var prop_num:int = 0;
		public var bind:Boolean = true;
		public function p_mission_prop_reward() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_prop_reward", p_mission_prop_reward);
		}
		public override function getMethodName():String {
			return 'mission_prop_re';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.prop_id);
			output.writeInt(this.prop_type);
			output.writeInt(this.prop_num);
			output.writeBoolean(this.bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.prop_id = input.readInt();
			this.prop_type = input.readInt();
			this.prop_num = input.readInt();
			this.bind = input.readBoolean();
		}
	}
}
