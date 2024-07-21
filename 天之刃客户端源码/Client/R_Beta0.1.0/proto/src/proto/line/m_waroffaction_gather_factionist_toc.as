package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_gather_factionist_toc extends Message
	{
		public var message:String = "";
		public var mapid:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public function m_waroffaction_gather_factionist_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_gather_factionist_toc", m_waroffaction_gather_factionist_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_gather_factionist';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.mapid);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.message = input.readUTF();
			this.mapid = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
		}
	}
}
