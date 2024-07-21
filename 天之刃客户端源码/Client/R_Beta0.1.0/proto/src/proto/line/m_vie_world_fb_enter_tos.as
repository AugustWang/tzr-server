package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vie_world_fb_enter_tos extends Message
	{
		public var npc_id:int = 0;
		public var type_id:int = 0;
		public function m_vie_world_fb_enter_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vie_world_fb_enter_tos", m_vie_world_fb_enter_tos);
		}
		public override function getMethodName():String {
			return 'vie_world_fb_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
			output.writeInt(this.type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.type_id = input.readInt();
		}
	}
}
