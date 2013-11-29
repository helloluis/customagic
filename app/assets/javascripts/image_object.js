function ImageObject() {
  
  this.id = false;

  this.initialize = function(img_hash) {

    this.list = $(".artwork");
    this.tmpl = $("#image_object_tmpl").html();

    if (typeof img_hash=='string') {
      img_hash = $.parseJSON(img_hash);
    }

    this.id = img_hash.__id;
    this.width = img_hash.width;
    this.height = img_hash.height;
    this.hash = img_hash;

    this.render();

  },

  this.render = function(){

    this.list.prepend(Mustache.to_html(this.tmpl, this.hash));

  }

}