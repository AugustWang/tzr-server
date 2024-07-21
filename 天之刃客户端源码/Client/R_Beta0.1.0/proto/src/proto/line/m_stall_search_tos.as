package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_search_tos extends Message
	{
		public var content:String = "";
		public var type:int = 0;
		public var page:int = 1;
		public function m_stall_search_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_search_tos", m_stall_search_tos);
		}
		public override function getMethodName():String {
			return 'stall_search';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.page);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.content = input.readUTF();
			this.type = input.readInt();
			this.page = input.readInt();
		}
	}
}
