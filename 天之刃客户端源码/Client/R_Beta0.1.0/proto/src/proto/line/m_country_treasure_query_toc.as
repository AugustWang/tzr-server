package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_country_treasure_query_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var op_type:int = 0;
		public var fb_start_time:int = 0;
		public var fb_end_time:int = 0;
		public var npc_id:int = 0;
		public var fee:int = 0;
		public function m_country_treasure_query_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_country_treasure_query_toc", m_country_treasure_query_toc);
		}
		public override function getMethodName():String {
			return 'country_treasure_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.op_type);
			output.writeInt(this.fb_start_time);
			output.writeInt(this.fb_end_time);
			output.writeInt(this.npc_id);
			output.writeInt(this.fee);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.op_type = input.readInt();
			this.fb_start_time = input.readInt();
			this.fb_end_time = input.readInt();
			this.npc_id = input.readInt();
			this.fee = input.readInt();
		}
	}
}
