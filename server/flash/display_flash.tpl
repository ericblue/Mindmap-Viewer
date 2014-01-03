<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta name="description" content="freemind flash browser"/>
<meta name="keywords" content="freemind,flash"/>
<title>MindMap Viewer</title>
<script type="text/javascript" 
src="http://eric-blue.com/projects/mindmapviewer/flash/flashobject.js"></script>
<link rel="stylesheet" type="text/css" href="http://eric-blue.com/projects/mindmapviewer/css/mindmap.css" />
<script language="javascript">
function giveFocus() 
    { 
      document.visorFreeMind.focus();  
    }
</script></head>
$HEADER$</br>

	<div id="flashcontent" onmouseover="giveFocus();">
		 Flash plugin or Javascript are turned off.
		 Activate both  and reload to view the mindmap
	</div>
	
	<script type="text/javascript">
		// <![CDATA[
		// for allowing using http://.....?mindmap.mm mode
		function getMap(map){
		  var result=map;
		  var loc=document.location+'';
		  if(loc.indexOf(".mm")>0 && loc.indexOf("?")>0){
			result=loc.substring(loc.indexOf("?")+1);
		  }
		  return result;
		}
		var fo = new 
FlashObject("http://eric-blue.com/projects/mindmapviewer/flash/visorFreemind.swf", 
"visorFreeMind", "100%", "100%", 6, "#9999ff");
		fo.addParam("quality", "high");
		fo.addParam("bgcolor", "#ffffff");
		fo.addVariable("openUrl", "_blank");
		fo.addVariable("startCollapsedToLevel","2");
		fo.addVariable("maxNodeWidth","200");
		//
		fo.addVariable("mainNodeShape","elipse");
		fo.addVariable("justMap","false");
		
fo.addVariable("initLoadFile",getMap("http://eric-blue.com/projects/mindmapviewer/maps/$MAPID$"));
		fo.addVariable("defaultToolTipWordWrap",200);
		fo.addVariable("offsetX","center");
		fo.addVariable("offsetY","center");
		fo.addVariable("buttonsPos","left");
		fo.addVariable("min_alpha_buttons",20);
		fo.addVariable("max_alpha_buttons",100);
		fo.addVariable("scaleTooltips","false");
		
			
		fo.write("flashcontent");
		// ]]>
	</script>
</body>
</html>
