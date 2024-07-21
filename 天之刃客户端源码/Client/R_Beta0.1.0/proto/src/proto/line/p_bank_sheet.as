package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_bank_sheet extends Message
	{
		public var sheet_id:int = 0;
		public var roleid:int = 0;
		public var price:int = 0;
		public var num:int = 0;
		public var type:Boolean = true;
		public var time:int = 0;
		public function p_bank_sheet() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_bank_sheet", p_bank_sheet);
		}
		public override function getMethodName():String {
			return 'bank_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.sheet_id);
			output.writeInt(this.roleid);
			output.writeInt(this.price);
			output.writeInt(this.num);
			output.writeBoolean(this.type);
			output.writeInt(this.time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.sheet_id = input.readInt();
			this.roleid = input.readInt();
			this.price = input.readInt();
			this.num = input.readInt();
			this.type = input.readBoolean();
			this.time = input.readInt();
		}
	}
}
