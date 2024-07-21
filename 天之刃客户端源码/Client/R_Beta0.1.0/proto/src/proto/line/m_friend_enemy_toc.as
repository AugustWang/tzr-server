package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_enemy_toc extends Message
	{
		public var enemy_info:p_friend_info = null;
		public function m_friend_enemy_toc() {
			super();
			this.enemy_info = new p_friend_info;

			flash.net.registerClassAlias("copy.proto.line.m_friend_enemy_toc", m_friend_enemy_toc);
		}
		public override function getMethodName():String {
			return 'friend_enemy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_enemy_info:ByteArray = new ByteArray;
			this.enemy_info.writeToDataOutput(tmp_enemy_info);
			var size_tmp_enemy_info:int = tmp_enemy_info.length;
			output.writeInt(size_tmp_enemy_info);
			output.writeBytes(tmp_enemy_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_enemy_info_size:int = input.readInt();
			if (byte_enemy_info_size > 0) {				this.enemy_info = new p_friend_info;
				var byte_enemy_info:ByteArray = new ByteArray;
				input.readBytes(byte_enemy_info, 0, byte_enemy_info_size);
				this.enemy_info.readFromDataOutput(byte_enemy_info);
			}
		}
	}
}
