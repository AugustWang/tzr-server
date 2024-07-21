package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect_role extends Message
	{
		public var roleid:int = 0;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public function p_collect_role() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_collect_role", p_collect_role);
		}
		public override function getMethodName():String {
			return 'collect_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
		}
	}
}
