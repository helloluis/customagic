//
// checks for CURRENT_USER and FACEBOOK_AUTH_URL constants
//

var Hearts = {
  
  product_ids : [],

  initialize: function(){
    if (typeof CURRENT_USER=='undefined') {
      $(".toggle_heart").
        attr('data-hint','Login via FB to <3 this').
        addClass('hint__right').
        click(function(){
          Flasher.add(['notice',"Logging you via Facebook ..."],true);
          window.location.assign(FACEBOOK_AUTH_URL + "&return_to" + window.location.path);
          return false;
        });

    } else {
      
      $.ajax({
        url : "/user/hearts",
        dataType: "JSON",
        success : function(data) {
          Hearts.product_ids = data;
          Hearts.show_hearted_products();
          Hearts.initialize_buttons();
        }
      });

    } 
  },

  show_hearted_products : function(){
    _.each(Hearts.product_ids, function(p){
      $(".toggle_heart[data-id='" + p + "']").addClass('hearted');
    });
  },

  initialize_buttons : function(){
    $(".toggle_heart").click(function(){
      var el = $(this),
          id = el.attr('data-id');

      $.ajax({
        url : "/user/toggle_heart/" + id,
        dataType : "JSON",
        success : function(data) {
          el.toggleClass('hearted');
        }
      });
    });
  }

};