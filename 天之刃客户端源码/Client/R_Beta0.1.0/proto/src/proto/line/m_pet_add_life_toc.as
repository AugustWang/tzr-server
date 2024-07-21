package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_add_life_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var pet_id:int = 0;
		public var life:int = 0;
		public function m_pet_add_life_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_add_life_toc", m_pet_add_life_toc);
		}
		public override function getMethodName():String {
			return 'pet_add_life';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pet_id);
			output.writeInt(this.life);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.pet_id = input.readInt();
			this.life = input.readInt();
		}
	}
}
