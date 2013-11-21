// global js


//
// Appending the CSRF token to every ajax request
//
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