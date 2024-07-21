package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_dropthing_pick_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var add_money:int = 0;
		public var money:int = 0;
		public var dropthingid:int = 0;
		public var goods:p_goods = null;
		public var num:int = 0;
		public var money_type:int = 0;
		public function m_map_dropthing_pick_toc() {
			super();
			this.goods = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_map_dropthing_pick_toc", m_map_dropthing_pick_toc);
		}
		public override function getMethodName():String {
			return 'map_dropthing_pick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.add_money);
			output.writeInt(this.money);
			output.writeInt(this.dropthingid);
			var tmp_goods:ByteArray = new ByteArray;
			this.goods.writeToDataOutput(tmp_goods);
			var size_tmp_goods:int = tmp_goods.length;
			output.writeInt(size_tmp_goods);
			output.writeBytes(tmp_goods);
			output.writeInt(this.num);
			output.writeInt(this.money_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.add_money = input.readInt();
			this.money = input.readInt();
			this.dropthingid = input.readInt();
			var byte_goods_size:int = input.readInt();
			if (byte_goods_size > 0) {				this.goods = new p_goods;
				var byte_goods:ByteArray = new ByteArray;
				input.readBytes(byte_goods, 0, byte_goods_size);
				this.goods.readFromDataOutput(byte_goods);
			}
			this.num = input.readInt();
			this.money_type = input.readInt();
		}
	}
}
