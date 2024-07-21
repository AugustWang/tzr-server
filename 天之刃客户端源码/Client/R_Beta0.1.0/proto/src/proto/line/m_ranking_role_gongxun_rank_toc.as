package proto.line {
	import proto.common.p_role_gongxun_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_role_gongxun_rank_toc extends Message
	{
		public var role_gongxun_ranks:Array = new Array;
		public function m_ranking_role_gongxun_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_role_gongxun_rank_toc", m_ranking_role_gongxun_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_role_gongxun_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_role_gongxun_ranks:int = this.role_gongxun_ranks.length;
			output.writeShort(size_role_gongxun_ranks);
			var temp_repeated_byte_role_gongxun_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_role_gongxun_ranks; i++) {
				var t2_role_gongxun_ranks:ByteArray = new ByteArray;
				var tVo_role_gongxun_ranks:p_role_gongxun_rank = this.role_gongxun_ranks[i] as p_role_gongxun_rank;
				tVo_role_gongxun_ranks.writeToDataOutput(t2_role_gongxun_ranks);
				var len_tVo_role_gongxun_ranks:int = t2_role_gongxun_ranks.length;
				temp_repeated_byte_role_gongxun_ranks.writeInt(len_tVo_role_gongxun_ranks);
				temp_repeated_byte_role_gongxun_ranks.writeBytes(t2_role_gongxun_ranks);
			}
			output.writeInt(temp_repeated_byte_role_gongxun_ranks.length);
			output.writeBytes(temp_repeated_byte_role_gongxun_ranks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_role_gongxun_ranks:int = input.readShort();
			var length_role_gongxun_ranks:int = input.readInt();
			if (length_role_gongxun_ranks > 0) {
				var byte_role_gongxun_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_role_gongxun_ranks, 0, length_role_gongxun_ranks);
				for(i=0; i<size_role_gongxun_ranks; i++) {
					var tmp_role_gongxun_ranks:p_role_gongxun_rank = new p_role_gongxun_rank;
					var tmp_role_gongxun_ranks_length:int = byte_role_gongxun_ranks.readInt();
					var tmp_role_gongxun_ranks_byte:ByteArray = new ByteArray;
					byte_role_gongxun_ranks.readBytes(tmp_role_gongxun_ranks_byte, 0, tmp_role_gongxun_ranks_length);
					tmp_role_gongxun_ranks.readFromDataOutput(tmp_role_gongxun_ranks_byte);
					this.role_gongxun_ranks.push(tmp_role_gongxun_ranks);
				}
			}
		}
	}
}
