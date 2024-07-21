package com.scene.sceneData
{

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;


	public class MapEncode
	{
		public function MapEncode()
		{

		}

		public static function encode(vo:MapDataVo):ByteArray
		{
			var mx:int=vo.offsetX + MapDataVo.CORRECT_VALUE
			var my:int=vo.offsetY + MapDataVo.CORRECT_VALUE;
			var width:int=vo.width;
			var height:int=vo.height;
			var byte:ByteArray=new ByteArray;
			//写入地图id
			byte.writeInt(vo.map_id);
			//是否副本
			byte.writeInt(vo.isSub);
			//写入地图名
			byte.writeMultiByte(vo.name, 'cn-gb');
			byte.position=40;
			//写入图片地址
			byte.writeMultiByte(vo.imageLink, 'cn-gb');
			byte.position=72;
			//写入格子数目
			byte.writeInt(vo.tileRow);
			byte.writeInt(vo.tileCol);
			//写入物品数目
			byte.writeInt(vo.elements.length);
			//写入跳转点数目
			byte.writeInt(vo.transfers.length);
			//写入图片偏移量
			byte.writeInt(mx);
			byte.writeInt(my);
			//写入背景高宽
			byte.writeInt(width);
			byte.writeInt(height);

			//写入单元格
			var arr:Array;
			for (var x:int=0; x < vo.tiles.length; x++)
			{
				arr=vo.tiles[x];
				for (var z:int=0; z < arr.length; z++)
				{
					byte.writeByte(arr[z]);
				}
			}
			//写入地图元素
			for (var j:int=0; j < vo.elements.length; j++)
			{
				var element:MapElementVo=vo.elements[j];
				//写入物品id 
				byte.writeInt(element.id);
				//写入物品位置
				byte.writeInt(element.tx);
				byte.writeInt(element.ty);

				//写入物品类型
				byte.writeInt(element.itemType);
				//计算avatarId长度
				var b:ByteArray=new ByteArray;
				b.writeMultiByte(element.avatarId, 'cn-gb');
				//写入物品形象id长度
				byte.writeInt(b.length);
				//写物品形象id
				byte.writeMultiByte(element.avatarId, 'cn-gb');
			}
			//写入跳转点
			for (j=0; j < vo.transfers.length; j++)
			{
				var tran:MapTransferVo=vo.transfers[j]
				//写入物品id 
				byte.writeInt(tran.id);
				//写入各自索引
				byte.writeInt(tran.tx);
				byte.writeInt(tran.ty);

				//写入目标跳转点索引
				byte.writeInt(tran.tar_Map);
				byte.writeInt(tran.tar_tx);
				byte.writeInt(tran.tar_ty);

				//写入跳转条件
				byte.writeInt(tran.hw);
				byte.writeInt(tran.yl);
				byte.writeInt(tran.wl);
				byte.writeInt(tran.minLevel);
				byte.writeInt(tran.maxLevel);
				//计算avatarId长度
				var tb:ByteArray=new ByteArray
				tb.writeMultiByte(tran.avatarId, 'cn-gb');
				//写入物品形象id长度
				byte.writeInt(tb.length);
				//写入avatarId
				byte.writeMultiByte(tran.avatarId, 'cn-gb')
			}
			byte.compress()
			return byte
		}

		/**
		 * 读文件
		 * @param bytes
		 * @return
		 *
		 */
		public static function encodeByteArray(bytes:ByteArray):MapDataVo
		{
			var t:int=getTimer();
			var hash:Dictionary=new Dictionary
			bytes.position=0;
			try
			{
				bytes.uncompress()
			}
			catch (e:Error)
			{
			}
			var vo:MapDataVo=new MapDataVo;
			vo.map_id=bytes.readInt(); //地图id
			vo.isSub=bytes.readInt(); //是否副本
			vo.name=bytes.readMultiByte(32, 'cn-gb'); //地图名
			vo.imageLink=bytes.readMultiByte(32, 'cn-gb'); //图片地址


			vo.tileRow=bytes.readInt(); //格子数
			vo.tileCol=bytes.readInt();
			var ele_length:int=bytes.readInt(); // 地图元素数目
			var tran_length:int=bytes.readInt(); //跳转点数

			vo.offsetX=bytes.readInt() - MapDataVo.CORRECT_VALUE; //背景图偏移量
			vo.offsetY=bytes.readInt() - MapDataVo.CORRECT_VALUE;

			vo.width=bytes.readInt(); //背景图宽高 
			vo.height=bytes.readInt();

			var tiles:Array=new Array(vo.tileRow);
			var arr:Array;
			for (var x:int=0; x < tiles.length; x++)
			{
				arr=new Array(vo.tileCol);
				for (var z:int=0; z < arr.length; z++)
				{
					arr[z]=bytes.readUnsignedByte();
				}
				tiles[x]=arr;
			}
			vo.tiles=tiles;
			//元素列表
			var elements:Vector.<MapElementVo>=new Vector.<MapElementVo>
			for (var j:int=0; j < ele_length; j++)
			{
				var ele:MapElementVo=new MapElementVo;
				ele.id=bytes.readInt();
				ele.tx=bytes.readInt();
				ele.ty=bytes.readInt();
				ele.itemType=bytes.readInt();
				//读取链接名长度
				var l:int=bytes.readInt();
				//读取链接名
				ele.avatarId=bytes.readMultiByte(l, 'cn-gb')
				elements.push(ele)
			}
			vo.elements=elements;
			//物品列表
			var transfers:Vector.<MapTransferVo>=new Vector.<MapTransferVo>
			for (var k:int=0; k < tran_length; k++)
			{

				var tran:MapTransferVo=new MapTransferVo;

				//读取跳转点所在的地图id,各自索引,
				tran.id=bytes.readInt();
				tran.tx=bytes.readInt();
				tran.ty=bytes.readInt();

				tran.tar_Map=bytes.readInt();
				tran.tar_tx=bytes.readInt();
				tran.tar_ty=bytes.readInt();

				tran.hw=bytes.readInt();
				tran.yl=bytes.readInt();
				tran.wl=bytes.readInt();
				tran.minLevel=bytes.readInt();
				tran.maxLevel=bytes.readInt();

				var len:int=bytes.readInt();
				tran.avatarId=bytes.readMultiByte(len, 'cn-gb');
				transfers.push(tran)
			}
			vo.transfers=transfers;
			trace("MCM文件解析时间：", getTimer() - t);
			return vo;
		}
	}
}