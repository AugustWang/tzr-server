package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_clan_info_toc extends Message
	{
		public var clans:Array = new Array;
		public function m_educate_get_clan_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_clan_info_toc", m_educate_get_clan_info_toc);
		}
		public override function getMethodName():String {
			return 'educate_get_clan_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_clans:int = this.clans.length;
			output.writeShort(size_clans);
			var temp_repeated_byte_clans:ByteArray= new ByteArray;
			for(i=0; i<size_clans; i++) {
				var t2_clans:ByteArray = new ByteArray;
				var tVo_clans:p_educate_role_info = this.clans[i] as p_educate_role_info;
				tVo_clans.writeToDataOutput(t2_clans);
				var len_tVo_clans:int = t2_clans.length;
				temp_repeated_byte_clans.writeInt(len_tVo_clans);
				temp_repeated_byte_clans.writeBytes(t2_clans);
			}
			output.writeInt(temp_repeated_byte_clans.length);
			output.writeBytes(temp_repeated_byte_clans);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_clans:int = input.readShort();
			var length_clans:int = input.readInt();
			if (length_clans > 0) {
				var byte_clans:ByteArray = new ByteArray; 
				input.readBytes(byte_clans, 0, length_clans);
				for(i=0; i<size_clans; i++) {
					var tmp_clans:p_educate_role_info = new p_educate_role_info;
					var tmp_clans_length:int = byte_clans.readInt();
					var tmp_clans_byte:ByteArray = new ByteArray;
					byte_clans.readBytes(tmp_clans_byte, 0, tmp_clans_length);
					tmp_clans.readFromDataOutput(tmp_clans_byte);
					this.clans.push(tmp_clans);
				}
			}
		}
	}
}
