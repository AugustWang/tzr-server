package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_accumulate_exp_view_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var allexp:Number = 0;
		public var cangetexp:Number = 0;
		public var nextexp:Number = 0;
		public var gold:int = 0;
		public var flag:int = 0;
		public function m_accumulate_exp_view_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_accumulate_exp_view_toc", m_accumulate_exp_view_toc);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_view';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeDouble(this.allexp);
			output.writeDouble(this.cangetexp);
			output.writeDouble(this.nextexp);
			output.writeInt(this.gold);
			output.writeInt(this.flag);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.allexp = input.readDouble();
			this.cangetexp = input.readDouble();
			this.nextexp = input.readDouble();
			this.gold = input.readInt();
			this.flag = input.readInt();
		}
	}
}
