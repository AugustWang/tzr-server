package proto.line {
	import proto.common.p_role_pet_bag;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_bag_info_toc extends Message
	{
		public var info:p_role_pet_bag = null;
		public function m_pet_bag_info_toc() {
			super();
			this.info = new p_role_pet_bag;

			flash.net.registerClassAlias("copy.proto.line.m_pet_bag_info_toc", m_pet_bag_info_toc);
		}
		public override function getMethodName():String {
			return 'pet_bag_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_info:ByteArray = new ByteArray;
			this.info.writeToDataOutput(tmp_info);
			var size_tmp_info:int = tmp_info.length;
			output.writeInt(size_tmp_info);
			output.writeBytes(tmp_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_info_size:int = input.readInt();
			if (byte_info_size > 0) {				this.info = new p_role_pet_bag;
				var byte_info:ByteArray = new ByteArray;
				input.readBytes(byte_info, 0, byte_info_size);
				this.info.readFromDataOutput(byte_info);
			}
		}
	}
}
