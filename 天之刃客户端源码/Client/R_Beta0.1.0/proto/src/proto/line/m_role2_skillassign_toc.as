package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_skillassign_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var result:p_role_skill = null;
		public var remain_points:int = 0;
		public function m_role2_skillassign_toc() {
			super();
			this.result = new p_role_skill;

			flash.net.registerClassAlias("copy.proto.line.m_role2_skillassign_toc", m_role2_skillassign_toc);
		}
		public override function getMethodName():String {
			return 'role2_skillassign';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_result:ByteArray = new ByteArray;
			this.result.writeToDataOutput(tmp_result);
			var size_tmp_result:int = tmp_result.length;
			output.writeInt(size_tmp_result);
			output.writeBytes(tmp_result);
			output.writeInt(this.remain_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_result_size:int = input.readInt();
			if (byte_result_size > 0) {				this.result = new p_role_skill;
				var byte_result:ByteArray = new ByteArray;
				input.readBytes(byte_result, 0, byte_result_size);
				this.result.readFromDataOutput(byte_result);
			}
			this.remain_points = input.readInt();
		}
	}
}
