function Asset(){
  
  this.id          = false;
  this.coordinates = [];
  this.dimensions  = [];
  this.is_selected = false;
  this.is_editing  = false;

  this.initialize = function(asset_hash) {

    this.id           = asset_hash.id;
    this.coordinates  = asset_hash.coordinates;
    this.dimensions   = asset_hash.dimensions;
    this.hash         = asset_hash;

    this.dom          = this.render();

    this.initialize_controls();

  };

  this.render = function(){

    var tmpl = $("#asset_" + this.hash.asset_type + "_tmpl").html();

    Editor.product_editable_area.append( Mustache.to_html( tmpl, this.hash ) );
    
    $("#" + this.hash.__id).
      css({
        top         :  this.hash.coordinates[0],
        left        :  this.hash.coordinates[1],
        zIndex      :  this.hash.coordinates[2],
        width       :  this.hash.width,
        height      :  this.hash.height,
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
      click(function(){
        $(this).addClass('selected').
          siblings(".asset").removeClass('selected');
        that.initialize_settings();
      }).
      draggable({
        containment: Editor.product_editable_area,
        grid : [ 2, 2 ]
      }).
      resizable({
        minWidth    : 50,
        minHeight   : 50,
        containment : Editor.product_editable_area,
        autoHide    : false,
        handles     : "all",
        grid        : [ 5, 5 ],
        maxWidth    : $(this).parent().width(),
        maxHeight   : $(this).parent().height()
      }).
      dblclick(function(){
        that.edit_content();
      }).
      blur(function(){
        if (that.hash.asset_type=='text') {
          that.update();
        }
      });

  };

  this.initialize_settings = function(){

    var that = this,
        tools = $(".asset_tools");
    
    if (that.hash.asset_type=='text') {
      tools.removeClass('show_asset_photo_fields').addClass('show_asset_text_fields');
    } else {
      tools.addClass('show_asset_photo_fields').removeClass('show_asset_text_fields');
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
      val( this.hash.color );

    tools.
      find(".bg_color_control").
      val ( this.hash.bg_color );

  };

  this.reset_settings = function(){
    
    Editor.reset_settings_panel();

  };

  this.edit_content = function(){

    this.is_editing = true;

    if (this.hash.asset_type=='text') {
      this.edit_content_text();
    } else {
      this.edit_content_graphic();
    }

    this.initialize_settings();

  };

  this.edit_content_text = function(){
    
    this.select_text( this.dom.find("h1")[0] );

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

  this.update = function(){

    console.log('fake saving!', this.hash);

    $.ajax({

    });

  };

}