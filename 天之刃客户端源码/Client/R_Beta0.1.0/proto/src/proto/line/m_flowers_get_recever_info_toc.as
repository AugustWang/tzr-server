package proto.line {
	import proto.common.p_role_base;
	import proto.common.p_role_attr;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_get_recever_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var rolebase:p_role_base = null;
		public var roleattr:p_role_attr = null;
		public function m_flowers_get_recever_info_toc() {
			super();
			this.rolebase = new p_role_base;
			this.roleattr = new p_role_attr;

			flash.net.registerClassAlias("copy.proto.line.m_flowers_get_recever_info_toc", m_flowers_get_recever_info_toc);
		}
		public override function getMethodName():String {
			return 'flowers_get_recever_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_rolebase:ByteArray = new ByteArray;
			this.rolebase.writeToDataOutput(tmp_rolebase);
			var size_tmp_rolebase:int = tmp_rolebase.length;
			output.writeInt(size_tmp_rolebase);
			output.writeBytes(tmp_rolebase);
			var tmp_roleattr:ByteArray = new ByteArray;
			this.roleattr.writeToDataOutput(tmp_roleattr);
			var size_tmp_roleattr:int = tmp_roleattr.length;
			output.writeInt(size_tmp_roleattr);
			output.writeBytes(tmp_roleattr);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_rolebase_size:int = input.readInt();
			if (byte_rolebase_size > 0) {				this.rolebase = new p_role_base;
				var byte_rolebase:ByteArray = new ByteArray;
				input.readBytes(byte_rolebase, 0, byte_rolebase_size);
				this.rolebase.readFromDataOutput(byte_rolebase);
			}
			var byte_roleattr_size:int = input.readInt();
			if (byte_roleattr_size > 0) {				this.roleattr = new p_role_attr;
				var byte_roleattr:ByteArray = new ByteArray;
				input.readBytes(byte_roleattr, 0, byte_roleattr_size);
				this.roleattr.readFromDataOutput(byte_roleattr);
			}
		}
	}
}
