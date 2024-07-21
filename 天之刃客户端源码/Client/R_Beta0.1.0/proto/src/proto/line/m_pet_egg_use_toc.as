package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_egg_use_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var refresh_tick:int = 0;
		public var type_id_list:Array = new Array;
		public var egg_left_tick:int = 0;
		public var goods_id:int = 0;
		public function m_pet_egg_use_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_egg_use_toc", m_pet_egg_use_toc);
		}
		public override function getMethodName():String {
			return 'pet_egg_use';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.refresh_tick);
			var size_type_id_list:int = this.type_id_list.length;
			output.writeShort(size_type_id_list);
			var temp_repeated_byte_type_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_type_id_list; i++) {
				temp_repeated_byte_type_id_list.writeInt(this.type_id_list[i]);
			}
			output.writeInt(temp_repeated_byte_type_id_list.length);
			output.writeBytes(temp_repeated_byte_type_id_list);
			output.writeInt(this.egg_left_tick);
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.refresh_tick = input.readInt();
			var size_type_id_list:int = input.readShort();
			var length_type_id_list:int = input.readInt();
			var byte_type_id_list:ByteArray = new ByteArray; 
			if (size_type_id_list > 0) {
				input.readBytes(byte_type_id_list, 0, size_type_id_list * 4);
				for(i=0; i<size_type_id_list; i++) {
					var tmp_type_id_list:int = byte_type_id_list.readInt();
					this.type_id_list.push(tmp_type_id_list);
				}
			}
			this.egg_left_tick = input.readInt();
			this.goods_id = input.readInt();
		}
	}
}
