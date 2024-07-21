package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_change_map_toc extends Message
	{
		public var succ:Boolean = true;
		public var mapid:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public var reason:String = "";
		public function m_map_change_map_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_change_map_toc", m_map_change_map_toc);
		}
		public override function getMethodName():String {
			return 'map_change_map';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.mapid);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.mapid = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
