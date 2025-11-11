class SubscribersController < ApplicationController
  def create
    @subscriber = Subscriber.new(subscriber_params)
    
    if @subscriber.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("flash-toast-container", partial: "shared/flash_toast_message", locals: { 
              message: "Successfully subscribed to our newsletter!", 
              type: :notice,
              id: "subscriber-toast-#{SecureRandom.hex(4)}"
            })
          ]
        end
        format.html { redirect_to root_path, notice: "Successfully subscribed to our newsletter!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("flash-toast-container", partial: "shared/flash_toast_message", locals: { 
              message: @subscriber.errors.full_messages.first, 
              type: :alert,
              id: "subscriber-toast-#{SecureRandom.hex(4)}"
            })
          ]
        end
        format.html { redirect_to root_path, alert: @subscriber.errors.full_messages.first }
      end
    end
  end
  
  def unsubscribe
    @subscriber = Subscriber.find_by(email: params[:email])
    
    if @subscriber&.unsubscribe!
      redirect_to root_path, notice: "You have been unsubscribed from our newsletter."
    else
      redirect_to root_path, alert: "Email not found in our subscriber list."
    end
  end
  
  private
  
  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end

