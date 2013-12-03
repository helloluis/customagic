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

    this.buy_now_price = this.product_sub_style.buy_now_price;

    this.initialize_sales_goal();

    this.initialize_currency();

  },

  initialize_sales_goal : function(){
    
    var that = this,
        refresh_indicators = function(){
          that.refresh_indicators();
        };

    this.base_price        = $("#product_base_price");
    this.retail_price      = $("#product_buy_now_price");
    this.charity_donation  = $("#product_charity_donation");
    this.profit            = $(".profit_margin");
    this.total_earn_20     = $(".total_earnings_10");
    this.total_earn_100    = $(".total_earnings_100");

    //this.retail_price.keyup(refresh_indicators);

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
    // defunct
    var that = this,
        int  = parseInt(int),
        bp   = _.find(that.prices, function(p){
                  var range = [p[0][0], p[0][p[0].length-1]];
                  if (int>=parseInt(range[0]) && int<=parseInt(range[1])) {
                    return true;
                  }
                });
    
    if (bp){
      return bp[1];  
    } else {
      return that.prices[0][1];
    }
    
  },

  refresh_indicators : function(with_default_retail_price){

    var that = this,
        bp   = that.buy_now_price, //prices[0][1],
        cp   = parseFloat(that.charity_donation.val()),
        rp   = parseFloat(that.retail_price.val());
          
    that.base_price.val(bp);
    
    if (rp<bp+cp) {
      that.retail_price.val( bp+cp );
      var profit = 0;
    } else {
      var profit = Math.max(0,rp-(bp+cp));  
    }

    that.profit.text(profit);
    
    that.total_earn_20.text(profit*20);
    that.total_earn_100.text(profit*100);

    $(".currency").not("input").currency({ region: SHOP.currency_symbol });
    $("input.currency").currency({ region : 'NA' });

  }


};