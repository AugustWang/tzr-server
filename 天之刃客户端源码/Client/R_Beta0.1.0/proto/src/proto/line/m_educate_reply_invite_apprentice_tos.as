package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_reply_invite_apprentice_tos extends Message
	{
		public var ref:String = "";
		public var is_agree:Boolean = true;
		public function m_educate_reply_invite_apprentice_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_reply_invite_apprentice_tos", m_educate_reply_invite_apprentice_tos);
		}
		public override function getMethodName():String {
			return 'educate_reply_invite_apprentice';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.ref != null) {				output.writeUTF(this.ref.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_agree);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ref = input.readUTF();
			this.is_agree = input.readBoolean();
		}
	}
}
