package proto.line {
	import proto.line.p_faction;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_panel_toc extends Message
	{
		public var faction_info:p_faction = null;
		public function m_office_panel_toc() {
			super();
			this.faction_info = new p_faction;

			flash.net.registerClassAlias("copy.proto.line.m_office_panel_toc", m_office_panel_toc);
		}
		public override function getMethodName():String {
			return 'office_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_faction_info:ByteArray = new ByteArray;
			this.faction_info.writeToDataOutput(tmp_faction_info);
			var size_tmp_faction_info:int = tmp_faction_info.length;
			output.writeInt(size_tmp_faction_info);
			output.writeBytes(tmp_faction_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_faction_info_size:int = input.readInt();
			if (byte_faction_info_size > 0) {				this.faction_info = new p_faction;
				var byte_faction_info:ByteArray = new ByteArray;
				input.readBytes(byte_faction_info, 0, byte_faction_info_size);
				this.faction_info.readFromDataOutput(byte_faction_info);
			}
		}
	}
}
