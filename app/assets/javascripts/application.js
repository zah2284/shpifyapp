// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-material-design
//= require tinymce-jquery
//= require libs/handlebars.min
//= require turbolinks

$(document).on('turbolinks:load', function(){
  console.log("ready");
  $("button.chooseImage").on("click",function(){
    var id = $(this).attr("data-id");
    ShopifyApp.Modal.open({
      src: "/product/image/" + id,
      title: 'Choose Image',
      width: 'small',
      height: 500,
      buttons: {
        primary: {
          label: "Save",
          callback: function(){
            var mbody = ShopifyApp.Modal.window();
            mbody.$("#chooseImageForm").submit();
          }
        },
        secondary: [
          {
            label: "Cancel",
            callback: function (label) {
              ShopifyApp.Modal.close();
            }
          }
        ]
      }
    }, function(result, data){

    });
  });



});
