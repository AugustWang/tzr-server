package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_driver_go_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var type:int = 0;
		public var id:int = 0;
		public function m_driver_go_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_driver_go_toc", m_driver_go_toc);
		}
		public override function getMethodName():String {
			return 'driver_go';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.type = input.readInt();
			this.id = input.readInt();
		}
	}
}
