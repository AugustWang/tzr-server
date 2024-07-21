package proto.line {
	import proto.line.p_family_summary;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_list_toc extends Message
	{
		public var family_list:Array = new Array;
		public var total_page:int = 0;
		public var page_id:int = 0;
		public var request_from:int = 1;
		public function m_family_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_list_toc", m_family_list_toc);
		}
		public override function getMethodName():String {
			return 'family_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_family_list:int = this.family_list.length;
			output.writeShort(size_family_list);
			var temp_repeated_byte_family_list:ByteArray= new ByteArray;
			for(i=0; i<size_family_list; i++) {
				var t2_family_list:ByteArray = new ByteArray;
				var tVo_family_list:p_family_summary = this.family_list[i] as p_family_summary;
				tVo_family_list.writeToDataOutput(t2_family_list);
				var len_tVo_family_list:int = t2_family_list.length;
				temp_repeated_byte_family_list.writeInt(len_tVo_family_list);
				temp_repeated_byte_family_list.writeBytes(t2_family_list);
			}
			output.writeInt(temp_repeated_byte_family_list.length);
			output.writeBytes(temp_repeated_byte_family_list);
			output.writeInt(this.total_page);
			output.writeInt(this.page_id);
			output.writeInt(this.request_from);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_family_list:int = input.readShort();
			var length_family_list:int = input.readInt();
			if (length_family_list > 0) {
				var byte_family_list:ByteArray = new ByteArray; 
				input.readBytes(byte_family_list, 0, length_family_list);
				for(i=0; i<size_family_list; i++) {
					var tmp_family_list:p_family_summary = new p_family_summary;
					var tmp_family_list_length:int = byte_family_list.readInt();
					var tmp_family_list_byte:ByteArray = new ByteArray;
					byte_family_list.readBytes(tmp_family_list_byte, 0, tmp_family_list_length);
					tmp_family_list.readFromDataOutput(tmp_family_list_byte);
					this.family_list.push(tmp_family_list);
				}
			}
			this.total_page = input.readInt();
			this.page_id = input.readInt();
			this.request_from = input.readInt();
		}
	}
}
