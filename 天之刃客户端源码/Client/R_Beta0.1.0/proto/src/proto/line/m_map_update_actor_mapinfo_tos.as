package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_update_actor_mapinfo_tos extends Message
	{
		public var actor_id:int = 0;
		public var actor_type:int = 0;
		public var map_id:int = 0;
		public function m_map_update_actor_mapinfo_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_update_actor_mapinfo_tos", m_map_update_actor_mapinfo_tos);
		}
		public override function getMethodName():String {
			return 'map_update_actor_mapinfo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.actor_id);
			output.writeInt(this.actor_type);
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.actor_id = input.readInt();
			this.actor_type = input.readInt();
			this.map_id = input.readInt();
		}
	}
}
