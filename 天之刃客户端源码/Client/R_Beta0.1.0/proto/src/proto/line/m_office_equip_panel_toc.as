package proto.line {
	import proto.line.p_office_equip;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_equip_panel_toc extends Message
	{
		public var office_equip:Array = new Array;
		public function m_office_equip_panel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_equip_panel_toc", m_office_equip_panel_toc);
		}
		public override function getMethodName():String {
			return 'office_equip_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_office_equip:int = this.office_equip.length;
			output.writeShort(size_office_equip);
			var temp_repeated_byte_office_equip:ByteArray= new ByteArray;
			for(i=0; i<size_office_equip; i++) {
				var t2_office_equip:ByteArray = new ByteArray;
				var tVo_office_equip:p_office_equip = this.office_equip[i] as p_office_equip;
				tVo_office_equip.writeToDataOutput(t2_office_equip);
				var len_tVo_office_equip:int = t2_office_equip.length;
				temp_repeated_byte_office_equip.writeInt(len_tVo_office_equip);
				temp_repeated_byte_office_equip.writeBytes(t2_office_equip);
			}
			output.writeInt(temp_repeated_byte_office_equip.length);
			output.writeBytes(temp_repeated_byte_office_equip);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_office_equip:int = input.readShort();
			var length_office_equip:int = input.readInt();
			if (length_office_equip > 0) {
				var byte_office_equip:ByteArray = new ByteArray; 
				input.readBytes(byte_office_equip, 0, length_office_equip);
				for(i=0; i<size_office_equip; i++) {
					var tmp_office_equip:p_office_equip = new p_office_equip;
					var tmp_office_equip_length:int = byte_office_equip.readInt();
					var tmp_office_equip_byte:ByteArray = new ByteArray;
					byte_office_equip.readBytes(tmp_office_equip_byte, 0, tmp_office_equip_length);
					tmp_office_equip.readFromDataOutput(tmp_office_equip_byte);
					this.office_equip.push(tmp_office_equip);
				}
			}
		}
	}
}
