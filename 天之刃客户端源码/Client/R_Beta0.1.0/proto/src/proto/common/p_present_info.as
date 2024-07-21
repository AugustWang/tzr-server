package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_present_info extends Message
	{
		public var present_id:int = 0;
		public var title:String = "";
		public var is_direct_get:Boolean = true;
		public var item_list:Array = new Array;
		public var npc_id:int = 0;
		public function p_present_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_present_info", p_present_info);
		}
		public override function getMethodName():String {
			return 'present_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.present_id);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_direct_get);
			var size_item_list:int = this.item_list.length;
			output.writeShort(size_item_list);
			var temp_repeated_byte_item_list:ByteArray= new ByteArray;
			for(i=0; i<size_item_list; i++) {
				temp_repeated_byte_item_list.writeInt(this.item_list[i]);
			}
			output.writeInt(temp_repeated_byte_item_list.length);
			output.writeBytes(temp_repeated_byte_item_list);
			output.writeInt(this.npc_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.present_id = input.readInt();
			this.title = input.readUTF();
			this.is_direct_get = input.readBoolean();
			var size_item_list:int = input.readShort();
			var length_item_list:int = input.readInt();
			var byte_item_list:ByteArray = new ByteArray; 
			if (size_item_list > 0) {
				input.readBytes(byte_item_list, 0, size_item_list * 4);
				for(i=0; i<size_item_list; i++) {
					var tmp_item_list:int = byte_item_list.readInt();
					this.item_list.push(tmp_item_list);
				}
			}
			this.npc_id = input.readInt();
		}
	}
}
