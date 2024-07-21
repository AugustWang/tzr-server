package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_exp_full_toc extends Message
	{
		public var text:String = "";
		public function m_role2_exp_full_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_exp_full_toc", m_role2_exp_full_toc);
		}
		public override function getMethodName():String {
			return 'role2_exp_full';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.text != null) {				output.writeUTF(this.text.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.text = input.readUTF();
		}
	}
}
