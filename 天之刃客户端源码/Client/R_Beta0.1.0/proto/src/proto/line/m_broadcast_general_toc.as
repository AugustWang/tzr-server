package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_broadcast_general_toc extends Message
	{
		public var type:Array = new Array;
		public var sub_type:int = 0;
		public var content:String = "";
		public var ext_info_list:Array = new Array;
		public function m_broadcast_general_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_broadcast_general_toc", m_broadcast_general_toc);
		}
		public override function getMethodName():String {
			return 'broadcast_general';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_type:int = this.type.length;
			output.writeShort(size_type);
			var temp_repeated_byte_type:ByteArray= new ByteArray;
			for(i=0; i<size_type; i++) {
				temp_repeated_byte_type.writeInt(this.type[i]);
			}
			output.writeInt(temp_repeated_byte_type.length);
			output.writeBytes(temp_repeated_byte_type);
			output.writeInt(this.sub_type);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			var size_ext_info_list:int = this.ext_info_list.length;
			output.writeShort(size_ext_info_list);
			var temp_repeated_byte_ext_info_list:ByteArray= new ByteArray;
			for(i=0; i<size_ext_info_list; i++) {
				if (this.ext_info_list != null) {					temp_repeated_byte_ext_info_list.writeUTF(this.ext_info_list[i].toString());
				} else {
					temp_repeated_byte_ext_info_list.writeUTF("");
				}
			}
			output.writeInt(temp_repeated_byte_ext_info_list.length);
			output.writeBytes(temp_repeated_byte_ext_info_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_type:int = input.readShort();
			var length_type:int = input.readInt();
			var byte_type:ByteArray = new ByteArray; 
			if (size_type > 0) {
				input.readBytes(byte_type, 0, size_type * 4);
				for(i=0; i<size_type; i++) {
					var tmp_type:int = byte_type.readInt();
					this.type.push(tmp_type);
				}
			}
			this.sub_type = input.readInt();
			this.content = input.readUTF();
			var size_ext_info_list:int = input.readShort();
			var length_ext_info_list:int = input.readInt();
			if (size_ext_info_list>0) {
				var byte_ext_info_list:ByteArray = new ByteArray; 
				input.readBytes(byte_ext_info_list, 0, length_ext_info_list);
				for(i=0; i<size_ext_info_list; i++) {
					var tmp_ext_info_list:String = byte_ext_info_list.readUTF(); 
					this.ext_info_list.push(tmp_ext_info_list);
				}
			}
		}
	}
}
