package com.scene.sceneUtils
{
	
	public class MoveSpeedMath
	{
		public static const V_COEFFICIENT:Number=0.6324; //斜方向为1，此为上下速度
		public static const H_COEFFICIENT:Number=1.265; //横向速度系数
		//    /\
		//   /  \
		//   \  /
		//    \/
		public static const tileAng:Number=0.4625 //格子横轴与左上边的夹角,单位是弧度
		
		public static function getRealSpeed(speed:Number, dir:int):Number
		{
			var realSpeed:Number;
			if (dir == 0 || dir == 4)
			{ //上下
				realSpeed=speed * V_COEFFICIENT;
			}
			else if (dir == 2 || dir == 6)
			{ //左右
				realSpeed=speed * H_COEFFICIENT;
			}
			else
			{ //斜
				realSpeed=speed;
			}
			return realSpeed;
		}
		
		public static function getDirSpeed(speed:Number, dir:int):Object
		{
			var realSpeedX:Number;
			var realSpeedY:Number;
			switch (dir)
			{
				case 0:
					realSpeedX=0;
					realSpeedY=-speed * V_COEFFICIENT;
					break;
				case 1:
					realSpeedX=Math.cos(tileAng) * speed;
					realSpeedY=-Math.sin(tileAng) * speed;
					break;
				case 2:
					realSpeedX=speed * H_COEFFICIENT;
					realSpeedY=0;
					break;
				case 3:
					realSpeedX=Math.cos(tileAng) * speed;
					realSpeedY=Math.sin(tileAng) * speed;
					break;
				case 4:
					realSpeedX=0;
					realSpeedY=speed * V_COEFFICIENT;
					break;
				case 5:
					realSpeedX=-Math.cos(tileAng) * speed;
					realSpeedY=Math.sin(tileAng) * speed;
					break;
				case 6:
					realSpeedX=-speed * H_COEFFICIENT;
					realSpeedY=0;
					break;
				case 7:
					realSpeedX=-Math.cos(tileAng) * speed;
					realSpeedY=-Math.sin(tileAng) * speed;
					break;
				default:
					throw new Error("速度计算错误!");
					break;
			}
			return {'xSpeed':realSpeedX, 'ySpeed':realSpeedY};
		}
	}
}