package proto.line {
	import proto.line.p_personybc_award_attr;
	import proto.line.p_personybc_award_prop;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_commit_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var status:int = 0;
		public var attr_award_list:Array = new Array;
		public var prop_award_list:Array = new Array;
		public function m_personybc_commit_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_commit_toc", m_personybc_commit_toc);
		}
		public override function getMethodName():String {
			return 'personybc_commit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.status);
			var size_attr_award_list:int = this.attr_award_list.length;
			output.writeShort(size_attr_award_list);
			var temp_repeated_byte_attr_award_list:ByteArray= new ByteArray;
			for(i=0; i<size_attr_award_list; i++) {
				var t2_attr_award_list:ByteArray = new ByteArray;
				var tVo_attr_award_list:p_personybc_award_attr = this.attr_award_list[i] as p_personybc_award_attr;
				tVo_attr_award_list.writeToDataOutput(t2_attr_award_list);
				var len_tVo_attr_award_list:int = t2_attr_award_list.length;
				temp_repeated_byte_attr_award_list.writeInt(len_tVo_attr_award_list);
				temp_repeated_byte_attr_award_list.writeBytes(t2_attr_award_list);
			}
			output.writeInt(temp_repeated_byte_attr_award_list.length);
			output.writeBytes(temp_repeated_byte_attr_award_list);
			var size_prop_award_list:int = this.prop_award_list.length;
			output.writeShort(size_prop_award_list);
			var temp_repeated_byte_prop_award_list:ByteArray= new ByteArray;
			for(i=0; i<size_prop_award_list; i++) {
				var t2_prop_award_list:ByteArray = new ByteArray;
				var tVo_prop_award_list:p_personybc_award_prop = this.prop_award_list[i] as p_personybc_award_prop;
				tVo_prop_award_list.writeToDataOutput(t2_prop_award_list);
				var len_tVo_prop_award_list:int = t2_prop_award_list.length;
				temp_repeated_byte_prop_award_list.writeInt(len_tVo_prop_award_list);
				temp_repeated_byte_prop_award_list.writeBytes(t2_prop_award_list);
			}
			output.writeInt(temp_repeated_byte_prop_award_list.length);
			output.writeBytes(temp_repeated_byte_prop_award_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.status = input.readInt();
			var size_attr_award_list:int = input.readShort();
			var length_attr_award_list:int = input.readInt();
			if (length_attr_award_list > 0) {
				var byte_attr_award_list:ByteArray = new ByteArray; 
				input.readBytes(byte_attr_award_list, 0, length_attr_award_list);
				for(i=0; i<size_attr_award_list; i++) {
					var tmp_attr_award_list:p_personybc_award_attr = new p_personybc_award_attr;
					var tmp_attr_award_list_length:int = byte_attr_award_list.readInt();
					var tmp_attr_award_list_byte:ByteArray = new ByteArray;
					byte_attr_award_list.readBytes(tmp_attr_award_list_byte, 0, tmp_attr_award_list_length);
					tmp_attr_award_list.readFromDataOutput(tmp_attr_award_list_byte);
					this.attr_award_list.push(tmp_attr_award_list);
				}
			}
			var size_prop_award_list:int = input.readShort();
			var length_prop_award_list:int = input.readInt();
			if (length_prop_award_list > 0) {
				var byte_prop_award_list:ByteArray = new ByteArray; 
				input.readBytes(byte_prop_award_list, 0, length_prop_award_list);
				for(i=0; i<size_prop_award_list; i++) {
					var tmp_prop_award_list:p_personybc_award_prop = new p_personybc_award_prop;
					var tmp_prop_award_list_length:int = byte_prop_award_list.readInt();
					var tmp_prop_award_list_byte:ByteArray = new ByteArray;
					byte_prop_award_list.readBytes(tmp_prop_award_list_byte, 0, tmp_prop_award_list_length);
					tmp_prop_award_list.readFromDataOutput(tmp_prop_award_list_byte);
					this.prop_award_list.push(tmp_prop_award_list);
				}
			}
		}
	}
}
