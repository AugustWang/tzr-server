package proto.line {
	import proto.common.p_scene_war_fb_link;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_scene_war_fb_query_toc extends Message
	{
		public var succ:Boolean = true;
		public var op_type:int = 0;
		public var npc_id:int = 0;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var fb_links:Array = new Array;
		public function m_scene_war_fb_query_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_scene_war_fb_query_toc", m_scene_war_fb_query_toc);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_query';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.op_type);
			output.writeInt(this.npc_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			var size_fb_links:int = this.fb_links.length;
			output.writeShort(size_fb_links);
			var temp_repeated_byte_fb_links:ByteArray= new ByteArray;
			for(i=0; i<size_fb_links; i++) {
				var t2_fb_links:ByteArray = new ByteArray;
				var tVo_fb_links:p_scene_war_fb_link = this.fb_links[i] as p_scene_war_fb_link;
				tVo_fb_links.writeToDataOutput(t2_fb_links);
				var len_tVo_fb_links:int = t2_fb_links.length;
				temp_repeated_byte_fb_links.writeInt(len_tVo_fb_links);
				temp_repeated_byte_fb_links.writeBytes(t2_fb_links);
			}
			output.writeInt(temp_repeated_byte_fb_links.length);
			output.writeBytes(temp_repeated_byte_fb_links);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.op_type = input.readInt();
			this.npc_id = input.readInt();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			var size_fb_links:int = input.readShort();
			var length_fb_links:int = input.readInt();
			if (length_fb_links > 0) {
				var byte_fb_links:ByteArray = new ByteArray; 
				input.readBytes(byte_fb_links, 0, length_fb_links);
				for(i=0; i<size_fb_links; i++) {
					var tmp_fb_links:p_scene_war_fb_link = new p_scene_war_fb_link;
					var tmp_fb_links_length:int = byte_fb_links.readInt();
					var tmp_fb_links_byte:ByteArray = new ByteArray;
					byte_fb_links.readBytes(tmp_fb_links_byte, 0, tmp_fb_links_length);
					tmp_fb_links.readFromDataOutput(tmp_fb_links_byte);
					this.fb_links.push(tmp_fb_links);
				}
			}
		}
	}
}
