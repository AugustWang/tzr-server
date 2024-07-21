package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_give_toc extends Message
	{
		public var succ:Boolean = true;
		public var tips:String = "";
		public var is_buy:Boolean = false;
		public function m_flowers_give_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_flowers_give_toc", m_flowers_give_toc);
		}
		public override function getMethodName():String {
			return 'flowers_give';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.tips != null) {				output.writeUTF(this.tips.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_buy);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.tips = input.readUTF();
			this.is_buy = input.readBoolean();
		}
	}
}
