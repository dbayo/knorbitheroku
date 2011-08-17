var xmlHttp;
var lasttags = new Array;

function changeRelated(obj) {
	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url="/jobs/1/skilltagcloudajax";
	url=url+"?related="+escape(obj);
	xmlHttp.onreadystatechange=stateChanged;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
	var i = jQuery.inArray(obj, lasttags);
	if (i != -1) {
		lasttags.splice(i+1,lasttags.length - i);
	}else{
		if(lasttags.length > 4) {
			lasttags.shift();
		}
		lasttags.push(obj);
	}	
	$('#lastvalue').html("History ");
	jQuery.each(lasttags, function(index, value) {
		$('#lastvalue').append(" - <a href='#' onclick=\"changeRelated('"+value+"');\">"+value+"</a>");
    });
	
}

function changeCategory() {
	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url="/jobs/1/skilltagcloudajax";
	url=url+"?cat="+document.getElementById('category').value;
	xmlHttp.onreadystatechange=stateChanged;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function saveComment() {
	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url=location.pathname+'/savecomment';
    url=url+"?comment="+document.getElementById('comment').value;
	xmlHttp.onreadystatechange=commentSaved;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function changeGroup(group, id) {

	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url=location.pathname+'/changegroup';
    url=url+"?user_id="+id+"&group="+group;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function addnewgroup(group) {

	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url=location.pathname+'/addnewgroup';
    url=url+"?group="+group;
    xmlHttp.onreadystatechange=groupadded;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function removegroup(group) {

	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url=location.pathname+'/removegroup';
    url=url+"?group="+group;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function getGroupUsers(group) {

	xmlHttp=GetXmlHttpObject();
	if (xmlHttp == null) {
		alert("Your browser does not support AJAX");
		return;
	}
	var url="/jobs/1/getGroupUsersFromMyNetwork";
    url=url+"?group="+group;
    xmlHttp.onreadystatechange=listGroupUsers;
	xmlHttp.open("GET",url,true);
	xmlHttp.send(null);
}

function GetXmlHttpObject() {
	var xmlHttp=null;
	try {
		xmlHttp = new XMLHttpRequest();
	}catch(e){
		try {
			xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		}catch (e) {
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
	return xmlHttp;
}

