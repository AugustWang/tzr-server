package proto.line {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_ybc_pos_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var map_id:int = 0;
		public var pos:p_pos = null;
		public var monster_type:int = 0;
		public function m_mission_ybc_pos_toc() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.m_mission_ybc_pos_toc", m_mission_ybc_pos_toc);
		}
		public override function getMethodName():String {
			return 'mission_ybc_pos';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.map_id);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.monster_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.map_id = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.monster_type = input.readInt();
		}
	}
}
