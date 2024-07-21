package com.ming.ui.controls
{
    import com.ming.events.ResizeEvent;
    import com.ming.ui.controls.core.UIComponent;
    
    import flash.display.*;

    public class ThumbBar extends UIComponent
    {
        private var iconButton:Sprite;

        public function ThumbBar()
        {
            addEventListener(ResizeEvent.RESIZE, thumbBarResize);
        }

        private function thumbBarResize(event:ResizeEvent) : void
        {
            if (iconButton != null)
            {
                iconButton.width = this.width;
                iconButton.height = this.width;
                iconButton.x = 0;
                iconButton.y = (this.height - iconButton.height) / 2;
                if (this.height < this.width)
                {
                    iconButton.visible = false;
                }
            }
        }

        public function set iconSkin(iconClass:Class) : void
        {
            if (iconClass == null && iconButton != null)
            {
                removeChild(iconButton);
                iconButton = null;
            }
            else if(iconClass)
            {
                if (iconButton == null)
                {
                    iconButton = new iconClass;
                }
                iconButton.width = this.width;
                iconButton.height = this.width;
                iconButton.x = 0;
                iconButton.y = (this.height - iconButton.height) / 2;
                addChild(iconButton);
            }
        }

    }
}
