package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_server_npc_quit_toc extends Message
	{
		public var npc_ids:Array = new Array;
		public function m_server_npc_quit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_server_npc_quit_toc", m_server_npc_quit_toc);
		}
		public override function getMethodName():String {
			return 'server_npc_quit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_npc_ids:int = this.npc_ids.length;
			output.writeShort(size_npc_ids);
			var temp_repeated_byte_npc_ids:ByteArray= new ByteArray;
			for(i=0; i<size_npc_ids; i++) {
				temp_repeated_byte_npc_ids.writeInt(this.npc_ids[i]);
			}
			output.writeInt(temp_repeated_byte_npc_ids.length);
			output.writeBytes(temp_repeated_byte_npc_ids);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_npc_ids:int = input.readShort();
			var length_npc_ids:int = input.readInt();
			var byte_npc_ids:ByteArray = new ByteArray; 
			if (size_npc_ids > 0) {
				input.readBytes(byte_npc_ids, 0, size_npc_ids * 4);
				for(i=0; i<size_npc_ids; i++) {
					var tmp_npc_ids:int = byte_npc_ids.readInt();
					this.npc_ids.push(tmp_npc_ids);
				}
			}
		}
	}
}
