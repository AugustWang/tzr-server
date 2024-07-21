package proto.line {
	import proto.common.p_hero_fb_rank;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_hero_fb_rank_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var hero_fb_ranks:Array = new Array;
		public function m_ranking_hero_fb_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_hero_fb_rank_toc", m_ranking_hero_fb_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_hero_fb_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_hero_fb_ranks:int = this.hero_fb_ranks.length;
			output.writeShort(size_hero_fb_ranks);
			var temp_repeated_byte_hero_fb_ranks:ByteArray= new ByteArray;
			for(i=0; i<size_hero_fb_ranks; i++) {
				var t2_hero_fb_ranks:ByteArray = new ByteArray;
				var tVo_hero_fb_ranks:p_hero_fb_rank = this.hero_fb_ranks[i] as p_hero_fb_rank;
				tVo_hero_fb_ranks.writeToDataOutput(t2_hero_fb_ranks);
				var len_tVo_hero_fb_ranks:int = t2_hero_fb_ranks.length;
				temp_repeated_byte_hero_fb_ranks.writeInt(len_tVo_hero_fb_ranks);
				temp_repeated_byte_hero_fb_ranks.writeBytes(t2_hero_fb_ranks);
			}
			output.writeInt(temp_repeated_byte_hero_fb_ranks.length);
			output.writeBytes(temp_repeated_byte_hero_fb_ranks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_hero_fb_ranks:int = input.readShort();
			var length_hero_fb_ranks:int = input.readInt();
			if (length_hero_fb_ranks > 0) {
				var byte_hero_fb_ranks:ByteArray = new ByteArray; 
				input.readBytes(byte_hero_fb_ranks, 0, length_hero_fb_ranks);
				for(i=0; i<size_hero_fb_ranks; i++) {
					var tmp_hero_fb_ranks:p_hero_fb_rank = new p_hero_fb_rank;
					var tmp_hero_fb_ranks_length:int = byte_hero_fb_ranks.readInt();
					var tmp_hero_fb_ranks_byte:ByteArray = new ByteArray;
					byte_hero_fb_ranks.readBytes(tmp_hero_fb_ranks_byte, 0, tmp_hero_fb_ranks_length);
					tmp_hero_fb_ranks.readFromDataOutput(tmp_hero_fb_ranks_byte);
					this.hero_fb_ranks.push(tmp_hero_fb_ranks);
				}
			}
		}
	}
}
