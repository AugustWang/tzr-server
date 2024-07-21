package com.components.progressBar{
	import com.globals.GameConfig;
	import com.gs.Linear;
	import com.gs.TweenMax;
	import com.managers.WindowManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	

	public class CommonProgressBar extends UIComponent{
        private var bg:Bitmap;
        private var bar:Bitmap;
        private var _count:int;
        private var _time:Timer
        private var title:TextField;
        private var barTitle:String;
        private var txtType:int;//1:显示百分比 2:显示倒计时
        public function CommonProgressBar(varBarTitle:String ="",pTxtType:int=1){
            this.barTitle = varBarTitle;
            this.txtType = pTxtType;
        }
        
        public function initView():void{
            //this.buttonMode=true;
            bg = Style.getBitmap(GameConfig.T1_VIEWUI,'collect_bar_bg');
            bar = Style.getBitmap(GameConfig.T1_VIEWUI,'collect_bar');
            bar.x = 17;
            bar.y = 20;
            
            addChild(bg);
            addChild(bar);
            
            title = ComponentUtil.createTextField(barTitle,1,1,new TextFormat("宋体",12,0xFFFFFF),120,19,this);
            title.filters=[new GlowFilter(0x000000, 1, 1, 1, 120)]
            
        }
        public function update($time:int):void{
            bar.scaleX = 0;
            _count = $time;
            TweenMax.to(bar,$time,{scaleX:1,ease: Linear.easeNone,onComplete: onTimerComplete,onUpdate:onTimerUpdate});
        }
        
        private function timerHandler(evt:TimerEvent):void{
            bar.scaleX = _time.currentCount/_count;
            
        }
        private var curCount:int = 0;
        private var curH:int = 0;
        private var curM:int = 0;
        private var curTxt:String = null;
        public function onTimerUpdate():void{
            if(this.txtType == 1){
                title.text = barTitle + int(bar.scaleX*100) + "%";
            }else if(this.txtType == 2){
                curCount = (1 - bar.scaleX) * _count;
                curH = 0;
                curM = 0;
                curTxt = "";
                if(curCount < 60){
                    curTxt = "0:0:" + curCount.toString();
                }else if(curCount < 60 * 60){
                    curM = int(curCount/60);
                    curTxt = "0:" + curM.toString() + ":" + int(curCount - curM * 60).toString();
                }else{
                    curH = int(curCount/3600);
                    curM = int((curCount - curH * 3600)/60);
                    curTxt = "" + curH.toString() + ":" +　
                        curM.toString() + ":" + 
                        int(curCount - curH * 3600  - curM * 60).toString();
                } 
                title.text = barTitle + curTxt;
            }else{
                title.text = barTitle + int(bar.scaleX*100) + "%";
            }
            title.x = (162 - title.textWidth)/2;
        }
        
        private function onTimerComplete():void{
            setTimeout(function clean():void{
                try{
                    WindowManager.getInstance().removeWindow(this);
                }catch(e:Error){
                    
                }
            },3000);
        }
		
	}
}