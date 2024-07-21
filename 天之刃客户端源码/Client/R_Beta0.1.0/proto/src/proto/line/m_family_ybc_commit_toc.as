package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_commit_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var exp:int = 0;
		public var silver:int = 0;
		public var contribution:int = 0;
		public var family_money:int = 0;
		public var active_point:int = 0;
		public function m_family_ybc_commit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_commit_toc", m_family_ybc_commit_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_commit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.exp);
			output.writeInt(this.silver);
			output.writeInt(this.contribution);
			output.writeInt(this.family_money);
			output.writeInt(this.active_point);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.exp = input.readInt();
			this.silver = input.readInt();
			this.contribution = input.readInt();
			this.family_money = input.readInt();
			this.active_point = input.readInt();
		}
	}
}
