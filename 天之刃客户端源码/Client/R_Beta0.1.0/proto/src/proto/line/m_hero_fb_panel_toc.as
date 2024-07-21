package proto.line {
	import proto.common.p_role_hero_fb_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_hero_fb_panel_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var hero_fb:p_role_hero_fb_info = null;
		public function m_hero_fb_panel_toc() {
			super();
			this.hero_fb = new p_role_hero_fb_info;

			flash.net.registerClassAlias("copy.proto.line.m_hero_fb_panel_toc", m_hero_fb_panel_toc);
		}
		public override function getMethodName():String {
			return 'hero_fb_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_hero_fb:ByteArray = new ByteArray;
			this.hero_fb.writeToDataOutput(tmp_hero_fb);
			var size_tmp_hero_fb:int = tmp_hero_fb.length;
			output.writeInt(size_tmp_hero_fb);
			output.writeBytes(tmp_hero_fb);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_hero_fb_size:int = input.readInt();
			if (byte_hero_fb_size > 0) {				this.hero_fb = new p_role_hero_fb_info;
				var byte_hero_fb:ByteArray = new ByteArray;
				input.readBytes(byte_hero_fb, 0, byte_hero_fb_size);
				this.hero_fb.readFromDataOutput(byte_hero_fb);
			}
		}
	}
}
