var MemeGenerator = {
  
  url    : "/canned_images/memes",
  page   : 1,
  images : [],

  initialize: function(){

    var that = this; 

    that.list = $(".artwork");
    that.tmpl = $("#external_image_object_tmpl").html();

    $.ajax({
      url : that.url,
      data: { page: that.page },
      success : function(data) {
        that.images = that.images.concat(data.result);
        that.append_images(data.result);
      }
    });

  },

  append_images: function(raw_data){
    var that = this;
    _.each(_.values(raw_data), function(rd,id){
      
      var el = Mustache.to_html(that.tmpl,{
        __id      : id,
        filename  : rd.filename,
        medium    : rd.filename,
        thumbnail : rd.thumbnail,
        title     : rd.name
      });
      
      el = $(el);

      that.list.append(el);
      
      el.click(function(){
        if (!el.hasClass('loading')) {
          el.addClass("loading");  
          that.upload_image( el.attr('data-url'), function(){
            el.removeClass("loading");
          });
        }
      });
    });
  },

  upload_image: function(url, callback){

    var f = $("#photo_uploader"),
        d = { product_id : Editor.product._id, 
              image : { remote_attachment_url : url } };

    $.ajax({
      url : f.attr('action'),
      type : "POST",
      data : d,
      dataType : "JSON",
      success : function(data) {
        
        var parsed_data = data;
      
        if (parsed_data.error) {
          
          Flasher.add(['error',parsed_data.error],true);
          
        } else {
          
          Editor.initialize_asset_and_image( parsed_data );

        }

      },
      complete : function(x) {
        
        if (typeof callback!=='undefined') {
          callback.call();
        }

      }
    });

  }

}