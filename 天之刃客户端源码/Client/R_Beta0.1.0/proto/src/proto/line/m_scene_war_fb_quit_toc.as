package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_quit_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var npc_id:int = 0;
		public var fb_type:int = 0;
		public var fb_level:int = 0;
		public function m_scene_war_fb_quit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_quit_toc", m_scene_war_fb_quit_toc);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.npc_id);
			output.writeInt(this.fb_type);
			output.writeInt(this.fb_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.npc_id = input.readInt();
			this.fb_type = input.readInt();
			this.fb_level = input.readInt();
		}
	}
}
