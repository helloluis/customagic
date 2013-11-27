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
        refresh_indicators = function(){
          that.refresh_indicators();
        };

    this.sales_goal   = $("#product_sales_goal");
    this.base_price   = $("#product_base_price");
    this.retail_price = $("#product_group_price");
    this.profit       = $(".profit_margin");
    this.sales_goal_indicator = $(".sales_goal");
    this.total_sales  = $(".total_sales");
    this.total_earn   = $(".total_earnings");

    this.sales_goal.keyup(refresh_indicators);

    this.refresh_indicators(true);

  },

  initialize_currency : function(){
    
    var that = this;

    $("input.currency").
      keyup(function(){
        clearTimeout($.data(this,'timer'));
        var wait = setTimeout(function(){ that.refresh_indicators(); }, 2000);
        $(this).data('timer',wait);
      });

  },
  
  find_base_price : function(int) {
    
    var that = this,
          bp = _.find(that.prices, function(p){
                  var range = [p[0][0], p[0][p[0].length-1]];
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

  refresh_indicators : function(with_default_retail_price){

    var that = this,
        bp   = that.find_base_price(that.sales_goal.val()),
        rp   = with_default_retail_price ? bp+(bp*0.2) : parseFloat(that.retail_price.val());
          
    that.base_price.val(bp);

    if (with_default_retail_price) {
      that.retail_price.val(rp);  
    }
    
    that.profit.text(rp-bp);
    
    that.sales_goal_indicator.text(that.sales_goal.val());
    that.total_sales.text(rp*parseInt(that.sales_goal.val()));
    that.total_earn.text((rp-bp)*parseInt(that.sales_goal.val()));

    $(".currency").not("input").currency({ region: SHOP.currency_symbol });
    $("input.currency").currency({ region : 'NA' });

  }


};