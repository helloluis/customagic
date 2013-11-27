var Cart = {

  guest_id          : false,
  contents          : {},
  quantities        : 0,
  total_discount    : 0,
  cart_open         : false,
  checking_out      : false,
  is_loading        : false,
  width_cart        : 930,
  height_open_cart  : 585, // 572
  height_checkout   : 585, // 1055
  height_order_form : 585, // 1095
  initialized       : false,

  initialize : function(guest_id, contents, mobile, standalone){

    if (this.initialized) { return false; }

    if (!guest_id.length && window.location.hash.indexOf('preview_mobile_site')===-1) {
      Flasher.add(['error', "You cannot buy from this shop."],true);
      return false;
    }
    
    this.in_iframe  = self!==top;
    this.guest_id   = guest_id;
    this.contents   = contents;
    this.standalone = standalone;
    this.mobile     = mobile;
    this.quantities = this.calculate_quantities();

    this.initialize_order_form();
    this.initialize_cart_buttons();
    this.initialize_product_buttons();

    if (this.quantities>0) {
      $("body").addClass('cart_has_contents');
    }

    if ($(".payment_instructions",".shopping_cart").hasClass("with_payment_instructions")) {
      this.height_order_form = 1195;
    }

    this.initialized = true;

  },

  initialize_window_scroller : function(){

    var nudge_cart = function(){
      var scr  = $(window).scrollTop(),
          cart = $(".shopping_cart").css({top:scr});

      if (scr>100) {
        cart.addClass('compact');
      } else {
        cart.removeClass('compact');
      }
    };

    $(window).scroll(_.throttle(nudge_cart,100));

  },

  initialize_product_buttons : function(){
    
    var c = this;
    c.build_variant_tree();
    
    $("#primary_variant").change(function(){
      
      var pri = $("#primary_variant").val();

      c.active_variant = [pri];

      c.rebuild_secondary_variant_selector(pri);

      c.show_variant_image();

    });

    $("#secondary_variant").change(function(){
      
      var pri = $("#primary_variant").val(),
          sec = $("#secondary_variant").val(),
          slugify = function(id,primary,secondary){
            return _.compact([id,primary,secondary]).join('-').toLowerCase();
          };
      
      c.active_variant = [pri,sec];

      if (typeof PRODUCT==='object') {
        if (pv = _.find(PRODUCT.price_variants_with_discounts, function(pv){ return pv.primary==pri && pv.secondary==sec; })) {
          
          $("#variant_price").empty().append($("<span class='currency'></span>").text( pv.price ));
          
          $(".active_variant").attr({
            'data-variant-id' : slugify(PRODUCT._id, pri, sec),
            'data-price'      : pv.price,
            'data-name'       : _.compact([pv.primary, pv.secondary]).join(" "),
            'data-primary'    : pv.primary,
            'data-secondary'  : pv.secondary
          });

          $("#message_body").val("RE: " + PRODUCT.name + " (" + pri + " " + sec + ")");

        } else {
        
          $("#variant_price").html("Starts at <span class='currency'>" + PRODUCT.lowest_price_with_discount + "</span>");
        
        }

        $("#variant_price").find(".currency").formatCurrency({ symbol : SHOP_CURRENCY });
      }

      c.show_variant_image();
      
    });

  },

  initialize_payment_buttons : function(){

    var self = this,
        cancel_checkout = function(){
          
          scrollWindow(10);
          
          $(".shopping_cart").animate({ height : self.height_open_cart });
          $(".checkout_details").animate({ opacity : 0 }, { duration : 500, complete : function(){ $(this).hide(); }});
          $(".checkout", ".shopping_cart_details").show();

          this.checking_out = false;

        };
        
    $(".checkout_with_paypal").
      unbind('click').
      click(function(){
        
        if (self.quantities<1) {
          Flasher.add(['error',"You have nothing in your shopping cart."], true);
        } else {
          
          $(".payment_options,.offline_form").hide();
          $(".order_form,.online_form").show();
          
          if (!self.mobile) {
            $(".shopping_cart").animate({ height : self.height_order_form });  
          }
          
          Cart.recompute_totals();
          Cart.place_order_then_checkout_with_paypal();
        }
        return false;
      });

    $(".checkout_with_nothing").
      unbind("click").
      click(function(){
        //console.log('checkout with nothing');
        if (self.quantities<1) {
          
          Flasher.add(['error',"You have nothing in your shopping cart."], true);
          return false;

        } else {
          $(".payment_options,.online_form").hide();
          $(".order_form,.offline_form").show();
          
          if (!self.mobile) {
            $(".shopping_cart").animate({ height : self.height_order_form });  
          }
          
          Cart.recompute_totals();
          Cart.checkout_with_nothing();
          return false;
        }
      });

    $(".cancel_order_form").unbind("click").click(function(){
      
      $(".payment_options").show();
      $(".order_form, .offline_form, .online_form").hide();
      
      if (self.mobile==false) {
        $(".shopping_cart").animate({ height : self.height_checkout });  
      } else {
        // if (self!==top) {
        //   window.parent.parent.scrollTo(0,0);  
        // } else {
          scrollWindow(0);  
        //}
      }
      
      return false;
    });

    $(".cancel_checkout").unbind('click').click(cancel_checkout);

    if ($(".shopping_cart").hasClass("no_paypal")) {
      Cart.checkout_with_nothing();
    }
  },

  build_variant_tree : function(){
    if (typeof PRODUCT==='object' && PRODUCT.price_variants_with_discounts.length) {
      var tree = {};
      _.each(PRODUCT.price_variants_with_discounts,function(pv){
        if (tree[pv.primary]) {
          if (!_.include(tree[pv.primary], pv.secondary)) {
            tree[pv.primary].push(pv.secondary);
          }
        } else {
          tree[pv.primary] = [ pv.secondary ];
        }
      });
      this.variant_tree = tree;
      this.primary_variants = $("#primary_variant").find("option").map(function(){ if ($(this).val().length){ return [ $(this).text(), $(this).val() ]; }});
      this.secondary_variants = $("#secondary_variant").find("option").map(function(){ if ($(this).val().length){ return [ $(this).text(), $(this).val() ]; }});
    }
  },

  rebuild_secondary_variant_selector : function(primary){

    if (this.variant_tree) {

      $("#secondary_variant").find("option[class!='label']").remove();
  
      if (this.variant_tree[primary] && this.variant_tree[primary].length) {

        _.each( this.variant_tree[primary], function(sec){
          $("#secondary_variant").removeAttr('disabled').append($("<option value='" + sec + "'>" + sec.titleize() + "</option>"));//.select2();
        });

      } else {

        $("#secondary_variant").attr('disabled','disabled');

      }
      
    }

  },

  show_variant_image : function(){
    
    if (typeof PRODUCT==='object') {
    
      var self     = this,
          variant  = self.active_variant,
          variants = PRODUCT.price_variants,
          img      = $(".product_image_container").find("img");

      if (variant.length) {
        if (variant.length==2) {
          for (i=0;i<variants.length;i++) {
            if (variants[i].primary==variant[0] && variants[i].secondary==variant[1]) {
              img.attr('src',variants[i].image);      
            }
          }
        } else {
          for (i=0;i<variants.length;i++) {
            if (variants[i].primary==variant[0]) {
              img.attr('src',variants[i].image);      
            }
          }
        }
      }

      if (img.attr('src')=='') {
        img.attr('src', $(".first_product_image").attr('data-default') );
      }

    }
    
  },

  initialize_cart_buttons : function(){
    
    var self = this;
    
    $(".variant_and_price>label").
      click(function(){
        $(this).parent().
          siblings().
          removeClass("active_variant");

        $(this).parent().
          addClass('active_variant');
      });

    $(".add_to_cart").
      unbind('click').
      click(function(){
        self.add_to_cart(($(".single_variant").length ? $(".single_variant") : $(".active_variant")), $(this));
      });

    $(".shipping_cost").change(function(){
      self.recompute_totals();
    });

    $(".empty_cart").unbind('click').click(function(event){
      self.empty_cart();
      event.stopPropagation();
    });

    $(".close_cart").unbind('click').click(function(event){
      self.hide_cart();
      $(window).scrollTop(0);
      event.stopPropagation();
    });

    $(".checkout").unbind('click').click(function(event){
      self.checkout();
      event.stopPropagation();
    });

    $(".view_shopping_cart").unbind('click').click(function(){
      if (self.quantities>0 && self.cart_open===false) {
        self.display_cart();
      }
    });

    $(".shopping_cart").
      delegate('.increase_quantity','click',function(){
        if (!$(this).parents(".cart_item").hasClass('unavailable')) {
          self.increase_quantity( $(this).parents(".cart_item"), $(this) );
        }
        return false;
      }).
      delegate('.decrease_quantity','click',function(){
        if (!$(this).parents(".cart_item").hasClass('unavailable')) {
          self.decrease_quantity( $(this).parents(".cart_item"), $(this) );
        }
        return false;
      }).
      delegate('.remove_from_cart','click',function(){
        self.remove_from_cart( $(this).parents(".cart_item"), $(this) );
        return false;
      });

    $(".check_discount_code").unbind('click').click(function(){
      var bttn = $(this).text('Checking').attr('disabled','disabled');
      Cart.check_discount_code(function(){
        bttn.text('Apply Code').removeAttr('disabled');
      }, true);
      return false;
    });

    $(".proceed_to_payment").click(function(){
      if (self.calculate_quantities()>0) {
        $(this).text('Proceeding ...');
      } else {
        Flasher.add(['error', "You don't have any items in your cart."], true);
        return false;
      }
    });

  },

  add_to_cart : function(el, bttn, failure_callback, suppress_success_message) {

    var product_types = _.uniq(_.values(PRODUCT.price_variant_classes)).join(" and ");

    if (typeof el==='undefined') {
      Flasher.add(['error', "Please choose a " + product_types + " to add to your cart."], true);
    }

    var self  = this,
        id    = el.attr('data-id'),
        variant_id = el.attr('data-variant-id'),
        name  = el.attr('data-name')||"",
        price = el.attr('data-price')||0.0,
        multi = $("#primary_variant,#secondary_variant,.multiple_variants",".product_prices").length;
    
    if (multi&&!name) {
      Flasher.add(['error', "Please choose a " + product_types + " to add to your cart."],true);
      return false;
    }

    bttn.attr('disabled','disabled').addClass('disabled').find(".label").text("Adding ...");

    $.jsonp({
      url : "/carts/add.json?callback=?",
      type : "GET",
      dataType : 'jsonp',
      data  : { item_id  : id, 
                name     : name, 
                price    : price, 
                quantity : 1 },
      success : function(data) {
        
        if (data.error) {
          
          if (typeof failure_callback !== 'undefined') {
            failure_callback.call(this, data.error);
          } else {
            Flasher.add(['error', data.error],true);
          }
          
        } else {
          
          self.contents = data;
          self.quantities = self.calculate_quantities();

          if (self.quantities>0) {
            $("body").addClass("cart_has_contents");
          } else {
            $("body").removeClass("cart_has_contents");
          }
          $(".cart_quantities").text( self.quantities );

          if (this.cart_open===false) {
            var cart = $(".shopping_cart");
            if (cart.css('backgroundColor').toLowerCase()=='#ffffff') {
              var old_c = $(".cart").css('backgroundColor');
              cart.
                animate({ 'backgroundColor' : '#ffff00' }).
                animate({ 'backgroundColor' : old_c });
            } else {
              
              var old_c = cart.css('backgroundColor');
              cart.
                animate({ 'backgroundColor' : '#ffffff' }).
                animate({ 'backgroundColor' : old_c });
            }
          }
          
          
          bttn.find(".add").hide();
          bttn.find(".label").text("Added!");
          bttn.find(".check-white").removeClass('hidden').animate({ opacity : 1 },200);
          if (!suppress_success_message) {
            Flasher.add(['notice',"We've added that to your cart!"],true);  
          }
        
        }
        
        _.delay(function(){
          bttn.
            removeAttr('disabled').
            removeClass('disabled').
            find(".label").
            text("Add to Cart");
          bttn.find(".add").show();
          bttn.find(".check-white").addClass('hidden').css('opacity',0);
        },2000);

        if (self.cart_open===true) {
          self.refresh_cart();
        }

      },
      error : function(x,s,e) {
        bttn.
          removeAttr('disabled').
          removeClass('disabled').
          text("Add to Cart");
      }
    });
  },

  remove_from_cart : function(el) {

    if (Cart.quantities==1) {
      Cart.empty_cart();
    } else {
      var self  = this,
        input = el.animate({ opacity : 0}, { duration: 500, complete : function(){ 
          $(this).remove(); 
          delete(self.contents[el.attr('data-key')]);
          self.update_content_quantities();
          self.collate_shipping_costs();
          self.recompute_totals();
          self.save_cart();
          self.refresh_paypal_fields();
        }});
  
    }
    
  },

  increase_quantity : function(el,bttn) {
    
    var self  = this,
        input = el.find(".quantity_cell > input"),
        val   = parseInt(input.val()),
        max   = input.attr('data-maximum'),
        increase = function(){
          bttn.addClass('disabled');
          input.val( val+1 ).css('backgroundColor','#ffff00').animate({'backgroundColor':'#ffffff'});
          self.update_content_quantities();
          self.collate_shipping_costs();
          self.recompute_totals();

          self.save_cart(function(){
              bttn.removeClass('disabled');
            }, 
            function(error_results){
              
              if (error_results[0].length) { 
                Flasher.add(['error', "That product is not available."],true); 
              } else if (error_results[1].length) { 
                Flasher.add(['error', "That product does not have enough stock."],true); 
              }
              
              input.val( val );
              
              self.update_content_quantities();
              $(".cart_quantities").text( self.quantities );

              bttn.removeClass('disabled');

            });

          self.refresh_paypal_fields();
        };

    if (bttn.hasClass('disabled')) { return false; }

    if (max && max!='false') {
      if (parseInt(max) >= val+1) {
        increase();
      } else {
        Flasher.add(['error',"There are only " + max + " units of this product in stock."],true);
      }
    } else {
      increase();
    }

  },

  decrease_quantity : function(el, bttn) {

    var input = el.find(".quantity_cell > input"),
        val   = parseInt(input.val());
    
    if (bttn.hasClass('disabled')) { return false; }

    if (val>0) {
      if (Cart.quantities==1) {
        this.empty_cart();
      } else if (val==1) {
        this.remove_from_cart(el);
      } else {
        bttn.addClass('disabled');
        input.val( val-1 ).css('backgroundColor','#ffff00').animate({'backgroundColor':'#ffffff'});  
        this.update_content_quantities();
        this.collate_shipping_costs();
        this.recompute_totals();
        // this.remove_one_from_cart(function(){
        //   bttn.removeClass('disabled');
        // }); 
        this.save_cart(function(){
          bttn.removeClass('disabled');
        });  
        this.refresh_paypal_fields();
      }
    }

  },

  update_content_quantities : function(){

    var self = this;
    self.quantities = 0;
    
    for (var key in self.contents) {
      var quant = $(".cart_item[data-key=" + key + "]").find(".quantity_cell > input").val();  
      self.contents[key].quantity = quant;
      self.quantities+=parseInt(quant);  
    }

  },

  recompute_totals : function(discount_success_message){

    var total = 0, quantity = 0;
    
    $(".cart_item").each(function(){
      
      var el  = $(this),
          q   = parseInt(el.find(".quantity_cell > input").val()),
          per = parseFloat(el.find(".price").attr('data-price').replace(",","")),
          sub = el.find(".subtotal"),
          new_sub = q*per;
      
      sub.attr('data-subtotal',new_sub).text( new_sub ).formatCurrency({symbol:SHOP_CURRENCY});

      total += new_sub;

      quantity += q;

    });

    Cart.total_without_discount_and_without_shipping = total;

    $(".sub_total_price").
      text( Cart.total_without_discount_and_without_shipping ).
      formatCurrency({ symbol : SHOP_CURRENCY });

    var discount = Cart.apply_discount_code(total,quantity,discount_success_message);

    if (Cart.discount_code && Cart.discount_code.code_type=='free_shipping') {
      // we ignore the shipping costs
      // total -= parseFloat($("select.shipping_cost",".shopping_cart").val()||0);  

    } else {
      total -= discount;
      total = Math.max(0,total); // we need this in case discounts are actually bigger than the totals
      total += parseFloat($("select.shipping_cost",".shopping_cart").val()||0);  
      
    }
    
    Cart.total_with_discount_and_with_shipping = total;
    
    Cart.total = total;

    $(".total").text( total ).formatCurrency({ symbol : SHOP_CURRENCY });

    $(".cart_quantities").text( quantity );

    this.refresh_paypal_fields();

  },

  // doesn't save the cart, just updates the hash in memory by looking at all the form fields
  update_cart_contents : function(overwrite){
    var new_contents = {};

    $(".cart_item").each(function(){
      
      var el = $(this),
          key = el.attr('data-key');
      
      new_contents[key] = {
          key           : key,
          name          : el.attr('data-name'),
          item_id       : el.attr('data-id'),
          variant_name  : el.attr('data-variant-name'),
          quantity      : parseInt(el.find(".quantity_cell > input").val()),
          price         : parseFloat(el.find('.price').attr('data-price')),
          currency      : el.attr('data-currency')
        }; 

    });
    
    this.contents = new_contents;  

  },

  save_cart : function(complete_callback, failure_callback){

    var self = this, 
        cart_contents = _.extend({},self.contents),
        data = {},
        unneeded_keys = [ 'shop_id','category_slug','formatted_price','formatted_subtotal',
                          'deactivated','featured_at','featured_in_marketplace','_slugs',
                          'rates','rating_delta','weighted_rate_count','lowest_price','premium',
                          'partner','on_sale','dont_track_quantities','visible_in_marketplace',
                          'name','item_name','slug','description','price_variants','_keywords',
                          'price_variant_classes', 'num_views','num_favorites','num_orders',
                          'featured','hide_prices','trusted','availability','status' ];

    for (item_id in cart_contents) {
      _.each(unneeded_keys, function(key){
        delete cart_contents[item_id][key];
      });
    }

    cart_contents_as_array = _.values(cart_contents); 

    data = { c : { 
              cc : cart_contents_as_array, 
              shipping : self.shipping, 
              discount : self.total_discount,
              discount_code : (self.discount_code ? self.discount_code.code : ''), 
              discount_code_type : (self.discount_code ? self.discount_code.code_type : ''),
              total    : self.total } };
    
    //self.update_cart_contents();

    var url = "/carts/" + self.guest_id + "/update_cart.json?callback=?";
   
    $.jsonp({
      url      : url,
      type     : "GET",
      dataType : "JSON",
      data     : data,
      success  : function(data) {
        if (data.error) {
          if (typeof failure_callback!=='undefined') {
            failure_callback.call(this, data.error);
          }  
        } else if (data.contents) {
          self.contents = data.contents;
        }
      },
      complete : function(x) {
        if (typeof complete_callback!=='undefined') {
          complete_callback.call(this, data);
        }
        //self.update_cart_contents();
      }

    });

  },

  place_order : function(success_callback) {
    var self = this, 
        data = { cart : { 
                  payer_email   : self.payer_email,
                  shipping      : self.shipping,
                  discount      : self.total_discount,
                  discount_code : (self.discount_code ? self.discount_code.code : ''), 
                  discount_code_type : (self.discount_code ? self.discount_code.code_type : ''), 
                  total         : self.total } };
    
    self.update_cart_contents();

    var url = "/carts/" + self.guest_id + "/check_out.json?callback=?";
    
    $.jsonp({
      url      : url,
      type     : "GET",
      dataType : "jsonp",
      data     : data,
      success  : function(data) {
        self.order = data;
        if (typeof success_callback!=='undefined') {
          success_callback.call(this, self.order);
        }
      },
      error : function(x,s,e) {
        Flasher.add(['error', "We couldn't place your order yet. Please try again later."], true);
        if (typeof error_callback!=='undefined') {
          error_callback.call();
        }
      }
    });
  },

  display_cart : function(completion_callback){
    
    var self = this;

    self.cart_open = true;

    var cart_height = $(".shopping_cart").hasClass("no_paypal") ? self.height_order_form : self.height_open_cart;
    
    if (!self.mobile && !self.standalone) {
      $(".shopping_cart").
        removeClass('compact').
        animate({ width : self.width_cart }, 
          { duration : 250, 
            complete : function(){
              $(this).addClass('cart_open');
            }
          }).
        animate({ height : cart_height }, 
          { duration : 400,
            complete : function(){
              $(".shopping_cart_details").css({'display':'block'}).animate({ opacity : 1 });
            }
          });

      $(".checkout", ".shopping_cart_details").show();

    } else if (self.standalone) {
      
      $(".shopping_cart").removeClass('compact').addClass('cart_open');
      $(".shopping_cart_details").css({display:'block', opacity: 1 });
      $(".checkout", ".shopping_cart_details").show();

    }

    this.refresh_cart(completion_callback);

  },

  refresh_cart : function(completion_callback){

    var self = this,
        find_variant_stock = function(product){
          if (product.dont_track_quantities===true) { return false; }
          
          if (variant = _.find(product.price_variants, function(pv){
              var searching_name = [pv['primary'],pv['secondary']].join(" ").trim(); 
              if (searching_name==" "){ searching_name=""; }
              return searching_name==product.variant_name; 
            })) {
            return variant['quantity'];  
          }
          return false;
        };
    
    $(".shopping_cart table").addClass('loading');
    
    $.jsonp({
      url : "/carts/" + self.guest_id + ".json?callback=?",
      type : "GET",
      dataType : "jsonp",
      success : function(data) {
        
        var tmpl = $("#cart_item_tmpl").html();
        $(".shopping_cart table tbody").empty();
        $(".shopping_cart table").removeClass('loading');

        _.each(data.contents, function(d){
          var html = Mustache.to_html(tmpl, _.extend(d, {
            variant_stock : find_variant_stock(d)
          }));
          $(".shopping_cart table tbody").append(html);
        });

        self.contents = data.contents;

        self.verify_availability();

        self.collate_shipping_costs();
        
        if ($("#discount_code").is(":visible") && data.discount_code && data.discount_code!=$("#discount_code").val()) {
          
          $("#discount_code").val( data.discount_code );
          self.check_discount_code(function(){
            //self.recompute_totals();
            self.refresh_paypal_fields();
            if (self.mobile && (typeof Panels!=='undefined')) { Panels.recalculate_panel_heights(); }
            if (completion_callback!==undefined) { completion_callback.call(); }
          });
          
        } else {

          self.recompute_totals();
          self.refresh_paypal_fields();
          if (self.mobile && (typeof Panels!=='undefined')) { Panels.recalculate_panel_heights(); }
          if (completion_callback!==undefined) { completion_callback.call(); }

        }
        
      }
    });
  },

  verify_availability : function(){
    
    var self = this;

    if (available = _.filter(_.values(self.contents),function(c){ return c.availability==true; })) {
      if (available.length<_.values(self.contents).length) {
        Flasher.add(['error',"Some items in your cart are no longer available. Please remove them before you check out."],true);
      }
    }

  },

  hide_cart : function(){
    
    $(".shopping_cart_details").animate({ opacity : 0 },200);
    $(".checkout_details").animate({ opacity : 0 },200);
    
    if (!this.mobile && !this.standalone) {
      $(".shopping_cart").
        animate({ height : 150 }, 
          { duration : 500, 
            complete : function(){             
              $(".shopping_cart").removeClass('cart_open');
            }
          }).
        animate({ width : 210 }, 250);  

    } else if (this.standalone) {
      
      $(".shopping_cart").
        removeClass('cart_open').
        hide();

    } else {
      Panels.toggle_cart(); 
    }
    
    this.cart_open = false;

  },

  empty_cart : function(){
    var self = this;
    self.contents = {};
    $.jsonp({
      url : "/carts/" + self.guest_id + "/empty",
      dataType : "json",
      complete : function(data) {
        Flasher.add(['notice',"Your cart has been emptied."],true);
        $(".cart_quantities").text("0");
        $(".cart_has_contents").removeClass("cart_has_contents");
        self.quantities=0;
        self.hide_cart();
      }
    });
  },

  find_common_locations : function(){
    var self = this,
        loc  = _.map(self.contents,function(item,key){
                  return _.map(item.shipping_costs,function(sc){ return sc[0].trim(); });
                });
    return _.intersection.apply(_,loc);
  },

  collate_shipping_costs : function(){

    var self   = this,
        sc     = $("select.shipping_cost", ".shopping_cart").empty().unbind('change'),
        opts   = [],
        html   = "",
        shipping_costs = [], 
        base_prices = {}, 
        base_price_indexes = {}; 

    if (!self.validate_shipping_costs()) {
      self.show_shipping_warning();
    }
    // console.log(this.contents);
    // compile all of the items' shipping costs into a single temporary array
    _.map(this.contents, function(item){
      if (parseInt(item.quantity)>0) {
        for (var i=0; i<parseInt(item.quantity); i++) {
          shipping_costs.push(item.shipping_costs);  
        }  
      }
    });

    for (var i=0; i<shipping_costs.length; i++){
      if (shipping_costs[i]) {
        for (var j=0; j<shipping_costs[i].length;j++) {
          shipping_costs[i][j][0]=shipping_costs[i][j][0].trim().toLowerCase();  
        }  
      }
    } 

    var common_locations = self.find_common_locations();

    // find the highest "alone" price for each delivery location and use that as the base_price
    // we store the index of the item that has the highest base price in base_price_index
    _.each(shipping_costs, function(cost,i){
      _.each(cost, function(location,j){
        var loc_name = location[0].trim().toLowerCase();
        if (_.include(_.keys(base_prices), loc_name)) {
          if (parseFloat(location[1]) > base_prices[loc_name]) {
            base_prices[loc_name] = parseFloat(location[1]);
            base_price_indexes[loc_name] = i;  
          }
        } else {
          base_prices[loc_name] = parseFloat(location[1]);
          base_price_indexes[loc_name] = i;
        } 
      });
    });
    
    // finally, generate the dropdown menu, taking care to ignore the costs in the item at the base_price_index,
    // since we've already used that as our base price

    // products
    // -> [ [ 'Location', 12.0, 6.0], [ 'Location 2', 18.0, 9 ] ]
    // -> [ [ 'Location', 10.0, 5.0], [ 'Location 2', 15.0, 7 ] ]
    // -> [ [ 'Location', 10.0, 5.0], [ 'Location 2', 15.0, 7 ] ]

    if (!common_locations.length) {
      common_locations = _.map(self.contents,function(item){ 
        return _.map(item.shipping_costs, function(sc){ return sc[0].trim().toLowerCase(); }); 
      });
      common_locations = _.flatten(common_locations);
    }
    
    //console.log('base prices', base_prices, 'base indexes', base_price_indexes, 'common', common_locations, 'shipping', shipping_costs);

    if (!self.contents || !_.keys(self.contents).length) {
      Flasher.add(['error',"Your shopping cart is empty"], true);
    } else if (!common_locations.length) {
      Flasher.add(['error',"Some items in your shopping cart can not be shipped to the same location. You may need to order them separately."], true);
    }
    //console.log('new');
    _.each(shipping_costs, function(cost, i){
      _.each(cost, function(location,j){
        var loc_name = location[0].trim().toLowerCase();
        if (_.include(common_locations, loc_name)) {
          if (i!=base_price_indexes[loc_name]) {
            if (_.include(_.keys(opts), loc_name)) {
              opts[""+loc_name] += parseFloat(location[2]);
            } else {
              opts[""+loc_name] = parseFloat(location[2]);
            }  
          } else {
            if (_.include(_.keys(opts), loc_name)) {
              opts[""+loc_name] += parseFloat(base_prices[loc_name]);
            } else {
              opts[""+loc_name] = parseFloat(base_prices[loc_name]);
            }
          }
        }
      });  
      
    });

    //console.log(opts);

    for (var prop in opts) {
      var shipping_price = _.isNaN(opts[prop]) ? '0.0' : opts[prop];
      $("<option class='" + prop.to_param() + "' value='" + shipping_price + "'>" + prop.titleize() + " (" + SHOP_CURRENCY + shipping_price + ")</option>").appendTo(sc);
    }

    // move the "everywheres" to the bottom of the stack
    sc.find(".everywhere").appendTo(sc);
    sc.find(".everywhere-else").appendTo(sc);

    sc.change(function(){
      self.recompute_totals();
      var num_val = _.isNull($(this).val()) ? 0.0 : $(this).val();
      $(".shipping_cost_display",".shopping_cart").
        text(num_val).
        formatCurrency({symbol:SHOP_CURRENCY});
      self.shipping = num_val;  
    }).change(); //.select2().change();
    //console.log(_.values(opts)[0] );
    if (_.values(opts).length) {
      sc.val( _.values(opts)[0] ).change(); //trigger('change');
    }

  },

  validate_shipping_costs : function(){
    
    var self = this;

    if (self.contents && _.keys(self.contents).length) {
      
      var costs = _.map(self.contents, function(item,key){
        return item.shipping_costs ? item.shipping_costs.length : false;
      });
      
      if (_.uniq(_.compact(costs)).length>1) {
        return false;
      } else {
        return true;  
      }

    } else {
      return true;
    }

  },

  show_shipping_warning : function(){

    Flasher.add(['error', "Not all of these products can be shipped to every listed location. Please review your order before submitting."], true);

  },

  checkout : function(){
    
    var self = this,
      show_checkout = function(){
        
        var cart_height = $(".shopping_cart").hasClass("no_paypal") ? self.height_order_form : self.height_checkout;

        if (!self.standalone) {
          $(".shopping_cart").animate({ width : self.width_cart, height : cart_height });
          $(".checkout_details").
            css({ display : 'block' }).
            animate({ opacity : 1 }, { duration : 500, complete : function(){
              scrollWindow($("#shipping_costs_and_total").position().top);
            }});

          $(".checkout", ".shopping_cart_details").hide();

        } else {
          
          $(".checkout_details").css({ display : 'block' });

        }

        self.refresh_paypal_fields();

        self.initialize_payment_buttons();

      };

    this.loading();
    this.checking_out = true;

    if (!this.cart_open) {
      this.display_cart(show_checkout);  
    } else {
      show_checkout();
    }

  },

  update_payment_fields : function(offline_or_paypal){
    var f = $(".order_form form");
    $("#order_contents",f).val( JSON.stringify(Cart.contents) );
    $("#order_shipping_cost", f).val( $("select.shipping_cost").val() );
    $("#order_discount", f).val( Cart.total_discount );
    $("#order_discount_code", f).val( Cart.discount_code ? Cart.discount_code.code : '' );
    $("#order_discount_code_type", f).val( Cart.discount_code ? Cart.discount_code.code_type : '' );
    $("#order_total", f).val( Cart.total );
    $("#order_payment_method", f).val(offline_or_paypal);
  },

  initialize_order_form : function(){
    $(".order_form form").validate({
      rules : {
        "order[firstname]" : { required : true },
        "order[lastname]"  : { required : true },
        "order[email]"     : { required : true, email : true },
        "order[phone]"     : { required : true },
        "order[address]"   : { required : true },
        "order[city]"      : { required : true },
        "order[postcode]"  : { required : true },
        "order[country]"   : { required : true }
      },
      onsubmit : true
    });
  },

  checkout_with_nothing : function(){

    var f = $(".order_form form");
    if (!f.length) { return false; }
    
    f.data('validator').settings.submitHandler=false;

    $("input[type=submit]",f).click(function(){ Cart.update_payment_fields('offline'); });

  },

  place_order_then_checkout_with_paypal : function(){

    var self = this,
        f    = $(".order_form form");

    f.data('validator').settings.submitHandler=function(form){

      $(".place_order",f).val("Sending ...").attr('disabled','disabled');

        Cart.update_payment_fields('paypal');

        // Paypal won't let us send them a shopping cart with a discount greater than the total
        if (Cart.total_discount>=Cart.total_without_discount) {
          $("#discount_amount_cart").val(Cart.total_without_discount-0.01);  
        }

        $.ajax({
          url      : "/orders",
          type     : "POST",
          data     : f.serializeArray(),
          dataType : "JSON",
          success  : function(data){
            if (data.order) {
              
              // if (self.in_iframe) {
              //   window.parent.parent.scrollTo(0,0);
              // }

              $("#invoice").val(data.order._id);
              $("#paypal_form").submit();  
              Flasher.add(['notice',"Your order has been placed! You are now being redirected to Paypal ..."],true);
              f.find(".place_order").val("Sending to Paypal ...");

            } else if (data.errors) {

              Flasher.add(['error',data.errors],true);
              f.find(".place_order").val("Send Order").removeAttr('disabled');
            }
          }
        });
        return false;
    };

  },

  cancel_checkout : function(){
    
    $(".checkout_details").animate({ opacity : 0 }, { duration : 500, complete : function(){ $(this).css('display','none'); }});
    this.checking_out = false;
    this.hide_cart();

  },

  refresh_paypal_fields : function(){
    var self = this,
        tmpl = $("#paypal_hidden_field_tmpl").html(),
        paypal_form = $("#paypal_form"),
        idx = 0,
        ship_idx = _.values(self.contents).length > 1 ? 2 : 1;
    
    $(".paypal_items", paypal_form).empty();

    var first = true;

    _.each(self.contents, function(d){
        
        $(".paypal_items", paypal_form).append(Mustache.to_html(tmpl, {
          name      : d.name,
          variant   : d.variant_name,
          i         : idx+=1,
          price     : d.price,
          shipping_price : (first ? parseFloat($("select.shipping_cost").val()) : 0.0),
          quantity  : d.quantity
        }));

        first = false;
      
    });

    if (self.discount_code) {
      $("#discount_amount_cart", paypal_form).val(self.total_discount);
    }
    
  },

  loading : function(){

    this.is_loading = true;
    $(".shop_header").addClass('loading');

  },

  stop_loading : function(){

    this.is_loading = false;
    $(".shop_header").removeClass('loading');

  },

  calculate_quantities : function(){

    var quantities = 0;
    _.each(_.values(this.contents), function(v){
      quantities += parseInt(v.quantity);
    });
    return quantities;

  },

  check_discount_code : function(complete_callback, show_notice){

    var dc = $("#discount_code").val().trim().toLowerCase(),
        dc_regex = new RegExp(/^[a-z0-9]{2,32}$/i);
    console.log('checking');
    if (dc_regex.test(dc)) {
      $.jsonp({
        url : "/shop/codes/" + dc + ".json?callback=?",
        type : "GET",
        dataType : "jsonp",
        success : function(data){
          
          if (data.results[0]=='success') {
            Cart.discount_code=data.code;
            Cart.recompute_totals(show_notice ? data.results[1] : false);
            
          } else if (data.results[0]=='error') {
            Flasher.add(data.results, true);
            Cart.discount_code=false;
            Cart.recompute_totals();

          }

          Cart.save_discount_code_with_cart();

        },
        complete : function(xhr,text){
          if (typeof complete_callback!=='undefined') {
            complete_callback.call();
          } 
        }});

    } else {
      
      //Flasher.add(['error', "That discount code is not valid."],true);
      Cart.discount_code=false;
      Cart.recompute_totals();
      if (typeof complete_callback!=='undefined') {
        complete_callback.call();
      }
    }
  },

  save_discount_code_with_cart : function() {
    
    var cart = this;

    $.ajax({
      url : "/carts/add_discount",
      dataType : "JSON",
      data : { discount_code : cart.discount_code.code, discount_total : cart.total_discount },
      success : function(data){

      }
    });

  },

  apply_discount_code : function(total, quantity, discount_success_message){
    
    var discount = 0;
    // console.log('applying');
    if (code = this.discount_code) {

      var threshold_type  = code.threshold_type,
          threshold_price = parseFloat(code.threshold_price)>0 ? parseFloat(code.threshold_price) : false,
          threshold_items = parseInt(code.threshold_items),
          qualified = false;

      if (!threshold_type || 
        (threshold_type=='price' && threshold_price<=total) ||
        (threshold_type=='items' && threshold_items<=quantity) )
        {
          
          if (discount_success_message){
            Flasher.add(['notice', discount_success_message],true);  
          }
          qualified = true;
        
        } else if ( threshold_type=='price' && threshold_price>total ) {
        
          Flasher.add(['alert', "Your shopping cart total must reach at least " + SHOP_CURRENCY + threshold_price + " to be eligible for this discount code."],true);
        
        } else if ( threshold_type=='items' && threshold_items>quantity ) {
        
          Flasher.add(['alert', "Your shopping cart total must have at least " + threshold_items + " item(s) to be eligible for this discount code."],true);
        
        }

      if (code.code_type=='percentage') {
        
        if ((percentage = parseInt(code.percentage)) && qualified) { 
          discount = total*(percentage/100);
          this.total_discount = discount;
          $(".discount_code_value").text("-" + discount).formatCurrency({symbol:SHOP_CURRENCY});
        }

      } else if (code.code_type=='absolute' && qualified) {
        
        discount = parseFloat(code.absolute);
        this.total_discount = discount;
        $(".discount_code_value").text("-" + discount).formatCurrency({symbol:SHOP_CURRENCY});

      } else if (code.code_type=='free_shipping' && qualified) {
        
        discount = this.shipping;
        this.total_discount = discount;
        $(".discount_code_value").text("-" + this.shipping).formatCurrency({symbol:SHOP_CURRENCY});

      }

      
    } else {
      $(".discount_code_value").text("-0.00").formatCurrency({symbol:SHOP_CURRENCY});
      this.total_discount = 0;
    }
    
    return discount;

  }

}
