package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_create_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var bag_id:int = 0;
		public function m_fmldepot_create_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_create_toc", m_fmldepot_create_toc);
		}
		public override function getMethodName():String {
			return 'fmldepot_create';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.bag_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.bag_id = input.readInt();
		}
	}
}
