package proto.line {
	import proto.common.p_waroffaction_record;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_record_toc extends Message
	{
		public var records:Array = new Array;
		public function m_waroffaction_record_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_record_toc", m_waroffaction_record_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_record';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_records:int = this.records.length;
			output.writeShort(size_records);
			var temp_repeated_byte_records:ByteArray= new ByteArray;
			for(i=0; i<size_records; i++) {
				var t2_records:ByteArray = new ByteArray;
				var tVo_records:p_waroffaction_record = this.records[i] as p_waroffaction_record;
				tVo_records.writeToDataOutput(t2_records);
				var len_tVo_records:int = t2_records.length;
				temp_repeated_byte_records.writeInt(len_tVo_records);
				temp_repeated_byte_records.writeBytes(t2_records);
			}
			output.writeInt(temp_repeated_byte_records.length);
			output.writeBytes(temp_repeated_byte_records);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_records:int = input.readShort();
			var length_records:int = input.readInt();
			if (length_records > 0) {
				var byte_records:ByteArray = new ByteArray; 
				input.readBytes(byte_records, 0, length_records);
				for(i=0; i<size_records; i++) {
					var tmp_records:p_waroffaction_record = new p_waroffaction_record;
					var tmp_records_length:int = byte_records.readInt();
					var tmp_records_byte:ByteArray = new ByteArray;
					byte_records.readBytes(tmp_records_byte, 0, tmp_records_length);
					tmp_records.readFromDataOutput(tmp_records_byte);
					this.records.push(tmp_records);
				}
			}
		}
	}
}
