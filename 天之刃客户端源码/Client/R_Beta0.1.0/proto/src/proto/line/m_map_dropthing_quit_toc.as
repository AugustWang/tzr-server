package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_dropthing_quit_toc extends Message
	{
		public var dropthingid:Array = new Array;
		public function m_map_dropthing_quit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_dropthing_quit_toc", m_map_dropthing_quit_toc);
		}
		public override function getMethodName():String {
			return 'map_dropthing_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_dropthingid:int = this.dropthingid.length;
			output.writeShort(size_dropthingid);
			var temp_repeated_byte_dropthingid:ByteArray= new ByteArray;
			for(i=0; i<size_dropthingid; i++) {
				temp_repeated_byte_dropthingid.writeInt(this.dropthingid[i]);
			}
			output.writeInt(temp_repeated_byte_dropthingid.length);
			output.writeBytes(temp_repeated_byte_dropthingid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_dropthingid:int = input.readShort();
			var length_dropthingid:int = input.readInt();
			var byte_dropthingid:ByteArray = new ByteArray; 
			if (size_dropthingid > 0) {
				input.readBytes(byte_dropthingid, 0, size_dropthingid * 4);
				for(i=0; i<size_dropthingid; i++) {
					var tmp_dropthingid:int = byte_dropthingid.readInt();
					this.dropthingid.push(tmp_dropthingid);
				}
			}
		}
	}
}
