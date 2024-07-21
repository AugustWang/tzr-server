package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_request_info extends Message
	{
		public var role_id:int = 0;
		public var family_id:int = 0;
		public function p_family_request_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_family_request_info", p_family_request_info);
		}
		public override function getMethodName():String {
			return 'family_request_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.family_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.family_id = input.readInt();
		}
	}
}
