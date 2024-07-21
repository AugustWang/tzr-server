package proto.line {
	import proto.common.p_walk_path;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_walk_path_toc extends Message
	{
		public var monsterid:int = 0;
		public var walk_path:p_walk_path = null;
		public function m_monster_walk_path_toc() {
			super();
			this.walk_path = new p_walk_path;

			flash.net.registerClassAlias("copy.proto.line.m_monster_walk_path_toc", m_monster_walk_path_toc);
		}
		public override function getMethodName():String {
			return 'monster_walk_path';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.monsterid);
			var tmp_walk_path:ByteArray = new ByteArray;
			this.walk_path.writeToDataOutput(tmp_walk_path);
			var size_tmp_walk_path:int = tmp_walk_path.length;
			output.writeInt(size_tmp_walk_path);
			output.writeBytes(tmp_walk_path);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.monsterid = input.readInt();
			var byte_walk_path_size:int = input.readInt();
			if (byte_walk_path_size > 0) {				this.walk_path = new p_walk_path;
				var byte_walk_path:ByteArray = new ByteArray;
				input.readBytes(byte_walk_path, 0, byte_walk_path_size);
				this.walk_path.readFromDataOutput(byte_walk_path);
			}
		}
	}
}
