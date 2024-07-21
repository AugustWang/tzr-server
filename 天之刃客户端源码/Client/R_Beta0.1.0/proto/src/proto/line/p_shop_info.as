package proto.line {
	import proto.line.p_shop_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_shop_info extends Message
	{
		public var id:int = 0;
		public var name:String = "";
		public var branch_shop:Array = new Array;
		public function p_shop_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_shop_info", p_shop_info);
		}
		public override function getMethodName():String {
			return 'shop_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			var size_branch_shop:int = this.branch_shop.length;
			output.writeShort(size_branch_shop);
			var temp_repeated_byte_branch_shop:ByteArray= new ByteArray;
			for(i=0; i<size_branch_shop; i++) {
				var t2_branch_shop:ByteArray = new ByteArray;
				var tVo_branch_shop:p_shop_info = this.branch_shop[i] as p_shop_info;
				tVo_branch_shop.writeToDataOutput(t2_branch_shop);
				var len_tVo_branch_shop:int = t2_branch_shop.length;
				temp_repeated_byte_branch_shop.writeInt(len_tVo_branch_shop);
				temp_repeated_byte_branch_shop.writeBytes(t2_branch_shop);
			}
			output.writeInt(temp_repeated_byte_branch_shop.length);
			output.writeBytes(temp_repeated_byte_branch_shop);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readUTF();
			var size_branch_shop:int = input.readShort();
			var length_branch_shop:int = input.readInt();
			if (length_branch_shop > 0) {
				var byte_branch_shop:ByteArray = new ByteArray; 
				input.readBytes(byte_branch_shop, 0, length_branch_shop);
				for(i=0; i<size_branch_shop; i++) {
					var tmp_branch_shop:p_shop_info = new p_shop_info;
					var tmp_branch_shop_length:int = byte_branch_shop.readInt();
					var tmp_branch_shop_byte:ByteArray = new ByteArray;
					byte_branch_shop.readBytes(tmp_branch_shop_byte, 0, tmp_branch_shop_length);
					tmp_branch_shop.readFromDataOutput(tmp_branch_shop_byte);
					this.branch_shop.push(tmp_branch_shop);
				}
			}
		}
	}
}
