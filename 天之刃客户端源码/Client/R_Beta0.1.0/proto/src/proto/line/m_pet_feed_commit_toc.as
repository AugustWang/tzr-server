package proto.line {
	import proto.common.p_pet_feed;
	import proto.common.p_pet;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_feed_commit_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var info:p_pet_feed = null;
		public var pet_info:p_pet = null;
		public function m_pet_feed_commit_toc() {
			super();
			this.info = new p_pet_feed;
			this.pet_info = new p_pet;

			flash.net.registerClassAlias("copy.proto.line.m_pet_feed_commit_toc", m_pet_feed_commit_toc);
		}
		public override function getMethodName():String {
			return 'pet_feed_commit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_info:ByteArray = new ByteArray;
			this.info.writeToDataOutput(tmp_info);
			var size_tmp_info:int = tmp_info.length;
			output.writeInt(size_tmp_info);
			output.writeBytes(tmp_info);
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
			var byte_info_size:int = input.readInt();
			if (byte_info_size > 0) {				this.info = new p_pet_feed;
				var byte_info:ByteArray = new ByteArray;
				input.readBytes(byte_info, 0, byte_info_size);
				this.info.readFromDataOutput(byte_info);
			}
			var byte_pet_info_size:int = input.readInt();
			if (byte_pet_info_size > 0) {				this.pet_info = new p_pet;
				var byte_pet_info:ByteArray = new ByteArray;
				input.readBytes(byte_pet_info, 0, byte_pet_info_size);
				this.pet_info.readFromDataOutput(byte_pet_info);
			}
		}
	}
}
