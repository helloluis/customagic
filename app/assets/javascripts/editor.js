var Editor = {

  assets_path : "/assets",

  scale : 0.12,

  initialize : function(shop, types, product, assets, images) {
    
    this.mobile         = $("body").hasClass("mobile_browser");
    this.shop           = shop;
    this.product_types  = types;
    this.product        = product;
    this.assets         = assets;
    this.images         = images;
    
    this.current_side   = 0; // which side of the item are we viewing? (front/back/etc)

    this.initialize_product();
    this.initialize_viewer();
    this.initialize_controls();
    this.initialize_asset_settings();
    this.initialize_meme_generator();
    this.initialize_window();

  },

  initialize_product : function(){
    
    var that = this;

    this.product_type  = this.product_types[0]; // shirt
    this.product_style = this.product_types[0].product_styles[0]; // basic tee
    

    if (that.product.product_type) {
      if (type = _.find(that.product_types,function(p){ return p.slug==that.product.product_type; })) {
        this.product_type = type;
        if (product_style = _.find(that.product_type.product_styles,function(pp){ return pp.slug==that.product.product_style; })) {
          this.product_style = product_style;
        }
      }
    } 

  },

  initialize_viewer : function() {

    var that = this;

    that.product_preview = $(".viewer .product");
    
    that.product_editable_area = $(".viewer .editable_area");

    that.initialize_scale();

    that.asset_objects = [];
    that.image_objects = [];

    _.each(that.assets, function(asset){
      
      var a = new Asset();
      a.initialize(asset);
      that.asset_objects.push(a);

    });

    _.each(that.images, function(img){
      
      var i = new ImageObject();
      i.initialize(img);
      that.image_objects.push(i);

    });

    $(".toggle_artwork_viewer").click(function(){
      $(".styles").toggleClass('expanded_artwork');
      if ($(".styles").hasClass('expanded_artwork')) {
        $(this).text("View less art ...");
      } else {
        $(this).text("View more art ...");
      }
    });

    that.product_preview.click(function(){
      that.product_editable_area.find(".asset").removeClass('selected');
      that.reset_settings_panel();
    });

  },

  initialize_scale : function(){

    var that = this;
    
    that.dpi_target    = this.product_type.dpi_target;
    that.full_width    = that.product_type.sides[that.current_side].editable_area[0]*this.product_type.dpi_target;
    that.full_height   = that.product_type.sides[that.current_side].editable_area[1]*this.product_type.dpi_target;
    that.scaled_width  = that.full_width*that.scale;
    that.scaled_height = that.full_height*that.scale;

    that.product_editable_area.css({ 
      width  : that.scaled_width, 
      height : that.scaled_height,
      left   : (that.product_preview.width()-that.scaled_width)/2
    });

  },

  initialize_window : function(){

    var init_scale = function(){
      Editor.initialize_scale();
    };
    
    $(window).resize(_.throttle(init_scale,500));

  },

  initialize_controls : function() {

    var that = this;

    that.initialize_color_swatches();
    that.initialize_sub_styles();
    that.initialize_content_buttons();

    $(".next_step").click(function(){
      
      var el   = $(this).attr('disabled','disabled').val('Saving ...'),
          href = el.is("a") ? el.attr('href') : el.attr('data-href');
      
      Flasher.add(['notice',"Please wait, we're saving your changes."], true);

      that.publish(function(){
        window.location.assign( href );
      });
      
      return false;
    });

  },

  initialize_asset_settings : function(){
    
    var that = this;

    $(".font_family_control, .font_size_control, .alignment_control").
      change(function(){
        var css_name = $(this).attr('data-css-name');
        Editor.selected_asset.dom.css(css_name, $(this).val());
        Editor.selected_asset.save();
      });

    $(".color_control, .bg_color_control").
      spectrum({
        showPalette: true,
        showInitial: true,
        showInput:   true,
        showSelectionPalette: true,
        showAlpha:  false,
        palette: [],
        localStorageKey: "spectrum",
        change : function(color){
          var css_name = $(this).attr('data-css-name');
          Editor.selected_asset.dom.
            css(css_name, color.toHexString());
          Editor.selected_asset.save();
        }
      });

    $(".bg_color_control").spectrum('option','allowEmpty',true);
      
    $(".alignment_button").click(function(){
      $(this).addClass('current').siblings().removeClass('current');
      $(".alignment_control").val( $(this).attr('data-alignment') ).change();
    });

    $(".increase_zindex, .decrease_zindex, .clone_asset").click(function(){
      alert("This doesn't work yet :P");
    });

    $(".delete_asset").click(function(){
      var id = that.selected_asset.id;
      $.ajax({
        url  : "/shops/" + that.shop.slug + "/assets/" + id,
        type : "DELETE",
        success : function(data) {
          that.selected_asset.dom.remove();
          that.selected_asset  = false;
          Editor.asset_objects = _.reject(Editor.asset_objects, function(ao){ return ao.id==id; });
        }
      });
    });
  },

  initialize_meme_generator : function(){

    MemeGenerator.initialize();

  },

  initialize_sub_styles : function(){
    
    var that = this;

    $(".product_sub_style.sub_style_" + that.product.sub_style).
      addClass('current').
      siblings(".product_sub_style").
      removeClass("current");

    $(".product_sub_style").click(function(){
      var el = $(this),
          slug = el.attr('data-target'),
          price = el.attr('data-base-price');

      el.addClass('current').
        siblings(".product_sub_style").
        removeClass('current');

      $("#product_product_sub_style").val( slug );
      $(".price_container .currency").text( price ).currency({ region : that.shop.currency_symbol });

    });
  },

  initialize_content_buttons : function(){

    var that = this;
    
    $(".content_buttons").
      find(".add_text").
      click(function(){
        that.create_text_asset();
      });

    $(".add_art").
      click(function(){
        $(this).
          toggleClass('toggled');
        $(".artwork_container").
          toggleClass('hidden');
      });

    var asset_browser = $(".artwork_viewer");

    //////////////////////////////////
    // local or remote file toggler //
    //////////////////////////////////
    $("input[name='photo_source']").click(function(){
      
      $("#"+$(this).val()).show().siblings('.photo_source_input').hide().find("input").attr('disabled');
      
      $("#"+$(this).val()).find("input").removeAttr('disabled','disabled');

      if ($(this).val()=='remote_file') {
        $("#photo_uploader .buttons").removeClass('hidden');
      } else {
        $("#photo_uploader .buttons").addClass('hidden');
      }
    });

    /////////////////////////
    // local file uploader //
    /////////////////////////
    var jqXHR = $("#attachments").fileupload({
      acceptFileTypes : /(\.|\/)(gif|jpe?g|png)$/i,
      maxFileSize: 5000000,
      formData : { product_id: that.product.slug },
      sequentialUploads : true,
      done : function(e,data){
        
        var el = $("#attachments"),
            parsed_data = $.parseJSON(data.result.replace(/\<textarea\>/i, '').replace(/\<\/textarea\>/i, ''));
        
        if (parsed_data.error) {
          //console.log(parsed_data.error);
          Flasher.add(['error',parsed_data.error],true);
          
          $("#progress .bar").css({ width : "0%" });
          $("#progress label").text("");
          el.data('errors', el.data('errors') ? el.data('errors')+1 : 1);
          data.jqXHR.abort();

        } else {
          
          Editor.initialize_asset_and_image( parsed_data );
          
          if (typeof callback!=='undefined') {
            callback.call(this, new_asset);
          }
          
          $(".instructions", asset_browser).text( $(".instructions", asset_browser).attr('data-orig-text') );
          var progress = parseInt(data.loaded/data.total*100, 10);
          $("#progress label").text("Still uploading ...");
          $("#progress .bar").css({ width : progress + "%" });  
        }

      },
      stop : function(e){
        
        if (typeof completed_callback!=='undefined') {
          completed_callback.call();
        }
        
        $("#progress .bar").css({ width : "0%" });
        $("#progress label").text("");
        
        if (!$("#attachments").data('errors')) {
          Flasher.add(['notice',"Your photos have been successfully uploaded."],true);  
        }
        
        $('#attachments').fileupload('enable').removeAttr('disabled').removeData('errors');
        
      },
      progressall : function(e,data){

        var progress = parseInt(data.loaded/data.total*100, 10);
        $("#progress label").text("Still uploading ...");
        $("#progress .bar").css({ width : progress + "%" });

        if ($("#attachments").attr('disabled')!=='disabled') {
          $('#attachments').fileupload('disable').attr('disabled','disabled');  
        }

      },
      fail : function(e,data) {
        
        Flasher.add(['error',e],true);
        $('#attachments').fileupload('enable').removeAttr('disabled');
        $("#progress .bar").css({ width : "0%" });
        $("#progress label").text("");
        jqXHR.abort();

      }
    }).
    bind('fileuploadprocessfail', function (e, data) {
      
      Flasher.add(['error',"Please ensure that your images are in GIF, JPEG or PNG format, and less than 5mb."],true);
      $('#attachments').fileupload('enable').removeAttr('disabled');
      jqXHR.abort();

    });

    //////////////////////////
    // remote file uploader //
    //////////////////////////
    var cont = $("#photo_uploader"),
      photo_submit      = $("input.submit_photo",cont).
                            attr('disabled','disabled').
                            addClass("disabled gray34"),
      remote_file_field = $("#asset_attachment_url",cont),
      http_regex        = new RegExp(/^http[s]?:\/\/[\w\.-]+\/[^\s\<\>\{\}\~]+$/i);

    
    $("#asset_attachment_url",cont).
      bind("input propertychange change paste", function(){
        var val = $(this).val();
        if (val.length>0 && http_regex.test(val)) {
          photo_submit.removeAttr("disabled").removeClass("disabled gray34").addClass("orange34");
        } else {
          photo_submit.attr("disabled","disabled").removeClass("orange34").addClass("disabled gray34");
        }    
      });

    $("#photo_uploader").
      submit(function(){

        var f = $(this),
            d = { product_id : that.product._id, 
                  image : { remote_attachment_url : $("#asset_attachment_url").val() } };

        photo_submit.val(photo_submit.attr('data-loading'));

        $.ajax({
          url : f.attr('action'),
          type : "POST",
          data : d,
          dataType : "JSON",
          success : function(data) {
            
            var parsed_data = data;
          
            if (parsed_data.error) {
              
              Flasher.add(['error',parsed_data.error],true);
              
              $("#progress .bar").css({ width : "0%" });
              $("#progress label").text("");

            } else {
              
              Editor.initialize_asset_and_image( parsed_data );

            }

          },
          complete : function(x) {
            
            photo_submit.val("Upload");

          }
        });

      return false;
    });

  },

  initialize_asset_and_image : function( parsed_data ) {

    if (parsed_data[0]) {
      var new_asset = new Asset();
      new_asset.initialize(parsed_data[0]);
      Editor.asset_objects.push(new_asset);
    }
    
    if (parsed_data[1]) {
      var new_image = new ImageObject();
      new_image.initialize(parsed_data[1]);
      Editor.image_objects.push(new_image);
    }
    
  },

  initialize_color_swatches : function() {

    var that = this,
        colors_list = $(".swatches");

    _.each(this.product_type.colors, function(c,i){
      colors_list.append( Mustache.to_html($("#color_swatch_tmpl").html(), 
        { color : c, 
          color_image : that.product_style.color_images[i]
        }) );
    });
    
    colors_list.
      find(".swatch").
      click(function(){
        that.set_color(this);
      });

    $(".swatches .swatch[data-hex='" + this.product.color + "']").click();

  },

  create_text_asset : function(){
    var that = this;

    that.loading();

    $.ajax({
      url : "/shops/" + that.shop.slug + "/assets",
      type : "POST",
      data : { product_id : that.product.slug },
      success : function(data){
        var a = new Asset();
        a.initialize(data);
        that.asset_objects.push(a);
      },
      complete : function(x) {
        that.loading_stop();
      }
    });


  },

  reset_settings_panel : function(){
    
    $('.asset_tools').
      addClass('disabled').
      find(".input_field,.select_field,.alignment_control").
      attr('disabled','disabled');
    
    $('.asset_tools').find(".asset_id_field").val("");

    $(".asset_tools").
      find(".color_control, .bg_color_control").
      spectrum('disable');

  },

  set_color : function(el){

    var that = this,
        el   = $(el);
    
    el.addClass('current').siblings().removeClass('current');

    that.product.color = el.attr('data-hex');
    $("#product_color").val( el.attr('data-hex') );
    that.product_preview.css({ 'backgroundImage': "url(" + that.assets_path + "/" + el.attr('data-image') + ")" });

  },

  publish : function(success_callback){

    var that = this;
    
    that.loading();

    that.final_art_html  = that.render_assets_in_markup();
    that.mockup_html     = that.render_assets_in_markup(true);

   $.ajax({
      url : "/shops/" + that.shop.slug + "/products/" + that.product.slug,
      type : "PUT",
      data : { 
        product : { 
          final_art_html       : that.final_art_html,
          mockup_html          : that.mockup_html,
          final_art_dimensions : [ that.full_width, that.full_height ],
          mockup_dimensions    : [ that.scaled_width, that.scaled_height ],
          product_style        : $("#product_product_style").val(),
          product_sub_style    : $("#product_product_sub_style").val(),
          color                : $("#product_color").val()
        }, 
        publish : true },
      dataType : "JSON",
      success : function(data) {
        if (typeof success_callback!=='undefined') {
          success_callback.call();
        }
      },
      complete : function(x) {
        that.loading_stop();
      }
    });

  },

  render_assets_in_markup : function(thumb_only){

    var that = this,
        mod  = thumb_only===true ? 1 : (100/(that.scale*100)),
        main = $("<div class='main'></div>").
                css({
                  position  : "absolute",
                  width     : thumb_only===true ? that.scaled_width  : that.full_width,
                  height    : thumb_only===true ? that.scaled_height : that.full_height,
                }),
        content = $("<div class='content'></div>").
                css({ 
                  position  : "absolute",
                  backgroundColor: 'transparent', //that.product.color,
                  transform : "scale(" + mod + ")",
                  "transform-origin" : "top left",
                  width     : that.scaled_width, 
                  height    : that.scaled_height
                });

    _.each(that.asset_objects, function(a){
      
      var clone = a.dom.clone();
  
      clone.css({
          position: 'absolute',
          width:    a.dom.width(),
          height:   a.dom.height()
        }).
        appendTo(content).
        removeClass('ui-resizable').
        removeClass('ui-draggable').
        find(".ui-resizable-handle").
        remove();

      var img = clone.find("img").css({ width: '100%' });

      // a bit of cleanup
      if (img.length) {
        if (img.attr('data-original')) {
          img.attr('src', img.attr('data-original'));
        } else {
          clone.remove();  
        } 
      }
      
    });

    return "<html style='background-color:transparent;'><body style='background-color:transparent;'>" + main.append(content.outerHTML()).outerHTML() + "</body></html>";

  },

  freeze : function(){

    this.is_frozen = true;
    this.product_editable_area.find(".asset").resizable('enable').draggable('enable');
    this.reset_settings_panel();

  },

  thaw : function(){

    this.is_frozen = false;
    this.product_editable_area.find(".asset").resizable('disable').draggable('disable');

  },

  start_editing : function(){

    this.is_editing = true;
    $(".next_step").attr('disabled','disabled');

  },

  stop_editing : function(){

    this.is_editing = false;
    $(".next_step").removeAttr('disabled');

  },

  loading : function(){
    $("body.shop").addClass('loading');
  },

  loading_stop: function(){
    $("body.shop").removeClass('loading');
  }

};