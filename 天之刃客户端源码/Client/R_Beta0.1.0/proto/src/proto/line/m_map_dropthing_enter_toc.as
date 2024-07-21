package proto.line {
	import proto.common.p_map_dropthing;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_dropthing_enter_toc extends Message
	{
		public var dropthing:Array = new Array;
		public function m_map_dropthing_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_dropthing_enter_toc", m_map_dropthing_enter_toc);
		}
		public override function getMethodName():String {
			return 'map_dropthing_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_dropthing:int = this.dropthing.length;
			output.writeShort(size_dropthing);
			var temp_repeated_byte_dropthing:ByteArray= new ByteArray;
			for(i=0; i<size_dropthing; i++) {
				var t2_dropthing:ByteArray = new ByteArray;
				var tVo_dropthing:p_map_dropthing = this.dropthing[i] as p_map_dropthing;
				tVo_dropthing.writeToDataOutput(t2_dropthing);
				var len_tVo_dropthing:int = t2_dropthing.length;
				temp_repeated_byte_dropthing.writeInt(len_tVo_dropthing);
				temp_repeated_byte_dropthing.writeBytes(t2_dropthing);
			}
			output.writeInt(temp_repeated_byte_dropthing.length);
			output.writeBytes(temp_repeated_byte_dropthing);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_dropthing:int = input.readShort();
			var length_dropthing:int = input.readInt();
			if (length_dropthing > 0) {
				var byte_dropthing:ByteArray = new ByteArray; 
				input.readBytes(byte_dropthing, 0, length_dropthing);
				for(i=0; i<size_dropthing; i++) {
					var tmp_dropthing:p_map_dropthing = new p_map_dropthing;
					var tmp_dropthing_length:int = byte_dropthing.readInt();
					var tmp_dropthing_byte:ByteArray = new ByteArray;
					byte_dropthing.readBytes(tmp_dropthing_byte, 0, tmp_dropthing_length);
					tmp_dropthing.readFromDataOutput(tmp_dropthing_byte);
					this.dropthing.push(tmp_dropthing);
				}
			}
		}
	}
}
