package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_downlevel_toc extends Message
	{
		public var level:int = 0;
		public var reason:String = "";
		public function m_family_downlevel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_downlevel_toc", m_family_downlevel_toc);
		}
		public override function getMethodName():String {
			return 'family_downlevel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.level);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.level = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
