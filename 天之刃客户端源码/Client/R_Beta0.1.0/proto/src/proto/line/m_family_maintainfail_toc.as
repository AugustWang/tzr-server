package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_maintainfail_toc extends Message
	{
		public var message:String = "";
		public var result:int = 0;
		public var new_level:int = 0;
		public function m_family_maintainfail_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_maintainfail_toc", m_family_maintainfail_toc);
		}
		public override function getMethodName():String {
			return 'family_maintainfail';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.result);
			output.writeInt(this.new_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.message = input.readUTF();
			this.result = input.readInt();
			this.new_level = input.readInt();
		}
	}
}
