package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_pet_join_rank_toc extends Message
	{
		public var succ:Boolean = false;
		public var rank_id:int = 0;
		public var reason:String = "";
		public function m_ranking_pet_join_rank_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_pet_join_rank_toc", m_ranking_pet_join_rank_toc);
		}
		public override function getMethodName():String {
			return 'ranking_pet_join_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.rank_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.rank_id = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
