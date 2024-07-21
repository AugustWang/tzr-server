package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personal_fb_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var fb_info:Array = new Array;
		public var today_count:int = 0;
		public var max_times:int = 0;
		public var last_fb_passed:int = 0;
		public var today_lost:int = 0;
		public var max_lost:int = 0;
		public var exp_get:int = 0;
		public function m_personal_fb_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personal_fb_list_toc", m_personal_fb_list_toc);
		}
		public override function getMethodName():String {
			return 'personal_fb_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_fb_info:int = this.fb_info.length;
			output.writeShort(size_fb_info);
			var temp_repeated_byte_fb_info:ByteArray= new ByteArray;
			for(i=0; i<size_fb_info; i++) {
				var t2_fb_info:ByteArray = new ByteArray;
				var tVo_fb_info:p_personal_fb_info = this.fb_info[i] as p_personal_fb_info;
				tVo_fb_info.writeToDataOutput(t2_fb_info);
				var len_tVo_fb_info:int = t2_fb_info.length;
				temp_repeated_byte_fb_info.writeInt(len_tVo_fb_info);
				temp_repeated_byte_fb_info.writeBytes(t2_fb_info);
			}
			output.writeInt(temp_repeated_byte_fb_info.length);
			output.writeBytes(temp_repeated_byte_fb_info);
			output.writeInt(this.today_count);
			output.writeInt(this.max_times);
			output.writeInt(this.last_fb_passed);
			output.writeInt(this.today_lost);
			output.writeInt(this.max_lost);
			output.writeInt(this.exp_get);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_fb_info:int = input.readShort();
			var length_fb_info:int = input.readInt();
			if (length_fb_info > 0) {
				var byte_fb_info:ByteArray = new ByteArray; 
				input.readBytes(byte_fb_info, 0, length_fb_info);
				for(i=0; i<size_fb_info; i++) {
					var tmp_fb_info:p_personal_fb_info = new p_personal_fb_info;
					var tmp_fb_info_length:int = byte_fb_info.readInt();
					var tmp_fb_info_byte:ByteArray = new ByteArray;
					byte_fb_info.readBytes(tmp_fb_info_byte, 0, tmp_fb_info_length);
					tmp_fb_info.readFromDataOutput(tmp_fb_info_byte);
					this.fb_info.push(tmp_fb_info);
				}
			}
			this.today_count = input.readInt();
			this.max_times = input.readInt();
			this.last_fb_passed = input.readInt();
			this.today_lost = input.readInt();
			this.max_lost = input.readInt();
			this.exp_get = input.readInt();
		}
	}
}
