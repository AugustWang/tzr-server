package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_enter_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var fb_fee:int = 0;
		public var fb_times:int = 0;
		public var npc_id:int = 0;
		public var fb_type:int = 0;
		public var fb_level:int = 0;
		public var fb_id:int = 0;
		public var fb_seconds:int = 0;
		public var fb_max_times:int = 0;
		public function m_scene_war_fb_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_enter_toc", m_scene_war_fb_enter_toc);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.fb_fee);
			output.writeInt(this.fb_times);
			output.writeInt(this.npc_id);
			output.writeInt(this.fb_type);
			output.writeInt(this.fb_level);
			output.writeInt(this.fb_id);
			output.writeInt(this.fb_seconds);
			output.writeInt(this.fb_max_times);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.fb_fee = input.readInt();
			this.fb_times = input.readInt();
			this.npc_id = input.readInt();
			this.fb_type = input.readInt();
			this.fb_level = input.readInt();
			this.fb_id = input.readInt();
			this.fb_seconds = input.readInt();
			this.fb_max_times = input.readInt();
		}
	}
}
