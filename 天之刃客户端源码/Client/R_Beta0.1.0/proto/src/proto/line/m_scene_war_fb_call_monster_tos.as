package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_call_monster_tos extends Message
	{
		public var npc_id:int = 0;
		public var pass_id:int = 0;
		public function m_scene_war_fb_call_monster_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_call_monster_tos", m_scene_war_fb_call_monster_tos);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_call_monster';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
			output.writeInt(this.pass_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.pass_id = input.readInt();
		}
	}
}
