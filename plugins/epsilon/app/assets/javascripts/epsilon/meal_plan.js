// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/**
 * Event handler for when the filter button is clicked (index.html.erb)
 * --Makes AJAX call to filter users
 */
$( document ).on( 'click', '.meal_plan_filter_btn',function() {
	var data = {year: $("#filter_class").val(),
				house: $("#filter_house").val(),
				meal_plan: $("#filter_meal_plan").val()};
	$.ajax({
		url: this.id,
		type: "POST",
		data: data,
		success: function(data, textStatus, jqXHR) {
			var usr_tbl = $("#user_body");
			usr_tbl.html(data);
		}
	});
});

$( document ).on( 'click', '.meal_plan_toggle',function() {
	var data = {id: this.value};
	var cells = this.parentNode.parentNode.children;
	var field = cells[cells.length-2];
	$.ajax({
		url: this.id,
		type: "POST",
		data: data,
		success: function(data, textStatus, jqXHR) {
			field.innerHTML = data;
		}
	});
});