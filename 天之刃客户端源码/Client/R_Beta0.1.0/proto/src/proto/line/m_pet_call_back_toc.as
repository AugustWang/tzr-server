package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_call_back_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var pet_id:int = 0;
		public function m_pet_call_back_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_call_back_toc", m_pet_call_back_toc);
		}
		public override function getMethodName():String {
			return 'pet_call_back';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pet_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.pet_id = input.readInt();
		}
	}
}
