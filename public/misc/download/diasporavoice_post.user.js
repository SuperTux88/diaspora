// ==UserScript==
// @name           Diaspora* Voice (only Post)   
// @description    Diaspora* with Google Chrome HTML5 speech to text input (for nerdpol.ch, diasp.org, joindiaspora.com, pod.geraspora.de)
// @include        https://nerdpol.ch/*
// @include        https://diasp.org/*
// @include        https://joindiaspora.com/*
// @include        https://pod.geraspora.de/*
// @exclude	   https://joindiaspora.com/profile/edit
// @author	   arlogattonero (nerdpol added by supertux@nerdpol.ch)
// @version        0.1.6
// ==/UserScript==

document.getElementById("q").setAttribute("x-webkit-speech","x-webkit-speech");

var s=document.createElement('script');
s.innerHTML="" + 
"var isactive=false;\n" + 
"var vmessage='';\n" + 
"function voicePostInsertText(t){\n" + 
"vmessage+=t+' ';\n" + 
"if(!isactive){\n" + 
"document.getElementById('publisher').removeAttribute('class');\n" + 
"document.getElementById('publisher_textarea_wrapper').setAttribute('class','active');\n" + 
"document.getElementById('new_status_message').setAttribute('onSubmit','voicePostClean();');\n" + 
"document.getElementById('status_message_submit').removeAttribute('disabled');\n" + 
"document.getElementById('status_message_submit').setAttribute('onClick','voicePostAddBanner();');\n" + 
"document.getElementById('hide_publisher').setAttribute('onClick','voicePostClean();');\n" + 
"isactive=true;\n" + 
"}\n" + 
"document.getElementById('voice_input').value='';\n" + 
"document.getElementById('status_message_text').setAttribute('value',vmessage);\n" + 
"document.getElementById('status_message_fake_text').value=vmessage;\n" + 
"}\n" +  
"function voicePostAddBanner(){\n" + 
"var banner='[![voice](https://nerdpol.ch/misc/images/voice_input.png)](https://nerdpol.ch/misc/speech_to_text.html)';\n" + 
"vmessage+='\\n'+banner;\n" + 
"document.getElementById('status_message_text').setAttribute('value',vmessage);\n" + 
"document.getElementById('status_message_fake_text').value=vmessage;\n" + 
"document.getElementById('voice_input').value=vmessage;\n" + 
"}\n" + 
"function voicePostClean(){\n" + 
"vmessage='';\n" + 
"document.getElementById('status_message_submit').removeAttribute('onClick');\n" + 
"document.getElementById('hide_publisher').removeAttribute('onClick');\n" + 
"document.getElementById('voice_input').value=vmessage;\n" + 
"document.getElementById('new_status_message').removeAttribute('onSubmit');\n" + 
"isactive=false;\n" + 
"}";
document.body.appendChild(s);

function init(){
var element = document.getElementById("file-upload");
if (element && !element.hasAttribute('voice')) {
    element.setAttribute('voice',"voice");
	newElement = document.createElement('div');
	newElement.setAttribute("id","voice_box");
	newElement.setAttribute("title","Speech to text");
	newElement.setAttribute("style","position:absolute !important;bottom:1px !important;right:30px;z-index:10;overflow-x:hidden;overflow-y:hidden;direction:ltr;display:inline-block");
    newElement.innerHTML="<input id='voice_input' x-webkit-speech onfocus='voicePostInsertText(this.value)' style='width:15px;margin:0;outline:none;border:none;color:#fff!important;'>";
	element.parentNode.insertBefore(newElement, element.nextSibling);
}
}

document.addEventListener("load", init, true);
