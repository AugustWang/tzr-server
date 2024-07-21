package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_query_faction_online_rank_toc extends Message
	{
		public var op_type:int = 0;
		public var faction_id:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var online_rank:Array = new Array;
		public function m_role2_query_faction_online_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_query_faction_online_rank_toc", m_role2_query_faction_online_rank_toc);
		}
		public override function getMethodName():String {
			return 'role2_query_faction_online_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.faction_id);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_online_rank:int = this.online_rank.length;
			output.writeShort(size_online_rank);
			var temp_repeated_byte_online_rank:ByteArray= new ByteArray;
			for(i=0; i<size_online_rank; i++) {
				var t2_online_rank:ByteArray = new ByteArray;
				var tVo_online_rank:p_faction_online_rank = this.online_rank[i] as p_faction_online_rank;
				tVo_online_rank.writeToDataOutput(t2_online_rank);
				var len_tVo_online_rank:int = t2_online_rank.length;
				temp_repeated_byte_online_rank.writeInt(len_tVo_online_rank);
				temp_repeated_byte_online_rank.writeBytes(t2_online_rank);
			}
			output.writeInt(temp_repeated_byte_online_rank.length);
			output.writeBytes(temp_repeated_byte_online_rank);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.faction_id = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_online_rank:int = input.readShort();
			var length_online_rank:int = input.readInt();
			if (length_online_rank > 0) {
				var byte_online_rank:ByteArray = new ByteArray; 
				input.readBytes(byte_online_rank, 0, length_online_rank);
				for(i=0; i<size_online_rank; i++) {
					var tmp_online_rank:p_faction_online_rank = new p_faction_online_rank;
					var tmp_online_rank_length:int = byte_online_rank.readInt();
					var tmp_online_rank_byte:ByteArray = new ByteArray;
					byte_online_rank.readBytes(tmp_online_rank_byte, 0, tmp_online_rank_length);
					tmp_online_rank.readFromDataOutput(tmp_online_rank_byte);
					this.online_rank.push(tmp_online_rank);
				}
			}
		}
	}
}
