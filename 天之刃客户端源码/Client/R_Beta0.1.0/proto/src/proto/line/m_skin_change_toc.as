package proto.line {
	import proto.common.p_skin;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_skin_change_toc extends Message
	{
		public var roleid:int = 0;
		public var skin:p_skin = null;
		public function m_skin_change_toc() {
			super();
			this.skin = new p_skin;

			flash.net.registerClassAlias("copy.proto.line.m_skin_change_toc", m_skin_change_toc);
		}
		public override function getMethodName():String {
			return 'skin_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			var tmp_skin:ByteArray = new ByteArray;
			this.skin.writeToDataOutput(tmp_skin);
			var size_tmp_skin:int = tmp_skin.length;
			output.writeInt(size_tmp_skin);
			output.writeBytes(tmp_skin);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			var byte_skin_size:int = input.readInt();
			if (byte_skin_size > 0) {				this.skin = new p_skin;
				var byte_skin:ByteArray = new ByteArray;
				input.readBytes(byte_skin, 0, byte_skin_size);
				this.skin.readFromDataOutput(byte_skin);
			}
		}
	}
}
