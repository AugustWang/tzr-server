package proto.line {
	import proto.common.p_ranking;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_config_toc extends Message
	{
		public var rankings:Array = new Array;
		public function m_ranking_config_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_config_toc", m_ranking_config_toc);
		}
		public override function getMethodName():String {
			return 'ranking_config';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_rankings:int = this.rankings.length;
			output.writeShort(size_rankings);
			var temp_repeated_byte_rankings:ByteArray= new ByteArray;
			for(i=0; i<size_rankings; i++) {
				var t2_rankings:ByteArray = new ByteArray;
				var tVo_rankings:p_ranking = this.rankings[i] as p_ranking;
				tVo_rankings.writeToDataOutput(t2_rankings);
				var len_tVo_rankings:int = t2_rankings.length;
				temp_repeated_byte_rankings.writeInt(len_tVo_rankings);
				temp_repeated_byte_rankings.writeBytes(t2_rankings);
			}
			output.writeInt(temp_repeated_byte_rankings.length);
			output.writeBytes(temp_repeated_byte_rankings);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_rankings:int = input.readShort();
			var length_rankings:int = input.readInt();
			if (length_rankings > 0) {
				var byte_rankings:ByteArray = new ByteArray; 
				input.readBytes(byte_rankings, 0, length_rankings);
				for(i=0; i<size_rankings; i++) {
					var tmp_rankings:p_ranking = new p_ranking;
					var tmp_rankings_length:int = byte_rankings.readInt();
					var tmp_rankings_byte:ByteArray = new ByteArray;
					byte_rankings.readBytes(tmp_rankings_byte, 0, tmp_rankings_length);
					tmp_rankings.readFromDataOutput(tmp_rankings_byte);
					this.rankings.push(tmp_rankings);
				}
			}
		}
	}
}
