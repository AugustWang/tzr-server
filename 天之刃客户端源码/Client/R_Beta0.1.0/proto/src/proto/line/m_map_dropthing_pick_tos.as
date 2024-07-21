package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_dropthing_pick_tos extends Message
	{
		public var dropthingid:int = 0;
		public function m_map_dropthing_pick_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_dropthing_pick_tos", m_map_dropthing_pick_tos);
		}
		public override function getMethodName():String {
			return 'map_dropthing_pick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.dropthingid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.dropthingid = input.readInt();
		}
	}
}
