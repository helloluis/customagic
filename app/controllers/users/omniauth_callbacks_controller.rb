class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    omniauth_request = request.env["omniauth.auth"]
    
    @user = User.find_for_facebook_oauth(omniauth_request, current_user)
    @user.update_with_facebook(omniauth_request)
    
    if @user.persisted?
      @shop = @user.create_shop unless @user.shop.any?
      # sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      sign_in @user
      redirect_to "/#{@shop.slug}/products/new" #, :event => :authentication #this will throw if @user is not activated

      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end


# #<OmniAuth::AuthHash raw_info=#<OmniAuth::AuthHash education=[#<OmniAuth::AuthHash school=#<OmniAuth::AuthHash id="112272962117128" name="University of the Philippines Integrated School"> type="High School" year=#<OmniAuth::AuthHash id="131821060195210" name="1997">>, #<OmniAuth::AuthHash concentration=[#<OmniAuth::AuthHash id="108325695856472" name="Visual Communication">] school=#<OmniAuth::AuthHash id="110093295677735" name="University of the philippines"> type="College">] email="helloluis@me.com" favorite_athletes=[#<OmniAuth::AuthHash id="120835987995006" name="Spanishiwa">, #<OmniAuth::AuthHash id="62884556670" name="Geoff Robinson (iNcontroL)">, #<OmniAuth::AuthHash id="174243119281991" name="IdrA">, #<OmniAuth::AuthHash id="152259921498570" name="Tyler Wasieleski">, #<OmniAuth::AuthHash id="114412026792" name="Jaedong">] favorite_teams=[#<OmniAuth::AuthHash id="170449369652184" name="Incredible Miracle">, #<OmniAuth::AuthHash id="171579346196053" name="Evil Geniuses">, #<OmniAuth::AuthHash id="166004850102226" name="Team Liquid">, #<OmniAuth::AuthHash id="187624054613008" name="Startale">, #<OmniAuth::AuthHash id="192166147468157" name="Team eXo (eXorbitant)">] first_name="Luis" gender="male" hometown=#<OmniAuth::AuthHash id="106050279435951" name="Quezon City, Philippines"> id="676321517" last_name="Buenaventura" link="https://www.facebook.com/helloluis" locale="en_US" location=#<OmniAuth::AuthHash id="112258348789775" name="Fort Bonifacio"> middle_name="II" name="Luis Buenaventura II" quotes="\"I have never killed a man, but I have read many obituaries with great pleasure.” - Clarence Darrow\n\n\"How come we've reached this fork in the road, and yet it cuts like a knife?\" - Flight of the Conchords" sports=[#<OmniAuth::AuthHash description="kswitch (696) on NA,\nkswitch (953) on SEA" id="166226043413093" name="Starcraft II" with=[#<OmniAuth::AuthHash id="100000339968688" name="Gary Salazar">, #<OmniAuth::AuthHash id="1557391577" name="Buddy Magsipoc">, #<OmniAuth::AuthHash id="722456733" name="Volts Vitug">, #<OmniAuth::AuthHash id="1149895468" name="Michael Vincent Saniel">, #<OmniAuth::AuthHash id="745331234" name="Kenji Inukai">, #<OmniAuth::AuthHash id="678470861" name="Nicole Concepcion de Vera">]>] timezone=8 updated_time="2013-11-21T03:57:30+0000" username="helloluis" verified=true work=[#<OmniAuth::AuthHash description="Rethinking the web-page building experience." employer=#<OmniAuth::AuthHash id="116468375031046" name="infinite.ly"> location=#<OmniAuth::AuthHash id="104007419635992" name="Pasig City"> position=#<OmniAuth::AuthHash id="130875350283931" name="CEO & Founder"> start_date="2010-02-15">, #<OmniAuth::AuthHash employer=#<OmniAuth::AuthHash id="151052508584" name="DevCon Philippines"> end_date="0000-00" start_date="2012-10-01">, #<OmniAuth::AuthHash description="Ruby practice lead" employer=#<OmniAuth::AuthHash id="189635434550855" name="Exist Global"> end_date="2010-01-01" position=#<OmniAuth::AuthHash id="129469867097597" name="Director"> start_date="2008-10-01">, #<OmniAuth::AuthHash employer=#<OmniAuth::AuthHash id="137561106737" name="SyndeoLabs"> end_date="2008-10-01" location=#<OmniAuth::AuthHash id="112308428784887" name="Makati City"> position=#<OmniAuth::AuthHash id="204886116188727" name="co-founder/social architect"> start_date="2007-10-01" with=[#<OmniAuth::AuthHash id="505082479" name="Hunter Nield">, #<OmniAuth::AuthHash id="556746980" name="Mae Paulino">, #<OmniAuth::AuthHash id="650783648" name="Tim Medina">, #<OmniAuth::AuthHash id="724460317" name="Kindred Pasana">, #<OmniAuth::AuthHash id="1353308515" name="Kristina Lim">, #<OmniAuth::AuthHash id="531437152" name="Jason Torres">, #<OmniAuth::AuthHash id="1295194098" name="Evan Sagge">]>, #<OmniAuth::AuthHash employer=#<OmniAuth::AuthHash id="161380290730278" name="syndeo::media"> with=[#<OmniAuth::AuthHash id="505082479" name="Hunter Nield">]>]>> !!
