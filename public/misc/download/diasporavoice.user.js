// ==UserScript==
// @name           Diaspora* Voice    
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
"var isopen=false;\n" + 
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
"var banner='[![voice](http://bit.ly/vivqi7)](http://bit.ly/vbzjvr)';\n" + 
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
"}\n" + 
"function voiceCommentInsertText(t,nid){\n" + 
"vmessage+=t+' ';\n" + 
"if(!isopen){\n" + 
"var label=document.getElementById('new_comment_on_'+nid).getElementsByTagName('label');\n" + 
"label[0].style.display='none';\n" + 
"document.getElementById('comment_text_on_'+nid).setAttribute('style','resize:none;direction:ltr;height:50px;overflow-y:hidden;');\n" + 
"document.getElementById('new_comment_on_'+nid).setAttribute('class','new_comment open');\n" + 
"document.getElementById('new_comment_on_'+nid).setAttribute('onSubmit','voiceCommentClean('+nid+')');\n" + 
"document.getElementById('comment_submit_'+nid).setAttribute('onClick','voiceCommentAddBanner('+nid+')');\n" + 
"isopen=true;\n" + 
"}\n" + 
"document.getElementById('voice_input_on_'+nid).value='';\n" + 
"document.getElementById('comment_text_on_'+nid).value=vmessage;\n" + 
"}\n" + 
"function voiceCommentAddBanner(nid){\n" + 
"var banner='[![voice](http://bit.ly/sxa30x)](http://bit.ly/vbzjvr)';\n" + 
"vmessage+='\\n'+banner;\n" + 
"document.getElementById('comment_text_on_'+nid).value=vmessage;\n" + 
"document.getElementById('voice_input_on_'+nid).value=vmessage;\n" + 
"}\n" + 
"function voiceCommentClean(nid){\n" + 
"vmessage='';\n" + 
"document.getElementById('comment_text_on_'+nid).setAttribute('style','resize:none;overflow-y:hidden;');\n" + 
"document.getElementById('comment_submit_'+nid).removeAttribute('onClick');\n" + 
"document.getElementById('voice_input_on_'+nid).value=vmessage;\n" + 
"document.getElementById('new_comment_on_'+nid).removeAttribute('onSubmit');\n" + 
"isopen=false;\n" + 
"}"; 
document.body.appendChild(s);

function addVoiceCommentInput(nid){
var element = document.getElementById('comment_text_on_'+nid);
if (element) {
    element.setAttribute('voice',"voice");
	newElement = document.createElement('div');
	newElement.setAttribute("id","voice_box_on_"+nid);
	newElement.setAttribute("title","Speech to text");
	newElement.setAttribute("style","position:absolute !important;bottom:1px !important;right:38px;z-index:10;overflow-x:hidden;overflow-y:hidden;direction:ltr;display:inline-block");
    newElement.innerHTML="<input id='voice_input_on_" + nid + "' x-webkit-speech='x-webkit-speech' onfocus=\"voiceCommentInsertText(this.value,\'" + nid + "')\" style='width:15px;margin:0;outline:none;border:none;color:#fff!important;'>";
	element.parentNode.insertBefore(newElement, element.nextSibling);
}
}

//function addclick(id){
//var o=document.getElementById(id);
//o.addEventListener('click', function(){
//				addvoice(o);
//		}, false);
//}

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
var mainstream = document.getElementById('main_stream');
if(mainstream){
	var commentarea=mainstream.getElementsByTagName('textarea'); 
	for(var i=0; i<commentarea.length; i++) {
		if(commentarea[i] && commentarea[i].hasAttribute('id') && !commentarea[i].hasAttribute('voice')) {
			var id=commentarea[i].getAttribute('id');
			var nid=id.match(/[\d\.]+/g);
			addVoiceCommentInput(nid);
		}
	}
}
}

document.addEventListener("load", init, true);

// hasAttribute e getAttribute deprecated - sostituire con querySelector?
// "var label = document.evaluate('//form[#new_comment_on_'+nid+' > p > label'], document.documentElement, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null)"
