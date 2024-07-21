package proto.line {
	import proto.common.p_family_task;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_activestate_toc extends Message
	{
		public var succ:Boolean = true;
		public var familytasklist:Array = new Array;
		public function m_family_activestate_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_activestate_toc", m_family_activestate_toc);
		}
		public override function getMethodName():String {
			return 'family_activestate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_familytasklist:int = this.familytasklist.length;
			output.writeShort(size_familytasklist);
			var temp_repeated_byte_familytasklist:ByteArray= new ByteArray;
			for(i=0; i<size_familytasklist; i++) {
				var t2_familytasklist:ByteArray = new ByteArray;
				var tVo_familytasklist:p_family_task = this.familytasklist[i] as p_family_task;
				tVo_familytasklist.writeToDataOutput(t2_familytasklist);
				var len_tVo_familytasklist:int = t2_familytasklist.length;
				temp_repeated_byte_familytasklist.writeInt(len_tVo_familytasklist);
				temp_repeated_byte_familytasklist.writeBytes(t2_familytasklist);
			}
			output.writeInt(temp_repeated_byte_familytasklist.length);
			output.writeBytes(temp_repeated_byte_familytasklist);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_familytasklist:int = input.readShort();
			var length_familytasklist:int = input.readInt();
			if (length_familytasklist > 0) {
				var byte_familytasklist:ByteArray = new ByteArray; 
				input.readBytes(byte_familytasklist, 0, length_familytasklist);
				for(i=0; i<size_familytasklist; i++) {
					var tmp_familytasklist:p_family_task = new p_family_task;
					var tmp_familytasklist_length:int = byte_familytasklist.readInt();
					var tmp_familytasklist_byte:ByteArray = new ByteArray;
					byte_familytasklist.readBytes(tmp_familytasklist_byte, 0, tmp_familytasklist_length);
					tmp_familytasklist.readFromDataOutput(tmp_familytasklist_byte);
					this.familytasklist.push(tmp_familytasklist);
				}
			}
		}
	}
}
