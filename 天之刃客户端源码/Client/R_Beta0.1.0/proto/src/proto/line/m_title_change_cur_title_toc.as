package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_title_change_cur_title_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var color:String = "";
		public var id:int = 0;
		public function m_title_change_cur_title_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_title_change_cur_title_toc", m_title_change_cur_title_toc);
		}
		public override function getMethodName():String {
			return 'title_change_cur_title';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.color != null) {				output.writeUTF(this.color.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.color = input.readUTF();
			this.id = input.readInt();
		}
	}
}
