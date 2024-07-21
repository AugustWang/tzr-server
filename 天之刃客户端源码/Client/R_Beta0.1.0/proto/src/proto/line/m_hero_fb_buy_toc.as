package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_hero_fb_buy_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var max_enter_times:int = 0;
		public var buy_count:int = 0;
		public function m_hero_fb_buy_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_hero_fb_buy_toc", m_hero_fb_buy_toc);
		}
		public override function getMethodName():String {
			return 'hero_fb_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.max_enter_times);
			output.writeInt(this.buy_count);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.max_enter_times = input.readInt();
			this.buy_count = input.readInt();
		}
	}
}
