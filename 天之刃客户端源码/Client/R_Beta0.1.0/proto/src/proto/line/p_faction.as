package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_faction extends Message
	{
		public var faction_id:int = 0;
		public var office_info:p_office = null;
		public var succ_times_waroffaction:int = 0;
		public var silver:int = 0;
		public var persist_succ_times_waroffaction:int = 0;
		public var fail_times_waroffaction:int = 0;
		public var persist_fail_times_waroffaction:int = 0;
		public var guarder_level:int = 1;
		public var last_attack_day:int = 0;
		public var last_defence_day:int = 0;
		public var war_point:int = 0;
		public var notice_content:String = "";
		public var last_launch_collection_day:int = 0;
		public var king_token_used_log:p_king_token_used_log = null;
		public function p_faction() {
			super();
			this.office_info = new p_office;
			this.king_token_used_log = new p_king_token_used_log;

			flash.net.registerClassAlias("copy.proto.line.p_faction", p_faction);
		}
		public override function getMethodName():String {
			return 'fac';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.faction_id);
			var tmp_office_info:ByteArray = new ByteArray;
			this.office_info.writeToDataOutput(tmp_office_info);
			var size_tmp_office_info:int = tmp_office_info.length;
			output.writeInt(size_tmp_office_info);
			output.writeBytes(tmp_office_info);
			output.writeInt(this.succ_times_waroffaction);
			output.writeInt(this.silver);
			output.writeInt(this.persist_succ_times_waroffaction);
			output.writeInt(this.fail_times_waroffaction);
			output.writeInt(this.persist_fail_times_waroffaction);
			output.writeInt(this.guarder_level);
			output.writeInt(this.last_attack_day);
			output.writeInt(this.last_defence_day);
			output.writeInt(this.war_point);
			if (this.notice_content != null) {				output.writeUTF(this.notice_content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.last_launch_collection_day);
			var tmp_king_token_used_log:ByteArray = new ByteArray;
			this.king_token_used_log.writeToDataOutput(tmp_king_token_used_log);
			var size_tmp_king_token_used_log:int = tmp_king_token_used_log.length;
			output.writeInt(size_tmp_king_token_used_log);
			output.writeBytes(tmp_king_token_used_log);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.faction_id = input.readInt();
			var byte_office_info_size:int = input.readInt();
			if (byte_office_info_size > 0) {				this.office_info = new p_office;
				var byte_office_info:ByteArray = new ByteArray;
				input.readBytes(byte_office_info, 0, byte_office_info_size);
				this.office_info.readFromDataOutput(byte_office_info);
			}
			this.succ_times_waroffaction = input.readInt();
			this.silver = input.readInt();
			this.persist_succ_times_waroffaction = input.readInt();
			this.fail_times_waroffaction = input.readInt();
			this.persist_fail_times_waroffaction = input.readInt();
			this.guarder_level = input.readInt();
			this.last_attack_day = input.readInt();
			this.last_defence_day = input.readInt();
			this.war_point = input.readInt();
			this.notice_content = input.readUTF();
			this.last_launch_collection_day = input.readInt();
			var byte_king_token_used_log_size:int = input.readInt();
			if (byte_king_token_used_log_size > 0) {				this.king_token_used_log = new p_king_token_used_log;
				var byte_king_token_used_log:ByteArray = new ByteArray;
				input.readBytes(byte_king_token_used_log, 0, byte_king_token_used_log_size);
				this.king_token_used_log.readFromDataOutput(byte_king_token_used_log);
			}
		}
	}
}
