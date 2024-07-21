package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trading_return_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var type:int = 0;
		public var silver:int = 0;
		public var family_money:int = 0;
		public var family_contribution:int = 0;
		public var trading_times:int = 0;
		public var award_type:int = 0;
		public function m_trading_return_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trading_return_toc", m_trading_return_toc);
		}
		public override function getMethodName():String {
			return 'trading_return';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.silver);
			output.writeInt(this.family_money);
			output.writeInt(this.family_contribution);
			output.writeInt(this.trading_times);
			output.writeInt(this.award_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.type = input.readInt();
			this.silver = input.readInt();
			this.family_money = input.readInt();
			this.family_contribution = input.readInt();
			this.trading_times = input.readInt();
			this.award_type = input.readInt();
		}
	}
}
