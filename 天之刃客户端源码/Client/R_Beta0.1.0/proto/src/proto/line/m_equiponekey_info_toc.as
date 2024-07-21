package proto.line {
	import proto.common.p_equip_onekey_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equiponekey_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var equips_list:p_equip_onekey_info = null;
		public var reason:String = "";
		public function m_equiponekey_info_toc() {
			super();
			this.equips_list = new p_equip_onekey_info;

			flash.net.registerClassAlias("copy.proto.line.m_equiponekey_info_toc", m_equiponekey_info_toc);
		}
		public override function getMethodName():String {
			return 'equiponekey_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_equips_list:ByteArray = new ByteArray;
			this.equips_list.writeToDataOutput(tmp_equips_list);
			var size_tmp_equips_list:int = tmp_equips_list.length;
			output.writeInt(size_tmp_equips_list);
			output.writeBytes(tmp_equips_list);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_equips_list_size:int = input.readInt();
			if (byte_equips_list_size > 0) {				this.equips_list = new p_equip_onekey_info;
				var byte_equips_list:ByteArray = new ByteArray;
				input.readBytes(byte_equips_list, 0, byte_equips_list_size);
				this.equips_list.readFromDataOutput(byte_equips_list);
			}
			this.reason = input.readUTF();
		}
	}
}
