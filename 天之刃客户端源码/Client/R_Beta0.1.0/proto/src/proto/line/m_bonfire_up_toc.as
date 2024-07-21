package proto.line {
	import proto.common.p_map_bonfire;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bonfire_up_toc extends Message
	{
		public var bnfires:Array = new Array;
		public function m_bonfire_up_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bonfire_up_toc", m_bonfire_up_toc);
		}
		public override function getMethodName():String {
			return 'bonfire_up';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_bnfires:int = this.bnfires.length;
			output.writeShort(size_bnfires);
			var temp_repeated_byte_bnfires:ByteArray= new ByteArray;
			for(i=0; i<size_bnfires; i++) {
				var t2_bnfires:ByteArray = new ByteArray;
				var tVo_bnfires:p_map_bonfire = this.bnfires[i] as p_map_bonfire;
				tVo_bnfires.writeToDataOutput(t2_bnfires);
				var len_tVo_bnfires:int = t2_bnfires.length;
				temp_repeated_byte_bnfires.writeInt(len_tVo_bnfires);
				temp_repeated_byte_bnfires.writeBytes(t2_bnfires);
			}
			output.writeInt(temp_repeated_byte_bnfires.length);
			output.writeBytes(temp_repeated_byte_bnfires);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_bnfires:int = input.readShort();
			var length_bnfires:int = input.readInt();
			if (length_bnfires > 0) {
				var byte_bnfires:ByteArray = new ByteArray; 
				input.readBytes(byte_bnfires, 0, length_bnfires);
				for(i=0; i<size_bnfires; i++) {
					var tmp_bnfires:p_map_bonfire = new p_map_bonfire;
					var tmp_bnfires_length:int = byte_bnfires.readInt();
					var tmp_bnfires_byte:ByteArray = new ByteArray;
					byte_bnfires.readBytes(tmp_bnfires_byte, 0, tmp_bnfires_length);
					tmp_bnfires.readFromDataOutput(tmp_bnfires_byte);
					this.bnfires.push(tmp_bnfires);
				}
			}
		}
	}
}
