/*
 * jquery-cfcgenerator-form.js
 * dominic watson, 24th May 2009
 * custom js for the main cfc generator form
 */

jQuery(document).ready(function(){

	var getTables = function(){
		var selected = jQuery('#dsn').selectedValues();
		jQuery("#tables").removeOption(/./);
		
		if(selected.length && selected[0].length){
			jQuery("#tables").ajaxAddOption("", {event:"ajax.getTables",dsn:selected[0]}, true, checkFormReady);
		}
	}
	
	var checkFormReady = function(){
		var tables = jQuery("#tables").selectedValues();
		var template = jQuery("#template").selectedValues();
		
		if( tables.length && template.length && template[0].length){
			jQuery("#submit").removeAttr("disabled");
		} else {
			jQuery("#submit").attr("disabled", "disabled");

		}
	}
	
	var checkFormatOptions = function(){
		if( $("#formatServer:checked").val()){
			jQuery("#rootpath").removeAttr("disabled");
		} else {
			jQuery("#rootpath").attr("disabled", "disabled");
		}
	}
	
	jQuery('#dsn').change( function(event){
		getTables();
	});
	jQuery(':input', "#generatorform").change( function(event){
		checkFormReady();
	});
	
	jQuery(':input', "#formats").change( function(event){
		checkFormatOptions();		
	});
	
	// do all checks and loads on page ready as well as onChange events
	getTables();
	checkFormatOptions();   
	checkFormReady();
});