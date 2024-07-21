package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bank_add_gold_toc extends Message
	{
		public var gold:int = 0;
		public var type:Boolean = true;
		public var sheet_id:int = 0;
		public var num:int = 0;
		public var if_self:Boolean = true;
		public function m_bank_add_gold_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bank_add_gold_toc", m_bank_add_gold_toc);
		}
		public override function getMethodName():String {
			return 'bank_add_gold';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.gold);
			output.writeBoolean(this.type);
			output.writeInt(this.sheet_id);
			output.writeInt(this.num);
			output.writeBoolean(this.if_self);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.gold = input.readInt();
			this.type = input.readBoolean();
			this.sheet_id = input.readInt();
			this.num = input.readInt();
			this.if_self = input.readBoolean();
		}
	}
}
