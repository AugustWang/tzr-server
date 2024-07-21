package proto.line {
	import proto.common.p_hero_fb_record;
	import proto.common.p_hero_fb_record;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_hero_fb_report_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var barrier_id:int = 0;
		public var fb_record:p_hero_fb_record = null;
		public var state:int = 0;
		public var first_record:p_hero_fb_record = null;
		public function m_hero_fb_report_toc() {
			super();
			this.fb_record = new p_hero_fb_record;
			this.first_record = new p_hero_fb_record;

			flash.net.registerClassAlias("copy.proto.line.m_hero_fb_report_toc", m_hero_fb_report_toc);
		}
		public override function getMethodName():String {
			return 'hero_fb_report';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.barrier_id);
			var tmp_fb_record:ByteArray = new ByteArray;
			this.fb_record.writeToDataOutput(tmp_fb_record);
			var size_tmp_fb_record:int = tmp_fb_record.length;
			output.writeInt(size_tmp_fb_record);
			output.writeBytes(tmp_fb_record);
			output.writeInt(this.state);
			var tmp_first_record:ByteArray = new ByteArray;
			this.first_record.writeToDataOutput(tmp_first_record);
			var size_tmp_first_record:int = tmp_first_record.length;
			output.writeInt(size_tmp_first_record);
			output.writeBytes(tmp_first_record);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.barrier_id = input.readInt();
			var byte_fb_record_size:int = input.readInt();
			if (byte_fb_record_size > 0) {				this.fb_record = new p_hero_fb_record;
				var byte_fb_record:ByteArray = new ByteArray;
				input.readBytes(byte_fb_record, 0, byte_fb_record_size);
				this.fb_record.readFromDataOutput(byte_fb_record);
			}
			this.state = input.readInt();
			var byte_first_record_size:int = input.readInt();
			if (byte_first_record_size > 0) {				this.first_record = new p_hero_fb_record;
				var byte_first_record:ByteArray = new ByteArray;
				input.readBytes(byte_first_record, 0, byte_first_record_size);
				this.first_record.readFromDataOutput(byte_first_record);
			}
		}
	}
}
