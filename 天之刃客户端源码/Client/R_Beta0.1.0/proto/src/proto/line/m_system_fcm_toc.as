package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_fcm_toc extends Message
	{
		public var info:String = "";
		public var remain_time:int = 0;
		public var total_time:int = 0;
		public function m_system_fcm_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_system_fcm_toc", m_system_fcm_toc);
		}
		public override function getMethodName():String {
			return 'system_fcm';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.info != null) {				output.writeUTF(this.info.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.remain_time);
			output.writeInt(this.total_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.info = input.readUTF();
			this.remain_time = input.readInt();
			this.total_time = input.readInt();
		}
	}
}
