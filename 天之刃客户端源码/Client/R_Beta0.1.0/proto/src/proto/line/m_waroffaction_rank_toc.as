package proto.line {
	import proto.common.p_waroffaction_rank;
	import proto.common.p_waroffaction_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_rank_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var self_score:int = 0;
		public var attack_faction_ranks:Array = new Array;
		public var attack_faction_id:int = 0;
		public var defence_faction_ranks:Array = new Array;
		public var defence_faction_id:int = 0;
		public function m_waroffaction_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_rank_toc", m_waroffaction_rank_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.self_score);
			var size_attack_faction_ranks:int = this.attack_faction_ranks.length;
			output.writeShort(size_attack_faction_ranks);
			var temp_repeated_byte_attack_faction_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_attack_faction_ranks; i++) {
				var t2_attack_faction_ranks:ByteArray = new ByteArray;
				var tVo_attack_faction_ranks:p_waroffaction_rank = this.attack_faction_ranks[i] as p_waroffaction_rank;
				tVo_attack_faction_ranks.writeToDataOutput(t2_attack_faction_ranks);
				var len_tVo_attack_faction_ranks:int = t2_attack_faction_ranks.length;
				temp_repeated_byte_attack_faction_ranks.writeInt(len_tVo_attack_faction_ranks);
				temp_repeated_byte_attack_faction_ranks.writeBytes(t2_attack_faction_ranks);
			}
			output.writeInt(temp_repeated_byte_attack_faction_ranks.length);
			output.writeBytes(temp_repeated_byte_attack_faction_ranks);
			output.writeInt(this.attack_faction_id);
			var size_defence_faction_ranks:int = this.defence_faction_ranks.length;
			output.writeShort(size_defence_faction_ranks);
			var temp_repeated_byte_defence_faction_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_defence_faction_ranks; i++) {
				var t2_defence_faction_ranks:ByteArray = new ByteArray;
				var tVo_defence_faction_ranks:p_waroffaction_rank = this.defence_faction_ranks[i] as p_waroffaction_rank;
				tVo_defence_faction_ranks.writeToDataOutput(t2_defence_faction_ranks);
				var len_tVo_defence_faction_ranks:int = t2_defence_faction_ranks.length;
				temp_repeated_byte_defence_faction_ranks.writeInt(len_tVo_defence_faction_ranks);
				temp_repeated_byte_defence_faction_ranks.writeBytes(t2_defence_faction_ranks);
			}
			output.writeInt(temp_repeated_byte_defence_faction_ranks.length);
			output.writeBytes(temp_repeated_byte_defence_faction_ranks);
			output.writeInt(this.defence_faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.self_score = input.readInt();
			var size_attack_faction_ranks:int = input.readShort();
			var length_attack_faction_ranks:int = input.readInt();
			if (length_attack_faction_ranks > 0) {
				var byte_attack_faction_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_attack_faction_ranks, 0, length_attack_faction_ranks);
				for(i=0; i<size_attack_faction_ranks; i++) {
					var tmp_attack_faction_ranks:p_waroffaction_rank = new p_waroffaction_rank;
					var tmp_attack_faction_ranks_length:int = byte_attack_faction_ranks.readInt();
					var tmp_attack_faction_ranks_byte:ByteArray = new ByteArray;
					byte_attack_faction_ranks.readBytes(tmp_attack_faction_ranks_byte, 0, tmp_attack_faction_ranks_length);
					tmp_attack_faction_ranks.readFromDataOutput(tmp_attack_faction_ranks_byte);
					this.attack_faction_ranks.push(tmp_attack_faction_ranks);
				}
			}
			this.attack_faction_id = input.readInt();
			var size_defence_faction_ranks:int = input.readShort();
			var length_defence_faction_ranks:int = input.readInt();
			if (length_defence_faction_ranks > 0) {
				var byte_defence_faction_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_defence_faction_ranks, 0, length_defence_faction_ranks);
				for(i=0; i<size_defence_faction_ranks; i++) {
					var tmp_defence_faction_ranks:p_waroffaction_rank = new p_waroffaction_rank;
					var tmp_defence_faction_ranks_length:int = byte_defence_faction_ranks.readInt();
					var tmp_defence_faction_ranks_byte:ByteArray = new ByteArray;
					byte_defence_faction_ranks.readBytes(tmp_defence_faction_ranks_byte, 0, tmp_defence_faction_ranks_length);
					tmp_defence_faction_ranks.readFromDataOutput(tmp_defence_faction_ranks_byte);
					this.defence_faction_ranks.push(tmp_defence_faction_ranks);
				}
			}
			this.defence_faction_id = input.readInt();
		}
	}
}
