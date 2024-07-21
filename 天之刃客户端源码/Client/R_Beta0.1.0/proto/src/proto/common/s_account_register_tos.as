package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class s_account_register_tos extends Message
	{
		public var account:String = "";
		public var guid:String = "";
		public function s_account_register_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.common.s_account_register_tos", s_account_register_tos);
		}
		public override function getMethodName():String {
			return 'account_register';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.account != null) {				output.writeUTF(this.account.toString());
			} else {
				output.writeUTF("");
			}
			if (this.guid != null) {				output.writeUTF(this.guid.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.account = input.readUTF();
			this.guid = input.readUTF();
		}
	}
}
