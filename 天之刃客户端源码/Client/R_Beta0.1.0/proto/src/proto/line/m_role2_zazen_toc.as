package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_zazen_toc extends Message
	{
		public var succ:Boolean = true;
		public var roleid:int = 0;
		public var return_self:Boolean = true;
		public var status:Boolean = true;
		public var reason:String = "";
		public function m_role2_zazen_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_zazen_toc", m_role2_zazen_toc);
		}
		public override function getMethodName():String {
			return 'role2_zazen';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.roleid);
			output.writeBoolean(this.return_self);
			output.writeBoolean(this.status);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.roleid = input.readInt();
			this.return_self = input.readBoolean();
			this.status = input.readBoolean();
			this.reason = input.readUTF();
		}
	}
}
