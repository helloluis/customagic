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

    this.buy_now_price  = this.product.buy_now_price;

    this.highest_cost   = this.product_sub_style.highest_production_price;

    this.lowest_cost    = this.product_sub_style.lowest_production_price;
    
    this.delta          = this.product_sub_style.delta;

    this.initialize_sales_goal();

    this.initialize_currency();

  },

  initialize_sales_goal : function(){
    
    var that = this,
        refresh_indicators = function(){
          that.refresh_indicators();
        };

    this.retail_price      = $("#product_buy_now_price");
    this.charity_donation  = $("#product_charity_donation");
    this.profit            = $(".profit_margin");
    this.total_earn_1      = $(".total_earnings_1");
    this.total_earn_20     = $(".total_earnings_20");
    this.total_earn_100    = $(".total_earnings_100");

    this.refresh_indicators(true);

  },

  initialize_currency : function(){
    
    var that = this;

    $("input.currency").
      keyup(function(){
        clearTimeout($.data(this,'timer'));
        var wait = setTimeout(function(){ that.refresh_indicators(); }, 1000);
        $(this).data('timer',wait);
      });

  },

  refresh_indicators : function(){

    var that = this,
        hp   = that.highest_cost,
        lp   = that.lowest_cost,
        del  = that.delta,
        bp   = that.buy_now_price,
        cp   = parseFloat(that.charity_donation.val()),
        rp   = parseFloat(that.retail_price.val());
    
    if (rp<hp+cp) {
      that.retail_price.val( hp+cp );
    }

    that.total_earn_1.text( that.calculate_production_cost_delta(1) );
    that.total_earn_20.text( that.calculate_production_cost_delta(20) );
    that.total_earn_100.text( that.calculate_production_cost_delta(100) );

    $(".currency").not("input").currency({ region: SHOP.currency_symbol });
    $("input.currency").currency({ region : 'NA' });

  },

  calculate_production_cost_delta : function(units) {

    var that   = this,
        hp     = that.highest_cost,
        lp     = that.lowest_cost,
        rp     = that.retail_price.val(),
        cp     = parseFloat(that.charity_donation.val())
        del    = that.delta,
        profit = 0;

    for (var i=0; i<units-1; i++) {
      var base = Math.max(lp, (hp-(del*i)));
      profit += base-(rp+cp);
    }

    return profit;

  }


};