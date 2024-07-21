package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_special_activity_list_toc extends Message
	{
		public var key_list:Array = new Array;
		public function m_special_activity_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_special_activity_list_toc", m_special_activity_list_toc);
		}
		public override function getMethodName():String {
			return 'special_activity_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_key_list:int = this.key_list.length;
			output.writeShort(size_key_list);
			var temp_repeated_byte_key_list:ByteArray= new ByteArray;
			for(i=0; i<size_key_list; i++) {
				temp_repeated_byte_key_list.writeInt(this.key_list[i]);
			}
			output.writeInt(temp_repeated_byte_key_list.length);
			output.writeBytes(temp_repeated_byte_key_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_key_list:int = input.readShort();
			var length_key_list:int = input.readInt();
			var byte_key_list:ByteArray = new ByteArray; 
			if (size_key_list > 0) {
				input.readBytes(byte_key_list, 0, size_key_list * 4);
				for(i=0; i<size_key_list; i++) {
					var tmp_key_list:int = byte_key_list.readInt();
					this.key_list.push(tmp_key_list);
				}
			}
		}
	}
}
