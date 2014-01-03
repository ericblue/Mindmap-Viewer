  var formTarget;

    function generateLink(url,description) {

      var url = '<a href=\"' + url + '\">' + description + '</a>';
      return url;

    }

    function generateIFrame(url,height,width) {

    var iframe = '<iframe id=\"mindmap\" name=\"mindmap\" height=\"' +height + '\" width=\"' +width+'\"';
    iframe += ' src=\"' + url + '\"></iframe>';

    return iframe;

    }

    function selectAll(obj) { 

        var text_val=eval(obj);
        text_val.focus();
        text_val.select();
        if (!document.all) return; // IE only

        r= text_val.createTextRange();
    } 

    function getRadioOption(obj) {

        for(var i = 0; i < obj.length; i++) {
            if (obj[i].checked) {
                return(obj[i].value);
            }
        }

        return null;

    }
 
  function setTarget(target) {

     //document.forms['defaultform'].target=target;

     formTarget = target;

  } 

  function submitForm() {


    if (formTarget == 'embeddisp') {

       var dstUrl= 'http://eric-blue.com/projects/mindmapviewer/display.cgi?'
       var encodedUrl= document.forms['defaultform'].mmap_url.value;
       // For whatever reason, a period in this query string value causes the flash viewer not to render
       // This will URL encode the period to %2E.  This is strange indeed... ETB
       encodedUrl = encodedUrl.replace(/\.mmap/, "%2Emmap");
       dstUrl += 'mmap_url=' + encodedUrl;
       dstUrl += '&format=' +  getRadioOption(document.forms['defaultform'].format);

        parent.frames['embeddisp'].document.location.href= dstUrl;
    }
    else {
        document.forms['defaultform'].submit();
      }

  }

  function init() {
      //document.forms['defaultform'].mmap_url.value='http://eric-blue.com/projects/mindmapviewer/sample/consciousness.mmap';
      document.forms['defaultform'].mmap_url.value='http://eric-blue.com/blog/download/Goals%20Mind%20Map%20Template.mmap';

      setTarget('embeddisp');
}

