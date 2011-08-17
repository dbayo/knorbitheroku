// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var $list;

$("#tooltip img").tooltip();

$(function() {
	$( "#sortable1, #sortable2" ).sortable({
		connectWith: ".connectedSortable"
	}).disableSelection();
});

$(function() {
	var stop = false;
	$( "#accordion h3" ).click(function( event ) {
		if ( stop ) {
			event.stopImmediatePropagation();
			event.preventDefault();
			stop = false;
		}
	});
	$( "#accordion" )
		.accordion({
			header: "> div > h3",
			collapsible: true,
			alwaysOpen: false,  
			active: -1,
			icons: "none",
			autoHeight: false,
			changestart: function(event, ui) {
				$(ui.newHeader).children(':nth-child(2)').children(':nth-child(1)').addClass( "inputchangeheaderopened");
				$(ui.oldHeader).children(':nth-child(2)').children(':nth-child(1)').removeClass( "inputchangeheaderopened");
			}
		})
		.sortable({
			axis: "y",
			handle: "h3",
			stop: function() {
				stop = true;
			}
	});	
	
	if ($("#template")[0] != undefined) {
		var focus = false;
		$( ".inputchangename").click(function() {
			$(this).addClass( "inputchangenameover");
			$(this).parent().children(':nth-child(2)').css('visibility', 'visible');
			stop = true;
			focus = true;
		});
		$( ".inputchangename").blur(function() {
			$(this).removeClass( "inputchangenameover");
			$(this).parent().children(':nth-child(2)').css('visibility', 'hidden');
			focus = false;
		});
		$( ".inputchangename").mouseover(function() {
			if (focus == false) {
				$(this).addClass( "inputchangenameover");
				$(this).parent().children(':nth-child(2)').css('visibility', 'visible');
			}
		});
		$( ".inputchangename").mouseout(function() {
			if (focus == false) {
				$(this).removeClass( "inputchangenameover");
				$(this).parent().children(':nth-child(2)').css('visibility', 'hidden');
			}		
		});
		$( "#accordion" ).accordion( "option", "icons", false );
		$( "#accordion" ).click(function() {
			$( ".inputchangename").blur();
		});
	}
	
	$( "#accordionsummary" )
		.accordion({
			header: "> div > h3",
			collapsible: true,
			active: -1,
			icons: "none",
			autoHeight: false,
			changestart: function(event, ui) {
				$(ui.newHeader).children(':nth-child(2)').children(':nth-child(1)').addClass( "inputchangeheaderopened");
				$(ui.oldHeader).children(':nth-child(2)').children(':nth-child(1)').removeClass( "inputchangeheaderopened");
			}
		});
});

$(function() {
	$( "#accordion2" ).accordion({
		header: "> div > h3",
		collapsible: true,
		active: -1,
		autoHeight: false
	});
});

$(function() {
	$( "#job_date" ).datepicker({
		defaultDate: +27,
		dateFormat: "yy-mm-dd",
		showOtherMonths: true,
		selectOtherMonths: true,
		showAnim: "clip",
		minDate: 0,
		maxDate: +28,
		showOn: "button",
		buttonImage: "../../images/calendar.gif",
		buttonImageOnly: true
	});
});

$(function() {
	$( "#selectable" ).selectable();
});

/* Pop-up User*/

$(function() {
	$( "#user-popup" ).dialog({
		autoOpen: false,
		show: {effect: 'drop', direction: 'right'},
		height: 370,
		width: 380,
		draggable: false,
		resizable: false,
		modal: true
	});

	$( "#star" ).click(function() {
		$( "#user-popup" ).dialog( "open" );
		return false;
	});
});

/* Pop-up Flag*/

$(function() {
	$( "#recent-popup" ).dialog({
		autoOpen: false,
		show: {effect: 'drop', direction: 'right'},
		height: 370,
		width: 380,
		draggable: false,
		resizable: false,
		modal: true
	});

	$( "#flag" ).click(function() {
		$( "#recent-popup" ).dialog( "open" );
		return false;
	});
});

/* Setting tabs as owner*/

$(function() {
	$( ".ui-tabs .ui-tabs-nav, .ui-tabs .ui-tabs-nav > *" ).removeClass( "ui-corner-all ui-corner-top" );
	$( ".ui-tabs .ui-tabs-nav, .ui-tabs .ui-tabs-nav > *" ).addClass( "ui-corner-bottom" );		
});

/* Rewards slider*/
var rewards = new Array();
rewards[0] = "NEUTRAL";
rewards[1] = "FAIR";
rewards[2] = "GOOD";
rewards[3] = "EXCELLENT";
rewards[4] = "EXCEPTIONAL";

$(function() {
	$( ".slider" ).slider({
		min: 0,
		max: 4,
		step: 1,
		animate: true
	});
});


/* Tabs when create new Job*/

$(function() {
	$( "#tabsnewjob" ).tabs({ disabled: [1, 2, 3, 4, 5, 6] });
	$( ".ui-tabs .ui-tabs-nav, .ui-tabs .ui-tabs-nav > *" ).removeClass( "ui-corner-all ui-corner-top" );
	$( ".ui-tabs .ui-tabs-nav, .ui-tabs .ui-tabs-nav > *" ).addClass( "ui-corner-bottom" );
});

/* Show and Hide notices */
$(function() {
	$( "#noticesuccess" ).show( "highlight" );
});

$( "#tabs" ).tabs({
   	select: function(event, ui) {
   		$( "#noticesuccess" ).hide( "blind", {}, 500 );
		setTimeout(function() {
			$( "#noticesuccess" ).remove();
		}, 1 );
   	}
});

/*
	function callback() {
		$( "#noticesuccess" ).hide( "blind", {}, 500 );
		setTimeout(function() {
			$( "#noticesuccess" ).remove();
		}, 1 );
	};
*/