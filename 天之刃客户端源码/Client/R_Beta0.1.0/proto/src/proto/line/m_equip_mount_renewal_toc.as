package proto.line {
	import proto.common.p_goods;
	import proto.common.p_equip_mount_renewal;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_mount_renewal_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var op_type:int = 0;
		public var mount_id:int = 0;
		public var mount_type_id:int = 0;
		public var mount_pos:int = 0;
		public var renewal_type:int = 0;
		public var end_time:int = 0;
		public var op_fee:int = 0;
		public var mount:p_goods = null;
		public var renewal_confs:Array = new Array;
		public var all_gold:int = 0;
		public function m_equip_mount_renewal_toc() {
			super();
			this.mount = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_mount_renewal_toc", m_equip_mount_renewal_toc);
		}
		public override function getMethodName():String {
			return 'equip_mount_renewal';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.op_type);
			output.writeInt(this.mount_id);
			output.writeInt(this.mount_type_id);
			output.writeInt(this.mount_pos);
			output.writeInt(this.renewal_type);
			output.writeInt(this.end_time);
			output.writeInt(this.op_fee);
			var tmp_mount:ByteArray = new ByteArray;
			this.mount.writeToDataOutput(tmp_mount);
			var size_tmp_mount:int = tmp_mount.length;
			output.writeInt(size_tmp_mount);
			output.writeBytes(tmp_mount);
			var size_renewal_confs:int = this.renewal_confs.length;
			output.writeShort(size_renewal_confs);
			var temp_repeated_byte_renewal_confs:ByteArray= new ByteArray;
			for(i=0; i<size_renewal_confs; i++) {
				var t2_renewal_confs:ByteArray = new ByteArray;
				var tVo_renewal_confs:p_equip_mount_renewal = this.renewal_confs[i] as p_equip_mount_renewal;
				tVo_renewal_confs.writeToDataOutput(t2_renewal_confs);
				var len_tVo_renewal_confs:int = t2_renewal_confs.length;
				temp_repeated_byte_renewal_confs.writeInt(len_tVo_renewal_confs);
				temp_repeated_byte_renewal_confs.writeBytes(t2_renewal_confs);
			}
			output.writeInt(temp_repeated_byte_renewal_confs.length);
			output.writeBytes(temp_repeated_byte_renewal_confs);
			output.writeInt(this.all_gold);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.op_type = input.readInt();
			this.mount_id = input.readInt();
			this.mount_type_id = input.readInt();
			this.mount_pos = input.readInt();
			this.renewal_type = input.readInt();
			this.end_time = input.readInt();
			this.op_fee = input.readInt();
			var byte_mount_size:int = input.readInt();
			if (byte_mount_size > 0) {				this.mount = new p_goods;
				var byte_mount:ByteArray = new ByteArray;
				input.readBytes(byte_mount, 0, byte_mount_size);
				this.mount.readFromDataOutput(byte_mount);
			}
			var size_renewal_confs:int = input.readShort();
			var length_renewal_confs:int = input.readInt();
			if (length_renewal_confs > 0) {
				var byte_renewal_confs:ByteArray = new ByteArray; 
				input.readBytes(byte_renewal_confs, 0, length_renewal_confs);
				for(i=0; i<size_renewal_confs; i++) {
					var tmp_renewal_confs:p_equip_mount_renewal = new p_equip_mount_renewal;
					var tmp_renewal_confs_length:int = byte_renewal_confs.readInt();
					var tmp_renewal_confs_byte:ByteArray = new ByteArray;
					byte_renewal_confs.readBytes(tmp_renewal_confs_byte, 0, tmp_renewal_confs_length);
					tmp_renewal_confs.readFromDataOutput(tmp_renewal_confs_byte);
					this.renewal_confs.push(tmp_renewal_confs);
				}
			}
			this.all_gold = input.readInt();
		}
	}
}
