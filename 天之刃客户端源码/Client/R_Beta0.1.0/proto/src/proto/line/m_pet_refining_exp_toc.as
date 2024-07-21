package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_refining_exp_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var pet_id:int = 0;
		public var pet_name:String = "";
		public var silver:int = 0;
		public var exp:Number = 0;
		public var pet_color:int = 0;
		public function m_pet_refining_exp_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_refining_exp_toc", m_pet_refining_exp_toc);
		}
		public override function getMethodName():String {
			return 'pet_refining_exp';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pet_id);
			if (this.pet_name != null) {				output.writeUTF(this.pet_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
			output.writeDouble(this.exp);
			output.writeInt(this.pet_color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.pet_id = input.readInt();
			this.pet_name = input.readUTF();
			this.silver = input.readInt();
			this.exp = input.readDouble();
			this.pet_color = input.readInt();
		}
	}
}
