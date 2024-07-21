package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_sale_toc extends Message
	{
		public var succ:Boolean = true;
		public var property:Array = new Array;
		public var ids:Array = new Array;
		public var reason:String = "";
		public function m_shop_sale_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_sale_toc", m_shop_sale_toc);
		}
		public override function getMethodName():String {
			return 'shop_sale';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_property:int = this.property.length;
			output.writeShort(size_property);
			var temp_repeated_byte_property:ByteArray= new ByteArray;
			for(i=0; i<size_property; i++) {
				temp_repeated_byte_property.writeInt(this.property[i]);
			}
			output.writeInt(temp_repeated_byte_property.length);
			output.writeBytes(temp_repeated_byte_property);
			var size_ids:int = this.ids.length;
			output.writeShort(size_ids);
			var temp_repeated_byte_ids:ByteArray= new ByteArray;
			for(i=0; i<size_ids; i++) {
				temp_repeated_byte_ids.writeInt(this.ids[i]);
			}
			output.writeInt(temp_repeated_byte_ids.length);
			output.writeBytes(temp_repeated_byte_ids);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_property:int = input.readShort();
			var length_property:int = input.readInt();
			var byte_property:ByteArray = new ByteArray; 
			if (size_property > 0) {
				input.readBytes(byte_property, 0, size_property * 4);
				for(i=0; i<size_property; i++) {
					var tmp_property:int = byte_property.readInt();
					this.property.push(tmp_property);
				}
			}
			var size_ids:int = input.readShort();
			var length_ids:int = input.readInt();
			var byte_ids:ByteArray = new ByteArray; 
			if (size_ids > 0) {
				input.readBytes(byte_ids, 0, size_ids * 4);
				for(i=0; i<size_ids; i++) {
					var tmp_ids:int = byte_ids.readInt();
					this.ids.push(tmp_ids);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
