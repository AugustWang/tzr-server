package proto.line {
	import proto.common.p_role_level_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_role_level_rank_toc extends Message
	{
		public var role_level_ranks:Array = new Array;
		public function m_ranking_role_level_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_role_level_rank_toc", m_ranking_role_level_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_role_level_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_role_level_ranks:int = this.role_level_ranks.length;
			output.writeShort(size_role_level_ranks);
			var temp_repeated_byte_role_level_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_role_level_ranks; i++) {
				var t2_role_level_ranks:ByteArray = new ByteArray;
				var tVo_role_level_ranks:p_role_level_rank = this.role_level_ranks[i] as p_role_level_rank;
				tVo_role_level_ranks.writeToDataOutput(t2_role_level_ranks);
				var len_tVo_role_level_ranks:int = t2_role_level_ranks.length;
				temp_repeated_byte_role_level_ranks.writeInt(len_tVo_role_level_ranks);
				temp_repeated_byte_role_level_ranks.writeBytes(t2_role_level_ranks);
			}
			output.writeInt(temp_repeated_byte_role_level_ranks.length);
			output.writeBytes(temp_repeated_byte_role_level_ranks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_role_level_ranks:int = input.readShort();
			var length_role_level_ranks:int = input.readInt();
			if (length_role_level_ranks > 0) {
				var byte_role_level_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_role_level_ranks, 0, length_role_level_ranks);
				for(i=0; i<size_role_level_ranks; i++) {
					var tmp_role_level_ranks:p_role_level_rank = new p_role_level_rank;
					var tmp_role_level_ranks_length:int = byte_role_level_ranks.readInt();
					var tmp_role_level_ranks_byte:ByteArray = new ByteArray;
					byte_role_level_ranks.readBytes(tmp_role_level_ranks_byte, 0, tmp_role_level_ranks_length);
					tmp_role_level_ranks.readFromDataOutput(tmp_role_level_ranks_byte);
					this.role_level_ranks.push(tmp_role_level_ranks);
				}
			}
		}
	}
}
