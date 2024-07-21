package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_achievement_query_tos extends Message
	{
		public var op_type:int = 0;
		public var group_id:int = 0;
		public var achieve_ids:Array = new Array;
		public function m_achievement_query_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_achievement_query_tos", m_achievement_query_tos);
		}
		public override function getMethodName():String {
			return 'achievement_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.group_id);
			var size_achieve_ids:int = this.achieve_ids.length;
			output.writeShort(size_achieve_ids);
			var temp_repeated_byte_achieve_ids:ByteArray= new ByteArray;
			for(i=0; i<size_achieve_ids; i++) {
				temp_repeated_byte_achieve_ids.writeInt(this.achieve_ids[i]);
			}
			output.writeInt(temp_repeated_byte_achieve_ids.length);
			output.writeBytes(temp_repeated_byte_achieve_ids);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.group_id = input.readInt();
			var size_achieve_ids:int = input.readShort();
			var length_achieve_ids:int = input.readInt();
			var byte_achieve_ids:ByteArray = new ByteArray; 
			if (size_achieve_ids > 0) {
				input.readBytes(byte_achieve_ids, 0, size_achieve_ids * 4);
				for(i=0; i<size_achieve_ids; i++) {
					var tmp_achieve_ids:int = byte_achieve_ids.readInt();
					this.achieve_ids.push(tmp_achieve_ids);
				}
			}
		}
	}
}
