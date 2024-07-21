package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vie_world_fb_enter_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var monster_type_ids:Array = new Array;
		public function m_vie_world_fb_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vie_world_fb_enter_toc", m_vie_world_fb_enter_toc);
		}
		public override function getMethodName():String {
			return 'vie_world_fb_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_monster_type_ids:int = this.monster_type_ids.length;
			output.writeShort(size_monster_type_ids);
			var temp_repeated_byte_monster_type_ids:ByteArray= new ByteArray;
			for(i=0; i<size_monster_type_ids; i++) {
				temp_repeated_byte_monster_type_ids.writeInt(this.monster_type_ids[i]);
			}
			output.writeInt(temp_repeated_byte_monster_type_ids.length);
			output.writeBytes(temp_repeated_byte_monster_type_ids);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_monster_type_ids:int = input.readShort();
			var length_monster_type_ids:int = input.readInt();
			var byte_monster_type_ids:ByteArray = new ByteArray; 
			if (size_monster_type_ids > 0) {
				input.readBytes(byte_monster_type_ids, 0, size_monster_type_ids * 4);
				for(i=0; i<size_monster_type_ids; i++) {
					var tmp_monster_type_ids:int = byte_monster_type_ids.readInt();
					this.monster_type_ids.push(tmp_monster_type_ids);
				}
			}
		}
	}
}
