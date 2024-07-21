package proto.line {
	import proto.common.p_equip_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_equip_refining_rank_toc extends Message
	{
		public var equip_refining_ranks:Array = new Array;
		public function m_ranking_equip_refining_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_equip_refining_rank_toc", m_ranking_equip_refining_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_equip_refining_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_equip_refining_ranks:int = this.equip_refining_ranks.length;
			output.writeShort(size_equip_refining_ranks);
			var temp_repeated_byte_equip_refining_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_equip_refining_ranks; i++) {
				var t2_equip_refining_ranks:ByteArray = new ByteArray;
				var tVo_equip_refining_ranks:p_equip_rank = this.equip_refining_ranks[i] as p_equip_rank;
				tVo_equip_refining_ranks.writeToDataOutput(t2_equip_refining_ranks);
				var len_tVo_equip_refining_ranks:int = t2_equip_refining_ranks.length;
				temp_repeated_byte_equip_refining_ranks.writeInt(len_tVo_equip_refining_ranks);
				temp_repeated_byte_equip_refining_ranks.writeBytes(t2_equip_refining_ranks);
			}
			output.writeInt(temp_repeated_byte_equip_refining_ranks.length);
			output.writeBytes(temp_repeated_byte_equip_refining_ranks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_equip_refining_ranks:int = input.readShort();
			var length_equip_refining_ranks:int = input.readInt();
			if (length_equip_refining_ranks > 0) {
				var byte_equip_refining_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_equip_refining_ranks, 0, length_equip_refining_ranks);
				for(i=0; i<size_equip_refining_ranks; i++) {
					var tmp_equip_refining_ranks:p_equip_rank = new p_equip_rank;
					var tmp_equip_refining_ranks_length:int = byte_equip_refining_ranks.readInt();
					var tmp_equip_refining_ranks_byte:ByteArray = new ByteArray;
					byte_equip_refining_ranks.readBytes(tmp_equip_refining_ranks_byte, 0, tmp_equip_refining_ranks_length);
					tmp_equip_refining_ranks.readFromDataOutput(tmp_equip_refining_ranks_byte);
					this.equip_refining_ranks.push(tmp_equip_refining_ranks);
				}
			}
		}
	}
}
