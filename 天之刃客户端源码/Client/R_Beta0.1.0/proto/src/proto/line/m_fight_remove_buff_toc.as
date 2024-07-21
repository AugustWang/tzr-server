package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fight_remove_buff_toc extends Message
	{
		public var roleid:int = 0;
		public var buffid:Array = new Array;
		public function m_fight_remove_buff_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fight_remove_buff_toc", m_fight_remove_buff_toc);
		}
		public override function getMethodName():String {
			return 'fight_remove_buff';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			var size_buffid:int = this.buffid.length;
			output.writeShort(size_buffid);
			var temp_repeated_byte_buffid:ByteArray= new ByteArray;
			for(i=0; i<size_buffid; i++) {
				temp_repeated_byte_buffid.writeInt(this.buffid[i]);
			}
			output.writeInt(temp_repeated_byte_buffid.length);
			output.writeBytes(temp_repeated_byte_buffid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			var size_buffid:int = input.readShort();
			var length_buffid:int = input.readInt();
			var byte_buffid:ByteArray = new ByteArray; 
			if (size_buffid > 0) {
				input.readBytes(byte_buffid, 0, size_buffid * 4);
				for(i=0; i<size_buffid; i++) {
					var tmp_buffid:int = byte_buffid.readInt();
					this.buffid.push(tmp_buffid);
				}
			}
		}
	}
}
