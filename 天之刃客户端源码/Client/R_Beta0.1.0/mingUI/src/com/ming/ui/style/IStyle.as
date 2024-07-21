package com.ming.ui.style
{
	import com.ming.ui.skins.AccordionSkin;
	import com.ming.ui.skins.CheckBoxSkin;
	import com.ming.ui.skins.ListSkin;
	import com.ming.ui.skins.NumericStepperSkin;
	import com.ming.ui.skins.PanelSkin;
	import com.ming.ui.skins.ScrollBarSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.SliderSkin;
	import com.ming.ui.skins.TabBarSkin;
	import com.ming.ui.skins.TabNavigationSkin;
	
	import flash.text.TextFormat;

	public interface IStyle
	{
		function get textFormat():TextFormat;
		function get buttonSkin():Skin;
		function get selectedSkin():Skin;
		function get scrollBarSkin():ScrollBarSkin;
		function get tabBarSkin():TabBarSkin;
		function get checkBoxSkin():CheckBoxSkin;
		function get comboBoxSkin():Skin;
		function get listSkin():ListSkin;
		function get textInputSkin():Skin;
		function get textAreaSkin():Skin;
		function get radioButtonSkin():CheckBoxSkin;
		function get panelSkin():PanelSkin;
		function get listItemSkin():Skin;
		function get numericStepperSkin():NumericStepperSkin;
		function get textScrollSkin():ScrollBarSkin;
		function get sliderSkin():SliderSkin;
		function get tabNavigationSkin():TabNavigationSkin;
		function get accordionSkin():AccordionSkin;
	}
}