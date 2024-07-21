package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_change_pos_toc extends Message
	{
		public var tx:int = 0;
		public var ty:int = 0;
		public var change_type:int = 0;
		public function m_map_change_pos_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_change_pos_toc", m_map_change_pos_toc);
		}
		public override function getMethodName():String {
			return 'map_change_pos';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.tx);
			output.writeInt(this.ty);
			output.writeInt(this.change_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.tx = input.readInt();
			this.ty = input.readInt();
			this.change_type = input.readInt();
		}
	}
}
