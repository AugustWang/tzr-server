package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_call_monster_toc extends Message
	{
		public var op_type:int = 1;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var npc_id:int = 0;
		public var pass_id:int = 0;
		public function m_scene_war_fb_call_monster_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_call_monster_toc", m_scene_war_fb_call_monster_toc);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_call_monster';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.npc_id);
			output.writeInt(this.pass_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.npc_id = input.readInt();
			this.pass_id = input.readInt();
		}
	}
}
