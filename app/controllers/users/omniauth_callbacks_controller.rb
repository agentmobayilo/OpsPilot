class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]

    if user_signed_in?
      current_user.connect_oauth!(auth)
      redirect_to settings_path, notice: "Google account connected."
      return
    end

    user = user_from_connection(auth) || user_from_email(auth)

    if user.persisted?
      user.connect_oauth!(auth)
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: "Could not authenticate via Google."
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Google sign-in failed."
  end

  private

  def user_from_connection(auth)
    connection = OAuthConnection.find_by(provider: auth.provider, uid: auth.uid)
    connection&.user
  end

  def user_from_email(auth)
    email = auth.info&.email
    return User.new unless email.present?

    User.find_or_create_by(email: email) do |u|
      u.password = Devise.friendly_token.first(20)
    end
  end
end
