package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_student_online_toc extends Message
	{
		public var name:String = "";
		public function m_educate_student_online_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_student_online_toc", m_educate_student_online_toc);
		}
		public override function getMethodName():String {
			return 'educate_student_online';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.name = input.readUTF();
		}
	}
}
