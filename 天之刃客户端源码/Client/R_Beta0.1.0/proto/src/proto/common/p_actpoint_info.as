package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_actpoint_info extends Message
	{
		public var id:int = 0;
		public var cur_ap:int = 0;
		public var max_ap:int = 0;
		public function p_actpoint_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_actpoint_info", p_actpoint_info);
		}
		public override function getMethodName():String {
			return 'actpoint_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.cur_ap);
			output.writeInt(this.max_ap);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.cur_ap = input.readInt();
			this.max_ap = input.readInt();
		}
	}
}
