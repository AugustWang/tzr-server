package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_goal_item extends Message
	{
		public var goal_id:int = 0;
		public var finished:Boolean = false;
		public var process_num:int = 0;
		public var fetched:Boolean = false;
		public function p_role_goal_item() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_goal_item", p_role_goal_item);
		}
		public override function getMethodName():String {
			return 'role_goal_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goal_id);
			output.writeBoolean(this.finished);
			output.writeInt(this.process_num);
			output.writeBoolean(this.fetched);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goal_id = input.readInt();
			this.finished = input.readBoolean();
			this.process_num = input.readInt();
			this.fetched = input.readBoolean();
		}
	}
}
