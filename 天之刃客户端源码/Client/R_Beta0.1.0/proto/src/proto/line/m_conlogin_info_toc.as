package proto.line {
	import proto.common.p_conlogin_reward;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_conlogin_info_toc extends Message
	{
		public var day:int = 0;
		public var next_day:int = 0;
		public var notice:String = "";
		public var rewards:Array = new Array;
		public function m_conlogin_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_conlogin_info_toc", m_conlogin_info_toc);
		}
		public override function getMethodName():String {
			return 'conlogin_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.day);
			output.writeInt(this.next_day);
			if (this.notice != null) {				output.writeUTF(this.notice.toString());
			} else {
				output.writeUTF("");
			}
			var size_rewards:int = this.rewards.length;
			output.writeShort(size_rewards);
			var temp_repeated_byte_rewards:ByteArray= new ByteArray;
			for(i=0; i<size_rewards; i++) {
				var t2_rewards:ByteArray = new ByteArray;
				var tVo_rewards:p_conlogin_reward = this.rewards[i] as p_conlogin_reward;
				tVo_rewards.writeToDataOutput(t2_rewards);
				var len_tVo_rewards:int = t2_rewards.length;
				temp_repeated_byte_rewards.writeInt(len_tVo_rewards);
				temp_repeated_byte_rewards.writeBytes(t2_rewards);
			}
			output.writeInt(temp_repeated_byte_rewards.length);
			output.writeBytes(temp_repeated_byte_rewards);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.day = input.readInt();
			this.next_day = input.readInt();
			this.notice = input.readUTF();
			var size_rewards:int = input.readShort();
			var length_rewards:int = input.readInt();
			if (length_rewards > 0) {
				var byte_rewards:ByteArray = new ByteArray; 
				input.readBytes(byte_rewards, 0, length_rewards);
				for(i=0; i<size_rewards; i++) {
					var tmp_rewards:p_conlogin_reward = new p_conlogin_reward;
					var tmp_rewards_length:int = byte_rewards.readInt();
					var tmp_rewards_byte:ByteArray = new ByteArray;
					byte_rewards.readBytes(tmp_rewards_byte, 0, tmp_rewards_length);
					tmp_rewards.readFromDataOutput(tmp_rewards_byte);
					this.rewards.push(tmp_rewards);
				}
			}
		}
	}
}
