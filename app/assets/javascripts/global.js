// global js


/*******************************
* Appending the CSRF token to every ajax request
*******************************/
$.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader('X-CSRF-Token',$('meta[name="csrf-token"]').attr('content'));
    },
    error:function(x,s,e) {
      if (error_message = $.parseJSON(x.responseText)) {
        Flasher.add(['error',(error_message.errors ? error_message.errors : error_message)],true);  
      }
    }
});


/*******************************
*
* Flasher Notification Object,
* wraps around jQuery.nottys
*
*******************************/

var Flasher = {
  
  messages : [],
  flash    : false,
  timeouts : { 
    "notice"      : 5000,
    "success"     : 5000,
    "stop_notice" : false, 
    "warning"     : false,
    "alert"       : false,
    "error"       : false
  },
  in_iframe : false,
  is_mobile : false,
  
  initialize : function() {

    Flasher.is_mobile = isTouchDevice();

    if (self!==top) {

      Flasher.in_iframe=true;

      if (Flasher.is_mobile) {
        Flasher.scroll_target = $(window.parent.parent);
      } else {
        Flasher.scroll_target = $(window);
      }

      Flasher.scroll_target.scroll(_.throttle(function(){ Flasher.adjust_nottys() },100));
      
      Flasher.adjust_nottys();

    }

  },

  adjust_nottys : function(){

    $("#nottys").css({ marginTop : Flasher.scroll_target.scrollTop() });
    
  },
  
  // all message_arr should be in the format of [ type, string ]
  // e.g., [ "error", "Something went wrong with your form submission!", function(){} ];
  // ["success", "Saved successfully!"]
  add : function(message, and_render) {
    if (_.include(_.keys(Flasher.timeouts), message[0])) {
      
      var messages = Flasher.messages, 
          dupe = false;
      
      //console.log(Flasher.messages);

      for (var i=0; i<messages.length; i++) {
        if ( messages[i][0]==message[0] && messages[i][1]==message[1] ) {
          dupe=true;
        }
      }

      if (!dupe) {
        Flasher.messages.push(message);  
        if (and_render===true) {
          Flasher.render(Flasher.messages[Flasher.messages.length-1]);
        }
      }
      
    }
  },
  
  render : function(message) {
    if (message===undefined) {
      if (Flasher.messages.length>1) {
        $(Flasher.flash).everyTime(500, function(i){
          Flasher.render_message(Flasher.messages[i-1], (i-1));
        }, Flasher.messages.length);
      } else {
        Flasher.render_message(Flasher.messages[0], 0);
      }
    } else {
      Flasher.render_message(message, Flasher.messages.length-1);
    }
    Flasher.cleanup();
  },
  
  render_message : function(message_arr, index) {
    
    if (message_arr===undefined || message_arr.length<2) {
      return false;
    }
    
    var timeout = Flasher.timeouts[message_arr[0]],
      notty_options = {
        title   : message_arr[0],
        content : message_arr[1],
        timeout : message_arr[3] ? message_arr[3] : timeout,
        click   : message_arr[2],
        css_class : message_arr[0]
      };

    if (message_arr[0]=='notice') {
      notty_options.click = undefined;
      notty_options.hideCallback = message_arr[2];
    }
    
    // should probably just write our own for this
    // $("body").notty( notty_options );
    
  },
  
  cleanup : function() {
    var other_messages = $(".notty", "#nottys");
    //console.log('cleaning up', other_messages.length);

    if (other_messages.length>3) {
      $(other_messages.get(other_messages.length-1)).remove();
    }
  },
  
  hide_all : function() {
    $("#nottys").find(".hide").click();
  }
  
};


jQuery.fn.outerHTML = function(s) {
return (s)
  ? this.before(s).remove()
  : jQuery("<p>").append(this.eq(0).clone()).html();
};