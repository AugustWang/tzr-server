package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_change_relative_toc extends Message
	{
		public var role_id:int = 0;
		public var relative:Array = new Array;
		public function m_friend_change_relative_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_change_relative_toc", m_friend_change_relative_toc);
		}
		public override function getMethodName():String {
			return 'friend_change_relative';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			var size_relative:int = this.relative.length;
			output.writeShort(size_relative);
			var temp_repeated_byte_relative:ByteArray= new ByteArray;
			for(i=0; i<size_relative; i++) {
				temp_repeated_byte_relative.writeInt(this.relative[i]);
			}
			output.writeInt(temp_repeated_byte_relative.length);
			output.writeBytes(temp_repeated_byte_relative);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			var size_relative:int = input.readShort();
			var length_relative:int = input.readInt();
			var byte_relative:ByteArray = new ByteArray; 
			if (size_relative > 0) {
				input.readBytes(byte_relative, 0, size_relative * 4);
				for(i=0; i<size_relative; i++) {
					var tmp_relative:int = byte_relative.readInt();
					this.relative.push(tmp_relative);
				}
			}
		}
	}
}
