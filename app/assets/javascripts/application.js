// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap

$(document).ready(function () {
  $.extend( $.fn.dataTable.defaults, {
    "bPaginate": false
  } );

  $('.js-datatable').dataTable({
  });

  $('.js-datatable-dues').dataTable({
    "aaSorting": [[ 2, "asc" ]]
  })

  $('.js-datatable-applications').dataTable({
    "aaSorting": [[ 1, "desc" ]],
    "aoColumnDefs": [
      {'aTargets': ['date'], 'sType': "date"}
    ]
  })
});

// Redirector app doesn't always work, so auto-redirect to SSL if someone manages
// to visit http://andconf.io. :'(
if (
  window.location.protocol === 'http:' &&
  window.location.hostname.indexOf("andconf.io") > -1
) {
  window.location.href = window.location.href.replace(/^http:/, 'https:')
}
