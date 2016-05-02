$(document).ready(function(){

  var handler = StripeCheckout.configure({
    key: $("#js-dues").data("key"),
    email: $("#js-dues").data("email"),

    token: function(token, args) {
        var tokenElem = $("<input type='hidden' name='token'>").val(token.id);
        $("#payment-form").append(tokenElem).submit();
        $("#js-dues").text("Updating...").attr("disabled", "disabled");
    }
  });

  $('#js-dues').on('click', function(e) {
    handler.open({
      name: "AndConf",
      description: "You're buying one $325 ticket",
      allowRememberMe: false
    });
    e.preventDefault();
  });
});
