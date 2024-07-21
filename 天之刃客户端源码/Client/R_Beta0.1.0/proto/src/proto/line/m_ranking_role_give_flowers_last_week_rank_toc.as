package proto.line {
	import proto.common.p_role_give_flowers_last_week_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_role_give_flowers_last_week_rank_toc extends Message
	{
		public var role_give_flowers:Array = new Array;
		public function m_ranking_role_give_flowers_last_week_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_role_give_flowers_last_week_rank_toc", m_ranking_role_give_flowers_last_week_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_role_give_flowers_last_week_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_role_give_flowers:int = this.role_give_flowers.length;
			output.writeShort(size_role_give_flowers);
			var temp_repeated_byte_role_give_flowers:ByteArray= new ByteArray;
			for(i=0; i<size_role_give_flowers; i++) {
				var t2_role_give_flowers:ByteArray = new ByteArray;
				var tVo_role_give_flowers:p_role_give_flowers_last_week_rank = this.role_give_flowers[i] as p_role_give_flowers_last_week_rank;
				tVo_role_give_flowers.writeToDataOutput(t2_role_give_flowers);
				var len_tVo_role_give_flowers:int = t2_role_give_flowers.length;
				temp_repeated_byte_role_give_flowers.writeInt(len_tVo_role_give_flowers);
				temp_repeated_byte_role_give_flowers.writeBytes(t2_role_give_flowers);
			}
			output.writeInt(temp_repeated_byte_role_give_flowers.length);
			output.writeBytes(temp_repeated_byte_role_give_flowers);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_role_give_flowers:int = input.readShort();
			var length_role_give_flowers:int = input.readInt();
			if (length_role_give_flowers > 0) {
				var byte_role_give_flowers:ByteArray = new ByteArray; 
				input.readBytes(byte_role_give_flowers, 0, length_role_give_flowers);
				for(i=0; i<size_role_give_flowers; i++) {
					var tmp_role_give_flowers:p_role_give_flowers_last_week_rank = new p_role_give_flowers_last_week_rank;
					var tmp_role_give_flowers_length:int = byte_role_give_flowers.readInt();
					var tmp_role_give_flowers_byte:ByteArray = new ByteArray;
					byte_role_give_flowers.readBytes(tmp_role_give_flowers_byte, 0, tmp_role_give_flowers_length);
					tmp_role_give_flowers.readFromDataOutput(tmp_role_give_flowers_byte);
					this.role_give_flowers.push(tmp_role_give_flowers);
				}
			}
		}
	}
}
