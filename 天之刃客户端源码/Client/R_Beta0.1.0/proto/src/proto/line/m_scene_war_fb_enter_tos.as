package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_enter_tos extends Message
	{
		public var npc_id:int = 0;
		public var fb_type:int = 0;
		public var fb_level:int = 0;
		public var fb_id:int = 0;
		public var fb_seconds:int = 0;
		public function m_scene_war_fb_enter_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_enter_tos", m_scene_war_fb_enter_tos);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
			output.writeInt(this.fb_type);
			output.writeInt(this.fb_level);
			output.writeInt(this.fb_id);
			output.writeInt(this.fb_seconds);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.fb_type = input.readInt();
			this.fb_level = input.readInt();
			this.fb_id = input.readInt();
			this.fb_seconds = input.readInt();
		}
	}
}
