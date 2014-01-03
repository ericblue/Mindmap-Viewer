
function viewMap() {
    
    var dstUrl= 'http://eric-blue.com/projects/mindmapviewer/display.cgi?'
    var encodedUrl= encodeURIComponent(contextMenuLinkUrl());
    // For whatever reason, a period in this query string value causes the flash viewer not to render
    // This will URL encode the period to %2E.  This is strange indeed... ETB
    encodedUrl = encodedUrl.replace(/.mmap/, "%2Emmap");
    dstUrl += 'mmap_url=' + encodedUrl;
    dstUrl += '&format=flash';
    
    open(dstUrl, "mindmapviewer", "resizable=yes,toolbar=no,width=800,height=600");

    
}

function contextMenuLinkUrl() {   
  return 'getLinkURL' in gContextMenu ? gContextMenu.getLinkURL() : gContextMenu.linkURL();
}
