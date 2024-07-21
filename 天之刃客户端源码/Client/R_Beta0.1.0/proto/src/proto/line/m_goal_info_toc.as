package proto.line {
	import proto.common.p_role_goal;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goal_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var info:p_role_goal = null;
		public function m_goal_info_toc() {
			super();
			this.info = new p_role_goal;

			flash.net.registerClassAlias("copy.proto.line.m_goal_info_toc", m_goal_info_toc);
		}
		public override function getMethodName():String {
			return 'goal_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_info:ByteArray = new ByteArray;
			this.info.writeToDataOutput(tmp_info);
			var size_tmp_info:int = tmp_info.length;
			output.writeInt(size_tmp_info);
			output.writeBytes(tmp_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_info_size:int = input.readInt();
			if (byte_info_size > 0) {				this.info = new p_role_goal;
				var byte_info:ByteArray = new ByteArray;
				input.readBytes(byte_info, 0, byte_info_size);
				this.info.readFromDataOutput(byte_info);
			}
		}
	}
}
