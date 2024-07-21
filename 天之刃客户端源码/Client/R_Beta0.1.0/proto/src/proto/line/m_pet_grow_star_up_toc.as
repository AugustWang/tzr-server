package proto.line {
	import proto.common.p_pet_grow;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_grow_star_up_toc extends Message
	{
		public var succ:Boolean = true;
		public var succ2:Boolean = true;
		public var reason:String = "";
		public var info:p_pet_grow = null;
		public function m_pet_grow_star_up_toc() {
			super();
			this.info = new p_pet_grow;

			flash.net.registerClassAlias("copy.proto.line.m_pet_grow_star_up_toc", m_pet_grow_star_up_toc);
		}
		public override function getMethodName():String {
			return 'pet_grow_star_up';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.succ2);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_info:ByteArray = new ByteArray;
			this.info.writeToDataOutput(tmp_info);
			var size_tmp_info:int = tmp_info.length;
			output.writeInt(size_tmp_info);
			output.writeBytes(tmp_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.succ2 = input.readBoolean();
			this.reason = input.readUTF();
			var byte_info_size:int = input.readInt();
			if (byte_info_size > 0) {				this.info = new p_pet_grow;
				var byte_info:ByteArray = new ByteArray;
				input.readBytes(byte_info, 0, byte_info_size);
				this.info.readFromDataOutput(byte_info);
			}
		}
	}
}
