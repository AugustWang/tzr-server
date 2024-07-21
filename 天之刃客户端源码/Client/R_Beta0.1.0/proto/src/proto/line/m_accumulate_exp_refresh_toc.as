package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_accumulate_exp_refresh_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var result:Boolean = true;
		public var rate:int = 0;
		public var exp:Number = 0;
		public var gold:int = 0;
		public var id:int = 0;
		public var next_exp:Number = 0;
		public function m_accumulate_exp_refresh_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_accumulate_exp_refresh_toc", m_accumulate_exp_refresh_toc);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_refresh';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.result);
			output.writeInt(this.rate);
			output.writeDouble(this.exp);
			output.writeInt(this.gold);
			output.writeInt(this.id);
			output.writeDouble(this.next_exp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.result = input.readBoolean();
			this.rate = input.readInt();
			this.exp = input.readDouble();
			this.gold = input.readInt();
			this.id = input.readInt();
			this.next_exp = input.readDouble();
		}
	}
}
