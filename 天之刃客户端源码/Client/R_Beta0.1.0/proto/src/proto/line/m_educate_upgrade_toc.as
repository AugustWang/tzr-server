package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_upgrade_toc extends Message
	{
		public var succ:Boolean = true;
		public var student_num:int = 0;
		public var reason:String = "";
		public function m_educate_upgrade_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_upgrade_toc", m_educate_upgrade_toc);
		}
		public override function getMethodName():String {
			return 'educate_upgrade';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.student_num);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.student_num = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
