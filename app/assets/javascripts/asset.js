function Asset(){
  
  this.id             = false;
  this.coordinates    = [];
  this.dimensions     = [];
  this.is_selected    = false;
  this.is_editing     = false;
  this.saving_timer   = false;

  this.initialize = function(asset_hash) {

    this.id           = asset_hash.__id;
    this.coordinates  = asset_hash.coordinates;
    this.width        = asset_hash.width;
    this.height       = asset_hash.height;
    this.hash         = asset_hash;
    this.asset_type   = asset_hash.asset_type;
    this.dom          = this.render();

    this.initialize_controls();

    this.dom.click();

  };

  this.render = function(){

    var tmpl  = $("#asset_" + this.hash.asset_type + "_tmpl").html(),
      scale   = function(w, h){
        var cont     = Editor.product_editable_area,
            cont_w   = cont.width(),
            cont_h   = cont.height(),
            width    = parseInt(w),
            height   = parseInt(h),
            scaled_w = w,
            scaled_h = h;

        if (cont_w>w || cont_h>h){
          if (cont_w>w) {
            scaled_h = h*(w/cont_w);
          }
          if (cont_h>h) {
            scaled_w = w*(h/cont_h);
          }
        }
        return [scaled_w, scaled_h];
      };

    Editor.product_editable_area.append( Mustache.to_html( tmpl, this.hash ) );
    
    $("#" + this.hash.__id).
      removeAttr('contenteditable').
      css({
        left        :  parseInt(this.hash.coordinates[0]), // x
        top         :  parseInt(this.hash.coordinates[1]), // y
        zIndex      :  parseInt(this.hash.coordinates[2]), // z
        width       :  scale(this.hash.width, this.hash.height, true),
        height      :  scale(this.hash.width, this.hash.height, false),
        fontSize    :  this.hash.font_size,
        fontFamily  :  this.hash.font_family,
        color       :  this.hash.color,
        textAlign   :  this.hash.alignment
      });

    return $("#" + this.hash.__id);

  };

  this.initialize_controls = function(){
    
    var that = this;

    $("#" + that.hash.__id).
      mousedown(function(){
        $(this).addClass('selected').
          siblings(".asset").removeClass('selected');
        that.initialize_settings();
      }).
      draggable({
        containment: Editor.product_editable_area,
        grid : [ 2, 2 ],
        stop : function(ev,ui) {
          that.save();
        }
      }).
      resizable({
        minWidth    : 50,
        minHeight   : 50,
        containment : Editor.product_editable_area,
        autoHide    : false,
        handles     : "all",
        grid        : [ 5, 5 ],
        maxWidth    : $(this).parent().width(),
        maxHeight   : $(this).parent().height(),
        stop : function(ev,ui) {
          that.save();
        }
      }).
      dblclick(function(){
        that.edit_content();
      }).
      blur(function(){
        if (that.hash.asset_type=='text') {
          that.stop_editing();
          that.save();
        }
      });

  };

  this.initialize_settings = function(){

    var that = this,
        tools = $(".asset_tools");
    
    Editor.selected_asset = this;

    if (that.hash.asset_type=='text') {
      tools.removeClass('show_asset_photo_fields').
        addClass('show_asset_text_fields');
    } else if (that.hash.asset_type=='photo') {
      tools.addClass('show_asset_photo_fields').
        removeClass('show_asset_text_fields');
    }
    
    tools.
      removeClass('disabled').
      find(".input_field, .select_field, .alignment_control").
      removeAttr('disabled');

    tools.
      find(".asset_id_field").
      val( this.hash.__id );

    tools.
      find(".font_family_control").
      val( this.hash.font_family );

    tools.
      find(".font_size_control").
      val( this.hash.font_size );

    tools.
      find(".alignment_control").
      val( this.hash.alignment );

    tools.
      find(".alignment_button.alignment_" + this.hash.alignment ).
      addClass("current").
      siblings().
      removeClass("current");

    tools.
      find(".color_control").
      val(this.hash.color).
      spectrum('enable').
      spectrum('set', this.hash.color);
    
    tools.
      find(".bg_color_control").
      val(this.hash.bg_color).
      spectrum('enable').
      spectrum('set', this.hash.bg_color);

  };

  this.reset_settings = function(){
    
    Editor.reset_settings_panel();

  };

  this.edit_content = function(){

    this.is_editing = true;
    
    Editor.start_editing();

    if (this.hash.asset_type=='text') {
      this.edit_content_text();
    } else {
      this.edit_content_graphic();
    }

    this.initialize_settings();

  };

  this.edit_content_text = function(){
    
    this.dom.attr('contenteditable','true');

    this.select_text( this.dom.find("span")[0] );

  };

  this.stop_editing = function(){

    this.dom.removeAttr('contenteditable');
    Editor.stop_editing();

  };

  this.select_text = function(el){
    
    var range, selection;
    
    if (document.body.createTextRange) {
    
      range = document.body.createTextRange();
      range.moveToElementText(el);
      range.select();
    
    } else if (window.getSelection) {
    
      selection = window.getSelection();
      range = document.createRange();
      range.selectNodeContents(el);
      selection.removeAllRanges();
      selection.addRange(range);
    
    }
    
    el.focus();

  };

  this.save = function(){

    var that = this,
      save_settings = function(){
        that.is_saving = true;

        $.ajax({
          url      : "/shops/" + Editor.shop.slug + "/assets/" + that.id,
          data     : { asset : that.hash },
          dataType : "JSON",
          method   : "PUT",
          success  : function(data){
            that.saving_timer.stop();
          },
          complete : function(x) {
            that.is_saving = false;
          }
        });
      };

    that.update_hash();

    if (that.saving_timer || that.is_saving) {
      that.saving_timer.stop();
    }

    that.saving_timer = $.timer(save_settings);
    that.saving_timer.set({ time : 5000, autostart: true });
    
  };

  this.update_hash = function(){
    
    // this.saveable_hash = {
    //   coordinates:  [ this.dom.position().left, 
    //                   this.dom.position().top, 
    //                   parseInt(this.dom.css('zIndex')) ], // type: Array,    default: [0,0,1] # x, y, z
    //   width:        this.dom.width(),                     // type: Integer,  default: 250 
    //   height:       this.dom.height(),                    // type: Integer,  default: 100
    //   color:        this.dom.css('color'),                // type: String,   default: "#000000"
    //   bg_color:     this.dom.css('background-color'),     // type: String,   default: "transparent"
    //   font_family:  this.dom.css('font-family'),          // type: String,   default: "Helvetica"
    //   font_size:    this.dom.css('font-size'),            // type: String,   default: "36px"
    //   alignment:    this.dom.css('text-align'),           // type: String,   default: "center"
    //   content:      this.dom.text()                       // type: String,   default: "Text"
    // };
    this.hash = _.extend(this.hash, {
      coordinates:  [ this.dom.position().left, 
                      this.dom.position().top, 
                      parseInt(this.dom.css('zIndex')) ], // type: Array,    default: [0,0,1] # x, y, z
      width:          this.dom.width(),                   // type: Integer,  default: 250 
      height:         this.dom.height(),                  // type: Integer,  default: 100
      color:          this.dom.css('color'),              // type: String,   default: "#000000"
      bg_color:       this.dom.css('background-color'),   // type: String,   default: "transparent"
      font_family:    this.dom.css('font-family'),        // type: String,   default: "Helvetica"
      font_size:      this.dom.css('font-size'),          // type: String,   default: "36px"
      alignment:      this.dom.css('text-align'),         // type: String,   default: "center"
      content:        this.dom.text()                     // type: String,   default: "Text"
    });

  };

}