package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_panel_toc extends Message
	{
		public var invites:Array = new Array;
		public var family_list:Array = new Array;
		public var requests:Array = new Array;
		public var total_page:int = 0;
		public function m_family_panel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_panel_toc", m_family_panel_toc);
		}
		public override function getMethodName():String {
			return 'family_panel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_invites:int = this.invites.length;
			output.writeShort(size_invites);
			var temp_repeated_byte_invites:ByteArray= new ByteArray;
			for(i=0; i<size_invites; i++) {
				var t2_invites:ByteArray = new ByteArray;
				var tVo_invites:p_family_invite_info = this.invites[i] as p_family_invite_info;
				tVo_invites.writeToDataOutput(t2_invites);
				var len_tVo_invites:int = t2_invites.length;
				temp_repeated_byte_invites.writeInt(len_tVo_invites);
				temp_repeated_byte_invites.writeBytes(t2_invites);
			}
			output.writeInt(temp_repeated_byte_invites.length);
			output.writeBytes(temp_repeated_byte_invites);
			var size_family_list:int = this.family_list.length;
			output.writeShort(size_family_list);
			var temp_repeated_byte_family_list:ByteArray= new ByteArray;
			for(i=0; i<size_family_list; i++) {
				var t2_family_list:ByteArray = new ByteArray;
				var tVo_family_list:p_family_summary = this.family_list[i] as p_family_summary;
				tVo_family_list.writeToDataOutput(t2_family_list);
				var len_tVo_family_list:int = t2_family_list.length;
				temp_repeated_byte_family_list.writeInt(len_tVo_family_list);
				temp_repeated_byte_family_list.writeBytes(t2_family_list);
			}
			output.writeInt(temp_repeated_byte_family_list.length);
			output.writeBytes(temp_repeated_byte_family_list);
			var size_requests:int = this.requests.length;
			output.writeShort(size_requests);
			var temp_repeated_byte_requests:ByteArray= new ByteArray;
			for(i=0; i<size_requests; i++) {
				var t2_requests:ByteArray = new ByteArray;
				var tVo_requests:p_family_request_info = this.requests[i] as p_family_request_info;
				tVo_requests.writeToDataOutput(t2_requests);
				var len_tVo_requests:int = t2_requests.length;
				temp_repeated_byte_requests.writeInt(len_tVo_requests);
				temp_repeated_byte_requests.writeBytes(t2_requests);
			}
			output.writeInt(temp_repeated_byte_requests.length);
			output.writeBytes(temp_repeated_byte_requests);
			output.writeInt(this.total_page);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_invites:int = input.readShort();
			var length_invites:int = input.readInt();
			if (length_invites > 0) {
				var byte_invites:ByteArray = new ByteArray; 
				input.readBytes(byte_invites, 0, length_invites);
				for(i=0; i<size_invites; i++) {
					var tmp_invites:p_family_invite_info = new p_family_invite_info;
					var tmp_invites_length:int = byte_invites.readInt();
					var tmp_invites_byte:ByteArray = new ByteArray;
					byte_invites.readBytes(tmp_invites_byte, 0, tmp_invites_length);
					tmp_invites.readFromDataOutput(tmp_invites_byte);
					this.invites.push(tmp_invites);
				}
			}
			var size_family_list:int = input.readShort();
			var length_family_list:int = input.readInt();
			if (length_family_list > 0) {
				var byte_family_list:ByteArray = new ByteArray; 
				input.readBytes(byte_family_list, 0, length_family_list);
				for(i=0; i<size_family_list; i++) {
					var tmp_family_list:p_family_summary = new p_family_summary;
					var tmp_family_list_length:int = byte_family_list.readInt();
					var tmp_family_list_byte:ByteArray = new ByteArray;
					byte_family_list.readBytes(tmp_family_list_byte, 0, tmp_family_list_length);
					tmp_family_list.readFromDataOutput(tmp_family_list_byte);
					this.family_list.push(tmp_family_list);
				}
			}
			var size_requests:int = input.readShort();
			var length_requests:int = input.readInt();
			if (length_requests > 0) {
				var byte_requests:ByteArray = new ByteArray; 
				input.readBytes(byte_requests, 0, length_requests);
				for(i=0; i<size_requests; i++) {
					var tmp_requests:p_family_request_info = new p_family_request_info;
					var tmp_requests_length:int = byte_requests.readInt();
					var tmp_requests_byte:ByteArray = new ByteArray;
					byte_requests.readBytes(tmp_requests_byte, 0, tmp_requests_length);
					tmp_requests.readFromDataOutput(tmp_requests_byte);
					this.requests.push(tmp_requests);
				}
			}
			this.total_page = input.readInt();
		}
	}
}
