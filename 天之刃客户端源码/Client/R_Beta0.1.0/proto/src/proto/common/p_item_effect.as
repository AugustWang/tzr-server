package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_item_effect extends Message
	{
		public var funid:int = 0;
		public var parameter:String = "";
		public function p_item_effect() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_item_effect", p_item_effect);
		}
		public override function getMethodName():String {
			return 'item_ef';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.funid);
			if (this.parameter != null) {				output.writeUTF(this.parameter.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.funid = input.readInt();
			this.parameter = input.readUTF();
		}
	}
}
