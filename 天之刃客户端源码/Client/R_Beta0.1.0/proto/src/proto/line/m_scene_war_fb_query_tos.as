package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_query_tos extends Message
	{
		public var op_type:int = 0;
		public var npc_id:int = 0;
		public function m_scene_war_fb_query_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_query_tos", m_scene_war_fb_query_tos);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.npc_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.npc_id = input.readInt();
		}
	}
}
