class NotificationsController < ApplicationController
    before_action :set_notification, only: [:show, :mark_as_read]
    
    def index
      @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(20)
    end
    
    def show
      @notification.mark_as_read unless @notification.read?
    end
    
    def mark_as_read
      @notification.mark_as_read
      redirect_back(fallback_location: notifications_path, notice: "Notification marked as read")
    end
    
    def mark_all_as_read
      current_user.notifications.where(read: false).update_all(read: true)
      redirect_to notifications_path, notice: "All notifications marked as read"
    end
    
    private
    
    def set_notification
      @notification = current_user.notifications.find(params[:id])
    end
  end