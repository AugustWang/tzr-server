package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_single_fb_prop_toc extends Message
	{
		public var barrier_id:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var prop_id:int = 0;
		public function m_single_fb_prop_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_single_fb_prop_toc", m_single_fb_prop_toc);
		}
		public override function getMethodName():String {
			return 'single_fb_prop';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.barrier_id);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.prop_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.barrier_id = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.prop_id = input.readInt();
		}
	}
}
