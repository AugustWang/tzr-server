package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_flowers_give_info extends Message
	{
		public var id:int = 0;
		public var give_role_id:int = 0;
		public var giver:String = "";
		public var giver_sex:int = 0;
		public var giver_faction:int = 0;
		public var flowers_type:int = 0;
		public function p_flowers_give_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_flowers_give_info", p_flowers_give_info);
		}
		public override function getMethodName():String {
			return 'flowers_give_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.give_role_id);
			if (this.giver != null) {				output.writeUTF(this.giver.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.giver_sex);
			output.writeInt(this.giver_faction);
			output.writeInt(this.flowers_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.give_role_id = input.readInt();
			this.giver = input.readUTF();
			this.giver_sex = input.readInt();
			this.giver_faction = input.readInt();
			this.flowers_type = input.readInt();
		}
	}
}
