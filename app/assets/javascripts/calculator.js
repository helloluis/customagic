var Calculator = {
  
  initialize : function(shop, types, product) {
    
    var that = this;

    this.shop           = shop;
    this.product_types  = types;
    this.product        = product;
    this.product_form   = $(".info_form_container > form");

    this.product_type   = _.find(this.product_types, function(pt){ return pt.slug==that.product.product_type }); // shirt
    
    this.product_style  = _.find(this.product_type.product_styles, function(ps){ return ps.slug==that.product.product_style; }); // basic tee

    this.product_sub_style = _.find(this.product_style.sub_styles, function(pss){ return pss.slug==that.product.product_sub_style; }); // basic_standard

    this.prices = this.product_sub_style.prices;

    this.initialize_sales_goal();

    this.initialize_currency();

  },

  initialize_sales_goal : function(){
    
    var that = this,
        find_base_price = function(int) {
          var bp = _.find(that.prices, function(p){
            var range = p[0].split("..");
            if (int>=parseInt(range[0]) && int<=parseInt(range[1])) {
              return true;
            }
          });
          
          if (bp){
            return bp[1];  
          } else {
            return 0;
          }
          
        },
        refresh_indicators = function(){
          
          var bp = find_base_price(that.sales_goal.val()),
              rp = bp+(bp*0.2);
          
          that.base_price.val(bp);
          that.retail_price.val(rp);
          that.profit.text(rp-bp);
          
          that.sales_goal_indicator.text(that.sales_goal.val());
          that.total_sales.text(rp*parseInt(that.sales_goal.val()));
          that.total_earn.text((rp-bp)*parseInt(that.sales_goal.val()));

          $(".currency").not("input").currency({ region: SHOP.currency_symbol });

        };

    this.sales_goal   = $("#product_sales_goal");
    this.base_price   = $("#product_base_price");
    this.retail_price = $("#product_retail_price");
    this.profit       = $(".profit_margin");
    this.sales_goal_indicator = $(".sales_goal");
    this.total_sales  = $(".total_sales");
    this.total_earn   = $(".total_earnings");

    this.sales_goal.keyup(refresh_indicators).keyup();

  },

  initialize_currency : function(){

    $("input.currency").change(function(){
      var el = $(this);
      if (el.data('timer')) { el.data('timer').stop(); }
      el.data('timer', $.timer(function(){
        el.currency({ region: 'NA' });
      }));
      el.data('timer').set({ time: 1000, autostart: true });
    }).
    change();

  }


};