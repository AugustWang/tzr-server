package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trap_quit_toc extends Message
	{
		public var trap_id:Array = new Array;
		public function m_trap_quit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trap_quit_toc", m_trap_quit_toc);
		}
		public override function getMethodName():String {
			return 'trap_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_trap_id:int = this.trap_id.length;
			output.writeShort(size_trap_id);
			var temp_repeated_byte_trap_id:ByteArray= new ByteArray;
			for(i=0; i<size_trap_id; i++) {
				temp_repeated_byte_trap_id.writeInt(this.trap_id[i]);
			}
			output.writeInt(temp_repeated_byte_trap_id.length);
			output.writeBytes(temp_repeated_byte_trap_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_trap_id:int = input.readShort();
			var length_trap_id:int = input.readInt();
			var byte_trap_id:ByteArray = new ByteArray; 
			if (size_trap_id > 0) {
				input.readBytes(byte_trap_id, 0, size_trap_id * 4);
				for(i=0; i<size_trap_id; i++) {
					var tmp_trap_id:int = byte_trap_id.readInt();
					this.trap_id.push(tmp_trap_id);
				}
			}
		}
	}
}
