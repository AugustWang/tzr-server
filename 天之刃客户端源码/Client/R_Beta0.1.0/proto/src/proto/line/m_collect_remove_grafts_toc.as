package proto.line {
	import proto.common.p_map_collect;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_collect_remove_grafts_toc extends Message
	{
		public var grafts:Array = new Array;
		public function m_collect_remove_grafts_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_collect_remove_grafts_toc", m_collect_remove_grafts_toc);
		}
		public override function getMethodName():String {
			return 'collect_remove_grafts';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_grafts:int = this.grafts.length;
			output.writeShort(size_grafts);
			var temp_repeated_byte_grafts:ByteArray= new ByteArray;
			for(i=0; i<size_grafts; i++) {
				var t2_grafts:ByteArray = new ByteArray;
				var tVo_grafts:p_map_collect = this.grafts[i] as p_map_collect;
				tVo_grafts.writeToDataOutput(t2_grafts);
				var len_tVo_grafts:int = t2_grafts.length;
				temp_repeated_byte_grafts.writeInt(len_tVo_grafts);
				temp_repeated_byte_grafts.writeBytes(t2_grafts);
			}
			output.writeInt(temp_repeated_byte_grafts.length);
			output.writeBytes(temp_repeated_byte_grafts);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_grafts:int = input.readShort();
			var length_grafts:int = input.readInt();
			if (length_grafts > 0) {
				var byte_grafts:ByteArray = new ByteArray; 
				input.readBytes(byte_grafts, 0, length_grafts);
				for(i=0; i<size_grafts; i++) {
					var tmp_grafts:p_map_collect = new p_map_collect;
					var tmp_grafts_length:int = byte_grafts.readInt();
					var tmp_grafts_byte:ByteArray = new ByteArray;
					byte_grafts.readBytes(tmp_grafts_byte, 0, tmp_grafts_length);
					tmp_grafts.readFromDataOutput(tmp_grafts_byte);
					this.grafts.push(tmp_grafts);
				}
			}
		}
	}
}
