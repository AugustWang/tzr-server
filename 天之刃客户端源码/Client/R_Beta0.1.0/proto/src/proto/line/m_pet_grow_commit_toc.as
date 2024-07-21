package proto.line {
	import proto.common.p_role_pet_grow;
	import proto.common.p_grow_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_grow_commit_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var use_gold:int = 0;
		public var grow_info:p_role_pet_grow = null;
		public var info_configs:Array = new Array;
		public function m_pet_grow_commit_toc() {
			super();
			this.grow_info = new p_role_pet_grow;

			flash.net.registerClassAlias("copy.proto.line.m_pet_grow_commit_toc", m_pet_grow_commit_toc);
		}
		public override function getMethodName():String {
			return 'pet_grow_commit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.use_gold);
			var tmp_grow_info:ByteArray = new ByteArray;
			this.grow_info.writeToDataOutput(tmp_grow_info);
			var size_tmp_grow_info:int = tmp_grow_info.length;
			output.writeInt(size_tmp_grow_info);
			output.writeBytes(tmp_grow_info);
			var size_info_configs:int = this.info_configs.length;
			output.writeShort(size_info_configs);
			var temp_repeated_byte_info_configs:ByteArray= new ByteArray;
			for(i=0; i<size_info_configs; i++) {
				var t2_info_configs:ByteArray = new ByteArray;
				var tVo_info_configs:p_grow_info = this.info_configs[i] as p_grow_info;
				tVo_info_configs.writeToDataOutput(t2_info_configs);
				var len_tVo_info_configs:int = t2_info_configs.length;
				temp_repeated_byte_info_configs.writeInt(len_tVo_info_configs);
				temp_repeated_byte_info_configs.writeBytes(t2_info_configs);
			}
			output.writeInt(temp_repeated_byte_info_configs.length);
			output.writeBytes(temp_repeated_byte_info_configs);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.use_gold = input.readInt();
			var byte_grow_info_size:int = input.readInt();
			if (byte_grow_info_size > 0) {				this.grow_info = new p_role_pet_grow;
				var byte_grow_info:ByteArray = new ByteArray;
				input.readBytes(byte_grow_info, 0, byte_grow_info_size);
				this.grow_info.readFromDataOutput(byte_grow_info);
			}
			var size_info_configs:int = input.readShort();
			var length_info_configs:int = input.readInt();
			if (length_info_configs > 0) {
				var byte_info_configs:ByteArray = new ByteArray; 
				input.readBytes(byte_info_configs, 0, length_info_configs);
				for(i=0; i<size_info_configs; i++) {
					var tmp_info_configs:p_grow_info = new p_grow_info;
					var tmp_info_configs_length:int = byte_info_configs.readInt();
					var tmp_info_configs_byte:ByteArray = new ByteArray;
					byte_info_configs.readBytes(tmp_info_configs_byte, 0, tmp_info_configs_length);
					tmp_info_configs.readFromDataOutput(tmp_info_configs_byte);
					this.info_configs.push(tmp_info_configs);
				}
			}
		}
	}
}
