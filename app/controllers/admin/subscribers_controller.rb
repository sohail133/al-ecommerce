require 'csv'

class Admin::SubscribersController < Admin::BaseController
  before_action :set_subscriber, only: [:show, :destroy, :toggle_status]
  
  def index
    @subscribers = Subscriber.recent
    @subscribers = @subscribers.search(params[:query]) if params[:query].present?
    @subscribers = @subscribers.by_status(params[:status]) if params[:status].present?
    @subscribers = @subscribers.page(params[:page])
    
    @total_subscribers = Subscriber.count
    @active_subscribers = Subscriber.active.count
    @unsubscribed = Subscriber.unsubscribed.count
  end
  
  def show
  end
  
  def destroy
    if @subscriber.destroy
      redirect_to admin_subscribers_path, notice: "Subscriber deleted successfully."
    else
      redirect_to admin_subscribers_path, alert: "Failed to delete subscriber."
    end
  end
  
  def toggle_status
    if @subscriber.active?
      @subscriber.unsubscribe!
      message = "Subscriber unsubscribed successfully."
    else
      @subscriber.resubscribe!
      message = "Subscriber resubscribed successfully."
    end
    
    redirect_to admin_subscribers_path, notice: message
  end
  
  def export
    @subscribers = Subscriber.active.order(:email)
    
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Email', 'Status', 'Subscribed At', 'Unsubscribed At']
      
      @subscribers.each do |subscriber|
        csv << [
          subscriber.email,
          subscriber.status,
          subscriber.subscribed_at&.strftime("%Y-%m-%d %H:%M:%S"),
          subscriber.unsubscribed_at&.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
    
    send_data csv_data, 
              filename: "subscribers-#{Date.today}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end
  
  private
  
  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end
end

