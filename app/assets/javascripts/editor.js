var Editor = {

  assets_path : "/assets",

  initialize : function(types, product, assets) {
    
    this.product_types = types;
    this.product = product;
    this.assets = assets;

    this.initialize_product();
    this.initialize_viewer();
    this.initialize_controls();

  },

  initialize_product : function(){
    
    var that = this;

    this.product_type = this.product_types[0]; // shirt
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

    that.asset_objects = [];

    _.each(that.assets, function(asset){
      
      var a = new Asset();
      a.initialize(asset);
      that.asset_objects.push(a);

    });

    that.product_preview.click(function(){
      that.product_editable_area.find(".asset").removeClass('selected');
      that.reset_settings_panel();
    });

  },

  initialize_controls : function() {

    this.initialize_color_swatches();
    this.initialize_content_buttons();

  },

  initialize_content_buttons : function(){

    $(".content_buttons").
      find(".add_text").
      click(function(){

      });

    $(".content_buttons").
      find(".add_art").
      click(function(){

      });

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

  },

  reset_settings_panel : function(){
    
    $('.asset_tools').
      addClass('disabled').
      find(".input_field,.select_field,.alignment_control").
      attr('disabled','disabled');
    
    $('.asset_tools').find(".asset_id_field").val("");

  },

  set_color : function(el){

    var that = this,
        el   = $(el);
    
    el.addClass('current').siblings().removeClass('current');

    that.product.color = el.attr('data-hex');
    that.product_preview.css({ 'backgroundImage': "url(" + that.assets_path + "/" + el.attr('data-image') + ")" });

  },

  update_product : function() {
    
    var that = this;

    $.ajax({
      url : "/products/" + that.product.slug,
      type : "PUT",
      dataType : "JSON",
      success : function(data) {

      }
    });

  }

};