package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_list_tos extends Message
	{
		public var type:int = 0;
		public var page:int = 0;
		public var typeid:Array = new Array;
		public var sort_type:int = 0;
		public var is_reverse:Boolean = true;
		public var is_gold_first:Boolean = true;
		public var min_level:int = 0;
		public var max_level:int = 0;
		public var color:int = 0;
		public var pro:int = 0;
		public function m_stall_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_list_tos", m_stall_list_tos);
		}
		public override function getMethodName():String {
			return 'stall_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.page);
			var size_typeid:int = this.typeid.length;
			output.writeShort(size_typeid);
			var temp_repeated_byte_typeid:ByteArray= new ByteArray;
			for(i=0; i<size_typeid; i++) {
				temp_repeated_byte_typeid.writeInt(this.typeid[i]);
			}
			output.writeInt(temp_repeated_byte_typeid.length);
			output.writeBytes(temp_repeated_byte_typeid);
			output.writeInt(this.sort_type);
			output.writeBoolean(this.is_reverse);
			output.writeBoolean(this.is_gold_first);
			output.writeInt(this.min_level);
			output.writeInt(this.max_level);
			output.writeInt(this.color);
			output.writeInt(this.pro);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.page = input.readInt();
			var size_typeid:int = input.readShort();
			var length_typeid:int = input.readInt();
			var byte_typeid:ByteArray = new ByteArray; 
			if (size_typeid > 0) {
				input.readBytes(byte_typeid, 0, size_typeid * 4);
				for(i=0; i<size_typeid; i++) {
					var tmp_typeid:int = byte_typeid.readInt();
					this.typeid.push(tmp_typeid);
				}
			}
			this.sort_type = input.readInt();
			this.is_reverse = input.readBoolean();
			this.is_gold_first = input.readBoolean();
			this.min_level = input.readInt();
			this.max_level = input.readInt();
			this.color = input.readInt();
			this.pro = input.readInt();
		}
	}
}
