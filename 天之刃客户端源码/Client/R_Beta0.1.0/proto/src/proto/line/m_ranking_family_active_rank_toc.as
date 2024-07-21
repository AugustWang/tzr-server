package proto.line {
	import proto.common.p_family_active_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_family_active_rank_toc extends Message
	{
		public var family_active_ranks:Array = new Array;
		public function m_ranking_family_active_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_family_active_rank_toc", m_ranking_family_active_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_family_active_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_family_active_ranks:int = this.family_active_ranks.length;
			output.writeShort(size_family_active_ranks);
			var temp_repeated_byte_family_active_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_family_active_ranks; i++) {
				var t2_family_active_ranks:ByteArray = new ByteArray;
				var tVo_family_active_ranks:p_family_active_rank = this.family_active_ranks[i] as p_family_active_rank;
				tVo_family_active_ranks.writeToDataOutput(t2_family_active_ranks);
				var len_tVo_family_active_ranks:int = t2_family_active_ranks.length;
				temp_repeated_byte_family_active_ranks.writeInt(len_tVo_family_active_ranks);
				temp_repeated_byte_family_active_ranks.writeBytes(t2_family_active_ranks);
			}
			output.writeInt(temp_repeated_byte_family_active_ranks.length);
			output.writeBytes(temp_repeated_byte_family_active_ranks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_family_active_ranks:int = input.readShort();
			var length_family_active_ranks:int = input.readInt();
			if (length_family_active_ranks > 0) {
				var byte_family_active_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_family_active_ranks, 0, length_family_active_ranks);
				for(i=0; i<size_family_active_ranks; i++) {
					var tmp_family_active_ranks:p_family_active_rank = new p_family_active_rank;
					var tmp_family_active_ranks_length:int = byte_family_active_ranks.readInt();
					var tmp_family_active_ranks_byte:ByteArray = new ByteArray;
					byte_family_active_ranks.readBytes(tmp_family_active_ranks_byte, 0, tmp_family_active_ranks_length);
					tmp_family_active_ranks.readFromDataOutput(tmp_family_active_ranks_byte);
					this.family_active_ranks.push(tmp_family_active_ranks);
				}
			}
		}
	}
}
