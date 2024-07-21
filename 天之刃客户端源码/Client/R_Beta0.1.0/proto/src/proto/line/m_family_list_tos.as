package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_list_tos extends Message
	{
		public var page_id:int = 1;
		public var num_per_page:int = 5;
		public var search_content:String = "";
		public var search_type:int = 1;
		public var request_from:int = 1;
		public function m_family_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_list_tos", m_family_list_tos);
		}
		public override function getMethodName():String {
			return 'family_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.page_id);
			output.writeInt(this.num_per_page);
			if (this.search_content != null) {				output.writeUTF(this.search_content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.search_type);
			output.writeInt(this.request_from);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.page_id = input.readInt();
			this.num_per_page = input.readInt();
			this.search_content = input.readUTF();
			this.search_type = input.readInt();
			this.request_from = input.readInt();
		}
	}
}
