package proto.line {
	import proto.common.p_role_pet_bag;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_throw_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var bag_info:p_role_pet_bag = null;
		public function m_pet_throw_toc() {
			super();
			this.bag_info = new p_role_pet_bag;

			flash.net.registerClassAlias("copy.proto.line.m_pet_throw_toc", m_pet_throw_toc);
		}
		public override function getMethodName():String {
			return 'pet_throw';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_bag_info:ByteArray = new ByteArray;
			this.bag_info.writeToDataOutput(tmp_bag_info);
			var size_tmp_bag_info:int = tmp_bag_info.length;
			output.writeInt(size_tmp_bag_info);
			output.writeBytes(tmp_bag_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_bag_info_size:int = input.readInt();
			if (byte_bag_info_size > 0) {				this.bag_info = new p_role_pet_bag;
				var byte_bag_info:ByteArray = new ByteArray;
				input.readBytes(byte_bag_info, 0, byte_bag_info_size);
				this.bag_info.readFromDataOutput(byte_bag_info);
			}
		}
	}
}
