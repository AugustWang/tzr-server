package proto.line {
	import proto.common.p_fmldepot_bag;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_list_goods_toc extends Message
	{
		public var depots:Array = new Array;
		public function m_fmldepot_list_goods_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_list_goods_toc", m_fmldepot_list_goods_toc);
		}
		public override function getMethodName():String {
			return 'fmldepot_list_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_depots:int = this.depots.length;
			output.writeShort(size_depots);
			var temp_repeated_byte_depots:ByteArray= new ByteArray;
			for(i=0; i<size_depots; i++) {
				var t2_depots:ByteArray = new ByteArray;
				var tVo_depots:p_fmldepot_bag = this.depots[i] as p_fmldepot_bag;
				tVo_depots.writeToDataOutput(t2_depots);
				var len_tVo_depots:int = t2_depots.length;
				temp_repeated_byte_depots.writeInt(len_tVo_depots);
				temp_repeated_byte_depots.writeBytes(t2_depots);
			}
			output.writeInt(temp_repeated_byte_depots.length);
			output.writeBytes(temp_repeated_byte_depots);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_depots:int = input.readShort();
			var length_depots:int = input.readInt();
			if (length_depots > 0) {
				var byte_depots:ByteArray = new ByteArray; 
				input.readBytes(byte_depots, 0, length_depots);
				for(i=0; i<size_depots; i++) {
					var tmp_depots:p_fmldepot_bag = new p_fmldepot_bag;
					var tmp_depots_length:int = byte_depots.readInt();
					var tmp_depots_byte:ByteArray = new ByteArray;
					byte_depots.readBytes(tmp_depots_byte, 0, tmp_depots_length);
					tmp_depots.readFromDataOutput(tmp_depots_byte);
					this.depots.push(tmp_depots);
				}
			}
		}
	}
}
