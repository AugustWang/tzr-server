package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_jail_donate_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var pk_points:int = 0;
		public var gold:int = 0;
		public var gold_bind:int = 0;
		public function m_jail_donate_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_jail_donate_toc", m_jail_donate_toc);
		}
		public override function getMethodName():String {
			return 'jail_donate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pk_points);
			output.writeInt(this.gold);
			output.writeInt(this.gold_bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.pk_points = input.readInt();
			this.gold = input.readInt();
			this.gold_bind = input.readInt();
		}
	}
}
