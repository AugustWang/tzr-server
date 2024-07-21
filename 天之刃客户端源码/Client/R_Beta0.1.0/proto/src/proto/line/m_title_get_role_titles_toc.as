package proto.line {
	import proto.common.p_title;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_title_get_role_titles_toc extends Message
	{
		public var titles:Array = new Array;
		public function m_title_get_role_titles_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_title_get_role_titles_toc", m_title_get_role_titles_toc);
		}
		public override function getMethodName():String {
			return 'title_get_role_titles';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_titles:int = this.titles.length;
			output.writeShort(size_titles);
			var temp_repeated_byte_titles:ByteArray= new ByteArray;
			for(i=0; i<size_titles; i++) {
				var t2_titles:ByteArray = new ByteArray;
				var tVo_titles:p_title = this.titles[i] as p_title;
				tVo_titles.writeToDataOutput(t2_titles);
				var len_tVo_titles:int = t2_titles.length;
				temp_repeated_byte_titles.writeInt(len_tVo_titles);
				temp_repeated_byte_titles.writeBytes(t2_titles);
			}
			output.writeInt(temp_repeated_byte_titles.length);
			output.writeBytes(temp_repeated_byte_titles);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_titles:int = input.readShort();
			var length_titles:int = input.readInt();
			if (length_titles > 0) {
				var byte_titles:ByteArray = new ByteArray; 
				input.readBytes(byte_titles, 0, length_titles);
				for(i=0; i<size_titles; i++) {
					var tmp_titles:p_title = new p_title;
					var tmp_titles_length:int = byte_titles.readInt();
					var tmp_titles_byte:ByteArray = new ByteArray;
					byte_titles.readBytes(tmp_titles_byte, 0, tmp_titles_length);
					tmp_titles.readFromDataOutput(tmp_titles_byte);
					this.titles.push(tmp_titles);
				}
			}
		}
	}
}
