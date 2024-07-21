package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_sex_toc extends Message
	{
		public var succ:Boolean = true;
		public var sex:int = 0;
		public var reason:String = "";
		public function m_role2_sex_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_sex_toc", m_role2_sex_toc);
		}
		public override function getMethodName():String {
			return 'role2_sex';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.sex);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.sex = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
