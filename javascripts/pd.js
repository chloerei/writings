function prettyDate ( timeObj ) {
  function setToStartOfDay( timeObject ) {
    return new Date(timeObject.getUTCFullYear(), timeObject.getUTCMonth(), timeObject.getUTCDate(), 0, 0, 0, 0);
  }
  function pluralize(count, singular, plural) {
    return count + " " + ( (count == 1) ? singular : (plural || singular + "s") );
  }

  var date = timeObj,
    today = setToStartOfDay( new Date() ),
    start_of_the_day = setToStartOfDay( date ),
    day_diff = Math.floor( ( (today - start_of_the_day) / 1000) / 86400);

  if ( isNaN(day_diff) || day_diff < 0 )
    return;

  return day_diff == 0 && "Today" ||
    day_diff == 1 && "Yesterday" ||
    day_diff < 7 && day_diff + " days ago" ||
    day_diff < 31 && pluralize(Math.round( day_diff / 7 ), "week") + " ago" ||
    day_diff < 366 && pluralize( Math.round( day_diff / 7 / 4 ), "month") + " ago" ||
    day_diff >= 366 && pluralize( Math.round( day_diff / 7 / 4 / 12 ), "year") + " ago";
}

$(function(){

  $("body").keyup(function(event) {

		if($(".left > a").length == 1 && event.which == 37) 
			location.replace($(".left >a").attr("href"));
		else if($(".right > a").length == 1 && event.which == 39)
			location.replace($(".right >a").attr("href"));
	});

});
