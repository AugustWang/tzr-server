package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_graduate_to_teacher_toc extends Message
	{
		public var address:String = "";
		public function m_educate_graduate_to_teacher_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_graduate_to_teacher_toc", m_educate_graduate_to_teacher_toc);
		}
		public override function getMethodName():String {
			return 'educate_graduate_to_teacher';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.address != null) {				output.writeUTF(this.address.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.address = input.readUTF();
		}
	}
}
