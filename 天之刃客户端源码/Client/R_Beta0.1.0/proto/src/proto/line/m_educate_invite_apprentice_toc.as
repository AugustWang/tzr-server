package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_invite_apprentice_toc extends Message
	{
		public var ref:String = "";
		public var rolename:String = "";
		public function m_educate_invite_apprentice_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_invite_apprentice_toc", m_educate_invite_apprentice_toc);
		}
		public override function getMethodName():String {
			return 'educate_invite_apprentice';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.ref != null) {				output.writeUTF(this.ref.toString());
			} else {
				output.writeUTF("");
			}
			if (this.rolename != null) {				output.writeUTF(this.rolename.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ref = input.readUTF();
			this.rolename = input.readUTF();
		}
	}
}
