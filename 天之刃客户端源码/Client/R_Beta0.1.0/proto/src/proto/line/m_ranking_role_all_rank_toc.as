package proto.line {
	import proto.common.p_role_all_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_role_all_rank_toc extends Message
	{
		public var role_all_ranks:Array = new Array;
		public var role_id:int = 0;
		public var is_self:Boolean = true;
		public var role_name:String = "";
		public var family_name:String = "";
		public var level:int = 0;
		public function m_ranking_role_all_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_role_all_rank_toc", m_ranking_role_all_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_role_all_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_role_all_ranks:int = this.role_all_ranks.length;
			output.writeShort(size_role_all_ranks);
			var temp_repeated_byte_role_all_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_role_all_ranks; i++) {
				var t2_role_all_ranks:ByteArray = new ByteArray;
				var tVo_role_all_ranks:p_role_all_rank = this.role_all_ranks[i] as p_role_all_rank;
				tVo_role_all_ranks.writeToDataOutput(t2_role_all_ranks);
				var len_tVo_role_all_ranks:int = t2_role_all_ranks.length;
				temp_repeated_byte_role_all_ranks.writeInt(len_tVo_role_all_ranks);
				temp_repeated_byte_role_all_ranks.writeBytes(t2_role_all_ranks);
			}
			output.writeInt(temp_repeated_byte_role_all_ranks.length);
			output.writeBytes(temp_repeated_byte_role_all_ranks);
			output.writeInt(this.role_id);
			output.writeBoolean(this.is_self);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_role_all_ranks:int = input.readShort();
			var length_role_all_ranks:int = input.readInt();
			if (length_role_all_ranks > 0) {
				var byte_role_all_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_role_all_ranks, 0, length_role_all_ranks);
				for(i=0; i<size_role_all_ranks; i++) {
					var tmp_role_all_ranks:p_role_all_rank = new p_role_all_rank;
					var tmp_role_all_ranks_length:int = byte_role_all_ranks.readInt();
					var tmp_role_all_ranks_byte:ByteArray = new ByteArray;
					byte_role_all_ranks.readBytes(tmp_role_all_ranks_byte, 0, tmp_role_all_ranks_length);
					tmp_role_all_ranks.readFromDataOutput(tmp_role_all_ranks_byte);
					this.role_all_ranks.push(tmp_role_all_ranks);
				}
			}
			this.role_id = input.readInt();
			this.is_self = input.readBoolean();
			this.role_name = input.readUTF();
			this.family_name = input.readUTF();
			this.level = input.readInt();
		}
	}
}
