package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_online_info extends Message
	{
		public var memberid:int = 0;
		public var otherattr:int = 0;
		public function p_online_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_online_info", p_online_info);
		}
		public override function getMethodName():String {
			return 'online_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.memberid);
			output.writeInt(this.otherattr);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.memberid = input.readInt();
			this.otherattr = input.readInt();
		}
	}
}
