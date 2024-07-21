package proto.line {
	import proto.common.p_pet;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_summon_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var pet_info:p_pet = null;
		public function m_pet_summon_toc() {
			super();
			this.pet_info = new p_pet;

			flash.net.registerClassAlias("copy.proto.line.m_pet_summon_toc", m_pet_summon_toc);
		}
		public override function getMethodName():String {
			return 'pet_summon';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_pet_info:ByteArray = new ByteArray;
			this.pet_info.writeToDataOutput(tmp_pet_info);
			var size_tmp_pet_info:int = tmp_pet_info.length;
			output.writeInt(size_tmp_pet_info);
			output.writeBytes(tmp_pet_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_pet_info_size:int = input.readInt();
			if (byte_pet_info_size > 0) {				this.pet_info = new p_pet;
				var byte_pet_info:ByteArray = new ByteArray;
				input.readBytes(byte_pet_info, 0, byte_pet_info_size);
				this.pet_info.readFromDataOutput(byte_pet_info);
			}
		}
	}
}
