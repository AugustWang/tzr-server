package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class s_account_kick_toc extends Message
	{
		public var account:String = "";
		public function s_account_kick_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.common.s_account_kick_toc", s_account_kick_toc);
		}
		public override function getMethodName():String {
			return 'account_kick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.account != null) {				output.writeUTF(this.account.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.account = input.readUTF();
		}
	}
}
