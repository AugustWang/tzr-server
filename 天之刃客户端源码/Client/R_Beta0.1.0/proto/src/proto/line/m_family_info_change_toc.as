package proto.line {
	import proto.common.p_family_info_change;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_info_change_toc extends Message
	{
		public var changes:Array = new Array;
		public function m_family_info_change_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_info_change_toc", m_family_info_change_toc);
		}
		public override function getMethodName():String {
			return 'family_info_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_changes:int = this.changes.length;
			output.writeShort(size_changes);
			var temp_repeated_byte_changes:ByteArray= new ByteArray;
			for(i=0; i<size_changes; i++) {
				var t2_changes:ByteArray = new ByteArray;
				var tVo_changes:p_family_info_change = this.changes[i] as p_family_info_change;
				tVo_changes.writeToDataOutput(t2_changes);
				var len_tVo_changes:int = t2_changes.length;
				temp_repeated_byte_changes.writeInt(len_tVo_changes);
				temp_repeated_byte_changes.writeBytes(t2_changes);
			}
			output.writeInt(temp_repeated_byte_changes.length);
			output.writeBytes(temp_repeated_byte_changes);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_changes:int = input.readShort();
			var length_changes:int = input.readInt();
			if (length_changes > 0) {
				var byte_changes:ByteArray = new ByteArray; 
				input.readBytes(byte_changes, 0, length_changes);
				for(i=0; i<size_changes; i++) {
					var tmp_changes:p_family_info_change = new p_family_info_change;
					var tmp_changes_length:int = byte_changes.readInt();
					var tmp_changes_byte:ByteArray = new ByteArray;
					byte_changes.readBytes(tmp_changes_byte, 0, tmp_changes_length);
					tmp_changes.readFromDataOutput(tmp_changes_byte);
					this.changes.push(tmp_changes);
				}
			}
		}
	}
}
