package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_dead_toc extends Message
	{
		public var killer:String = "";
		public var relive_type:Array = new Array;
		public var relive_silver:int = 0;
		public var dead_type:int = 0;
		public function m_role2_dead_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_dead_toc", m_role2_dead_toc);
		}
		public override function getMethodName():String {
			return 'role2_dead';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.killer != null) {				output.writeUTF(this.killer.toString());
			} else {
				output.writeUTF("");
			}
			var size_relive_type:int = this.relive_type.length;
			output.writeShort(size_relive_type);
			var temp_repeated_byte_relive_type:ByteArray= new ByteArray;
			for(i=0; i<size_relive_type; i++) {
				temp_repeated_byte_relive_type.writeInt(this.relive_type[i]);
			}
			output.writeInt(temp_repeated_byte_relive_type.length);
			output.writeBytes(temp_repeated_byte_relive_type);
			output.writeInt(this.relive_silver);
			output.writeInt(this.dead_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.killer = input.readUTF();
			var size_relive_type:int = input.readShort();
			var length_relive_type:int = input.readInt();
			var byte_relive_type:ByteArray = new ByteArray; 
			if (size_relive_type > 0) {
				input.readBytes(byte_relive_type, 0, size_relive_type * 4);
				for(i=0; i<size_relive_type; i++) {
					var tmp_relive_type:int = byte_relive_type.readInt();
					this.relive_type.push(tmp_relive_type);
				}
			}
			this.relive_silver = input.readInt();
			this.dead_type = input.readInt();
		}
	}
}
