package com.scene.sceneUnit {
	import com.globals.GameConfig;
	import com.ming.ui.skins.Skin;
	import com.scene.sceneUnit.baseUnit.SceneStyle;

	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * 摆摊的招牌，被包含在店小二或人物里面出现
	 * @author Administrator
	 *
	 */
	public class StallBoard extends Sprite {
		private var board:Skin;
		private var nametxt:TextField;

		public function StallBoard(boardName:String) {
			super();
			nametxt=new TextField;
			nametxt.text=boardName;
			nametxt.selectable=false;
			nametxt.autoSize=TextFieldAutoSize.CENTER;
			nametxt.textColor=0XFFF799;
			nametxt.x=-nametxt.width / 2;
			nametxt.y-=80;
			nametxt.filters=SceneStyle.nameFilter;
			board=new Skin(Style.getUIBitmapData(GameConfig.T1_UI, "stallBoard"), new Rectangle(19, 12, 40, 1));
			board.setSize(nametxt.width + 44, 25);
			board.x=-board.width / 2;
			board.y=nametxt.y - 4;
			addChild(board);
			addChild(nametxt);
		}

		public function reset(boardName:String):void {
			nametxt.text=boardName;
			board.setSize(nametxt.width + 44, 25);
			board.x=-board.width / 2;
		}
	}
}