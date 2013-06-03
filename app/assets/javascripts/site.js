//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require lib/highlight

var highlightBlock = function() {
  $('pre code').each(function() {
    hljs.highlightBlock(this);
  });
};

$(function() {
  highlightBlock();
});

$(document).on('page:load', function() {
  highlightBlock();
});
