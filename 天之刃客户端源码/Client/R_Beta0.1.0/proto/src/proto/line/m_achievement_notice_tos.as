package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_achievement_notice_tos extends Message
	{
		public var event_ids:Array = new Array;
		public var add_progress:int = 1;
		public function m_achievement_notice_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_achievement_notice_tos", m_achievement_notice_tos);
		}
		public override function getMethodName():String {
			return 'achievement_notice';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_event_ids:int = this.event_ids.length;
			output.writeShort(size_event_ids);
			var temp_repeated_byte_event_ids:ByteArray= new ByteArray;
			for(i=0; i<size_event_ids; i++) {
				temp_repeated_byte_event_ids.writeInt(this.event_ids[i]);
			}
			output.writeInt(temp_repeated_byte_event_ids.length);
			output.writeBytes(temp_repeated_byte_event_ids);
			output.writeInt(this.add_progress);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_event_ids:int = input.readShort();
			var length_event_ids:int = input.readInt();
			var byte_event_ids:ByteArray = new ByteArray; 
			if (size_event_ids > 0) {
				input.readBytes(byte_event_ids, 0, size_event_ids * 4);
				for(i=0; i<size_event_ids; i++) {
					var tmp_event_ids:int = byte_event_ids.readInt();
					this.event_ids.push(tmp_event_ids);
				}
			}
			this.add_progress = input.readInt();
		}
	}
}
