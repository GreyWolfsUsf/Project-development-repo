import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count", "list"]
  
  connect() {
    console.log("Notifications controller connected")
    this.startPolling()
  }
  
  startPolling() {
    // Check for new notifications every 60 seconds
    this.pollingInterval = setInterval(() => {
      this.fetchNotifications()
    }, 60000)
  }
  
  fetchNotifications() {
    fetch('/notifications.json')
      .then(response => response.json())
      .then(data => {
        this.updateNotificationCount(data.unread_count)
        this.updateNotificationList(data.recent_notifications)
      })
      .catch(error => {
        console.error('Error fetching notifications:', error)
      })
  }
  
  updateNotificationCount(count) {
    if (this.hasCountTarget) {
      this.countTarget.textContent = count
      
      if (count > 0) {
        this.countTarget.classList.remove('d-none')
      } else {
        this.countTarget.classList.add('d-none')
      }
    }
  }
  
  updateNotificationList(notifications) {
    if (this.hasListTarget && notifications && notifications.length > 0) {
      // Clear existing notifications
      this.listTarget.innerHTML = ''
      
      // Add new notifications
      notifications.forEach(notification => {
        const element = this.buildNotificationElement(notification)
        this.listTarget.appendChild(element)
      })
    }
  }
  
  buildNotificationElement(notification) {
    const li = document.createElement('a')
    li.href = `/notifications/${notification.id}`
    li.className = 'list-group-item list-group-item-action'
    
    const div = document.createElement('div')
    div.className = 'd-flex w-100 justify-content-between'
    
    const message = document.createElement('h6')
    message.className = 'mb-1'
    message.textContent = notification.message
    
    const time = document.createElement('small')
    time.textContent = notification.time_ago
    
    div.appendChild(message)
    div.appendChild(time)
    li.appendChild(div)
    
    return li
  }
  
  markAsRead(event) {
    const id = event.params.id
    
    fetch(`/notifications/${id}/mark_as_read`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json'
      }
    })
      .then(response => response.json())
      .then(data => {
        this.updateNotificationCount(data.unread_count)
      })
      .catch(error => {
        console.error('Error marking notification as read:', error)
      })
  }
  
  markAllAsRead(event) {
    event.preventDefault()
    
    fetch('/notifications/mark_all_as_read', {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json'
      }
    })
      .then(response => response.json())
      .then(data => {
        this.updateNotificationCount(0)
        
        if (this.hasListTarget) {
          this.listTarget.innerHTML = '<div class="list-group-item">No new notifications</div>'
        }
      })
      .catch(error => {
        console.error('Error marking all notifications as read:', error)
      })
  }
  
  disconnected() {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval)
    }
  }
}