var MemeGenerator = {
  
  url    : "/images/memes",
  page   : 0,
  images : [],

  initialize: function(){

    var that = this; 

    that.list = $(".artwork");
    that.tmpl = $("#external_image_object_tmpl").html();

    $.ajax({
      url : that.url,
      data: { pageIndex: that.page },
      success : function(data) {
        that.images = that.images.concat(data.result);
        that.append_images(data.result);
      }
    });

  },

  append_images: function(raw_data){
    var that = this;
    _.each(raw_data, function(rd){
      
      var el = Mustache.to_html(that.tmpl,{
        __id      : rd.generatorID,
        large_url : rd.imageUrl.replace("400x","1000x"),
        small_url : rd.imageUrl.replace("400x","100x"),
        title     : rd.displayName
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